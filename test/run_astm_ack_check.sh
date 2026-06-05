#!/usr/bin/env bash
set -euo pipefail

# One-shot diagnostic for ASTM -> MLLP ACK path.
# It starts a clean listener, reloads IRIS classes, sends one ASTM message,
# exports logs, and prints only the useful trace lines.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER="${IRIS_CONTAINER:-iris-test}"
NAMESPACE="${IRIS_NAMESPACE:-IRISAPP}"
IRIS_USER="${IRIS_USER:-_SYSTEM}"
IRIS_PASS="${IRIS_PASS:-SYS}"
APP_TIMEOUT="${APP_TIMEOUT:-20}"
RELOAD_CLASSES="${RELOAD_CLASSES:-0}"
IRIS_SQL_HOST="${IRIS_SQL_HOST:-localhost}"
IRIS_SQL_PORT="${IRIS_SQL_PORT:-10972}"

cd "$ROOT_DIR"

echo "[1] Stop old listener processes in container"
docker exec "$CONTAINER" sh -lc '
set +e
# Kill known listener script processes
pids=$(ps -eo pid,args | awk "\$2==\"python3\" && \$3==\"/test/mllp_listener.py\" {print \$1}")
if [ -n "$pids" ]; then kill $pids 2>/dev/null; fi
# Kill anything still listening on 6662
lpids=$(ss -ltnp 2>/dev/null | sed -n "s/.*pid=\([0-9][0-9]*\).*/\1/p" | sort -u)
if [ -n "$lpids" ]; then kill $lpids 2>/dev/null; fi
sleep 1
true
'

echo "[2] Start one listener with ACK enabled on :6662"
LISTENER_PID="$(docker exec "$CONTAINER" sh -lc ': >/tmp/mllp_listener.log; python3 -u /test/mllp_listener.py --host 0.0.0.0 --port 6662 --send-ack >/tmp/mllp_listener.log 2>&1 & echo $!')"
echo "Listener PID: ${LISTENER_PID}"

echo "[3] Verify listener is listening"
docker exec "$CONTAINER" sh -lc 'ss -ltnp 2>/dev/null | grep :6662 || true'

echo "[4] Probe direct MLLP ACK path on 127.0.0.1:6662"
docker exec "$CONTAINER" sh -lc 'python3 - <<"PY"
import socket
VT=b"\x0b"
END=b"\x1c\x0d"
payload=b"H|\\^&|||PING|||||||P|E1394-97|20260605170000\rL|1|N\r"
s=socket.socket()
s.settimeout(5)
s.connect(("127.0.0.1",6662))
s.sendall(VT+payload+END)
data=s.recv(4096)
s.close()
print("probe_recv_len", len(data))
print("probe_recv_prefix", data[:40])
if len(data)==0:
    raise SystemExit("MLLP probe failed: empty response")
PY'

echo "[5] Check IRIS SuperServer reachability on ${IRIS_SQL_HOST}:${IRIS_SQL_PORT}"
python3 - <<PY
import socket
host = "${IRIS_SQL_HOST}"
port = int("${IRIS_SQL_PORT}")
s = socket.socket()
s.settimeout(5)
try:
    s.connect((host, port))
    print(f"IRIS SQL port reachable: {host}:{port}")
finally:
    s.close()
PY

echo "[6] Send one ASTM test message"
cd "$ROOT_DIR/test"
SEND_EXIT=0
if ! python3 send_astm_e1381.py --host 127.0.0.1 --port 29010 --app-timeout "$APP_TIMEOUT"; then
    echo "First send failed, retrying in 2 seconds..."
    sleep 2
    if ! python3 send_astm_e1381.py --host 127.0.0.1 --port 29010 --app-timeout "$APP_TIMEOUT"; then
        SEND_EXIT=1
        echo "ASTM send failed twice; continuing with diagnostics."
    fi
fi

echo "[7] Export IRIS event log and locate latest CSV"
cd "$ROOT_DIR/iris-test/src/code"
EXPORT_EXIT=0
if ! python3 export_event_log.py >export_event_log.out 2>export_event_log.err; then
    echo "First log export failed; retrying in 2 seconds..."
    sleep 2
    if ! python3 export_event_log.py >export_event_log.out 2>export_event_log.err; then
        EXPORT_EXIT=1
        echo "Event log export failed twice; continuing with listener diagnostics."
    fi
fi
if [ "$EXPORT_EXIT" -eq 0 ]; then
    LATEST_CSV="$(ls -1t export_event_log_*.csv | head -n 1)"
    echo "Latest CSV: ${LATEST_CSV}"
fi

echo "[8] Show only useful trace lines"
if [ "$EXPORT_EXIT" -eq 0 ]; then
python3 - <<'PY'
import pandas as pd
from pathlib import Path

code_dir = Path('/Users/guilbaud/git/iris-test/iris-test/src/code')
csv_files = sorted(code_dir.glob('export_event_log_*.csv'), key=lambda p: p.stat().st_mtime, reverse=True)
if not csv_files:
    raise SystemExit('No export_event_log_*.csv found')
latest = csv_files[0]
print(f'Using: {latest.name}')
df = pd.read_csv(latest, sep=';')

relay = df[df['Text'].astype(str).str.contains('ASTM relay', na=False)]
print('\nLast ASTM relay lines:')
if relay.empty:
    print('  (none)')
else:
    cols = ['ID','TimeLogged','MessageId','SessionId','SourceMethod','Text']
    print(relay[cols].tail(15).to_string(index=False))

starts = relay[relay['Text'].astype(str).str.contains('ASTM relay start', na=False)]
if starts.empty:
    raise SystemExit('\nNo "ASTM relay start" line found in latest export.')

sid = str(starts.iloc[-1]['SessionId']).split('.')[0]
session_rows = df[df['SessionId'].astype(str).str.startswith(sid)]
print(f'\nRows for last ASTM session {sid}:')
cols = ['ID','TimeLogged','Type','ConfigName','SourceClass','SourceMethod','Text','StatusValue']
print(session_rows[cols].to_string(index=False))

tcp_rows = df[df['ConfigName'].astype(str).str.contains('de LIS ASTM E1394 - TCP', na=False)]
print('\nRecent TCP service rows:')
cols = ['ID','TimeLogged','Type','ConfigName','MessageId','SessionId','SourceClass','SourceMethod','Text','StatusValue']
print(tcp_rows[cols].tail(20).to_string(index=False))
PY
else
    echo "Skipping trace extraction because event log export failed."
    echo "export_event_log.py stderr:"
    cat export_event_log.err || true
fi

echo "[9] Listener log tail"
docker exec "$CONTAINER" sh -lc 'tail -n 60 /tmp/mllp_listener.log || true'

echo "\nDone. Listener is still running in container PID ${LISTENER_PID}."
if [ "$SEND_EXIT" -ne 0 ]; then
    echo "Note: ASTM sender failed in this run (see [6/9]); diagnostics above were still collected."
fi
