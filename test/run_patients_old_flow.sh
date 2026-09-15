#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="${PATIENTS_OLD_FLOW_LOG_DIR:-$ROOT_DIR/test/logs}"
COUNT="${PATIENTS_OLD_FLOW_COUNT:-3}"
LOG_FILE="${PATIENTS_OLD_FLOW_LOG_FILE:-$LOG_DIR/patients_old_flow_$(date '+%Y%m%d_%H%M%S').log}"
LISTENER_PID=""
LISTENER_PID_FILE="/tmp/patients_old_flow.listener.pid"

mkdir -p "$LOG_DIR"
log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

cleanup() {
    if [ -n "$LISTENER_PID" ]; then
        kill "$LISTENER_PID" 2>/dev/null || true
        wait "$LISTENER_PID" 2>/dev/null || true
    fi
    stop_listener
}
trap cleanup EXIT

stop_listener() {
    docker exec iris-test sh -c "
        if [ -r '$LISTENER_PID_FILE' ]; then
            pid=\$(cat '$LISTENER_PID_FILE')
            if ps -p \"\$pid\" -o args= 2>/dev/null | grep -q '[p]atients_old_flow.py.*--listen'; then
                kill \"\$pid\" 2>/dev/null || true
            fi
            rm -f '$LISTENER_PID_FILE'
        fi
        for pid in \$(ps -eo pid=,args= | awk '\$0 !~ /awk/ && \$0 ~ /python3 \/test\/patients_old_flow.py.*--listen/ {print \$1}'); do
            kill \"\$pid\" 2>/dev/null || true
        done
    " 2>/dev/null || true
}

log "Stopping any previous downstream listener"
stop_listener
sleep 1

log "Patients old flow test started"
log "Log file: $LOG_FILE"
log "Listener log: $LOG_FILE.listener"
log "Starting downstream listener in iris-test on port 8011"
docker exec iris-test sh -c "echo \$\$ > '$LISTENER_PID_FILE'; exec python3 /test/patients_old_flow.py --listen --keep-alive --host 0.0.0.0 --port 8011 --count '$COUNT' --timeout 30" >"$LOG_FILE.listener" 2>&1 &
LISTENER_PID=$!

for _ in $(seq 1 30); do
    if grep -q 'LISTENER_READY' "$LOG_FILE.listener"; then
        break
    fi
    if ! kill -0 "$LISTENER_PID" 2>/dev/null; then
        log "Downstream listener failed to start"
        tee -a "$LOG_FILE" <"$LOG_FILE.listener"
        exit 1
    fi
    sleep 1
done

if ! grep -q 'LISTENER_READY' "$LOG_FILE.listener"; then
    log "Timed out waiting for downstream listener"
    tee -a "$LOG_FILE" <"$LOG_FILE.listener"
    exit 1
fi

log "Sending ${COUNT} message(s) to PAS service on port 8010"
if python3 "$ROOT_DIR/test/patients_old_flow.py" --host localhost --port 8010 --count "$COUNT" 2>&1 | tee -a "$LOG_FILE"; then
    sender_result=0
else
    sender_result=$?
fi

if kill -0 "$LISTENER_PID" 2>/dev/null; then
    listener_result=0
else
    wait "$LISTENER_PID" 2>/dev/null || listener_result=$?
    listener_result="${listener_result:-1}"
fi
tee -a "$LOG_FILE" <"$LOG_FILE.listener"

if [ "$sender_result" -eq 0 ] && [ "$listener_result" -eq 0 ]; then
    log "RESULT PASS sender=${sender_result} listener=${listener_result}"
    log "FINAL PASS PAS -> PatientsIn_1Svc_HL7ADT_MLLP_PASOld -> PatientsIn_2Op_HL7ADT_MLLP_DGLabOld"
    exit 0
fi

log "FINAL FAIL sender=${sender_result} listener=${listener_result}"
exit 1