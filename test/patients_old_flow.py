#!/usr/bin/env python3
"""Exercise the legacy PAS -> IRIS -> DGLab HL7/MLLP flow."""

import argparse
import socket
import sys
from datetime import datetime


VT = b"\x0b"
FS = b"\x1c"
CR = b"\x0d"
END = FS + CR


def build_adt(control_id: str) -> str:
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    return "\r".join([
        f"MSH|^~\\&|PAS|HOSPITAL|IRIS|DGLAB|{timestamp}||ADT^A01|{control_id}|P|2.3",
        f"EVN|A01|{timestamp}",
        "PID|1||OLD-FLOW-001^^^PAS^MR||DOE^JANE||19800415|F",
        "PV1|1|I|MED^101^1",
    ])


def read_frame(conn: socket.socket, timeout: float) -> bytes:
    conn.settimeout(timeout)
    data = bytearray()
    while True:
        byte = conn.recv(1)
        if not byte:
            raise ConnectionError("connection closed before MLLP start")
        if byte == VT:
            break
    while True:
        byte = conn.recv(1)
        if not byte:
            raise ConnectionError("connection closed before MLLP end")
        data.extend(byte)
        if data.endswith(END):
            return bytes(data[:-2])


def send_ack(conn: socket.socket, payload: bytes) -> None:
    fields = payload.decode("ascii", errors="replace").split("\r", 1)[0].split("|")
    control_id = fields[9] if len(fields) > 9 else ""
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    ack = "\r".join([
        f"MSH|^~\\&|DGLAB|LAB|IRIS|PAS|{timestamp}||ACK|ACK-{control_id}|P|2.3",
        f"MSA|AA|{control_id}",
    ]).encode("ascii")
    conn.sendall(VT + ack + END)


def listen(host: str, port: int, count: int, timeout: float, keep_alive: bool) -> int:
    received = 0
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind((host, port))
        server.listen(5)
        print(f"LISTENER_READY {host}:{port}", flush=True)
        server.settimeout(timeout)
        while received < count:
            try:
                conn, address = server.accept()
            except socket.timeout:
                print(f"Listener timed out after {received}/{count} messages", file=sys.stderr)
                return 1
            with conn:
                while received < count:
                    try:
                        frame_timeout = timeout if received == 0 else min(timeout, 1.0)
                        payload = read_frame(conn, frame_timeout)
                    except (ConnectionError, socket.timeout):
                        break
                    send_ack(conn, payload)
                    received += 1
                    first_line = payload.decode("ascii", errors="replace").split("\r", 1)[0]
                    print(f"FORWARDED {received}/{count} {address[0]} {first_line}", flush=True)
        print(f"DOWNSTREAM_PASS {received}/{count}", flush=True)
        if keep_alive:
            server.settimeout(None)
            while True:
                conn, address = server.accept()
                with conn:
                    while True:
                        try:
                            payload = read_frame(conn, timeout)
                        except (ConnectionError, socket.timeout):
                            break
                        send_ack(conn, payload)
                        first_line = payload.decode("ascii", errors="replace").split("\r", 1)[0]
                        print(f"FORWARDED_KEEPALIVE {address[0]} {first_line}", flush=True)
    return 0


def send(host: str, port: int, count: int, timeout: float) -> int:
    for number in range(1, count + 1):
        control_id = f"OLD-FLOW-{datetime.now().strftime('%H%M%S')}-{number:03d}"
        payload = build_adt(control_id).encode("ascii")
        frame = VT + payload + END
        try:
            with socket.create_connection((host, port), timeout=timeout) as conn:
                conn.sendall(frame)
                response = read_frame(conn, timeout)
        except (OSError, socket.timeout, ConnectionError) as exc:
            print(f"SEND_FAIL {control_id}: {exc}", file=sys.stderr)
            return 1

        ack = response.decode("ascii", errors="replace")
        msa = next((line for line in ack.split("\r") if line.startswith("MSA|")), "")
        ack_code = msa.split("|")[1] if len(msa.split("|")) > 1 else ""
        if ack_code not in ("AA", "CA") or control_id not in msa:
            print(f"SEND_FAIL {control_id}: unexpected ACK {ack!r}", file=sys.stderr)
            return 1
        print(f"INBOUND_ACK {number}/{count} {control_id} MSA-1={ack_code}")
    print(f"INBOUND_PASS {count}/{count}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Test PAS -> DGLab legacy HL7 flow")
    parser.add_argument("--listen", action="store_true", help="run as the downstream DGLab listener")
    parser.add_argument("--keep-alive", action="store_true", help="keep the downstream listener alive after the expected messages")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=8010)
    parser.add_argument("--count", type=int, default=1)
    parser.add_argument("--timeout", type=float, default=30.0)
    args = parser.parse_args()
    if args.listen:
        return listen(args.host, args.port, args.count, args.timeout, args.keep_alive)
    return send(args.host, args.port, args.count, args.timeout)


if __name__ == "__main__":
    raise SystemExit(main())