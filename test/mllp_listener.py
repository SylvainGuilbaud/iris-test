#!/usr/bin/env python3
"""
Minimal MLLP listener for local testing.

Receives MLLP-framed payloads:
  VT (0x0B) ... FS (0x1C) CR (0x0D)

Use this to validate IRIS outbound MLLP without Mirth.
"""

import argparse
import os
import socket
from datetime import datetime


VT = b"\x0b"
FS = b"\x1c"
CR = b"\x0d"
END = FS + CR


def nowstamp() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def astm_ts() -> str:
    return datetime.now().strftime("%Y%m%d%H%M%S")


def build_mllp_ack_payload() -> bytes:
    # Minimal ASTM-style application ACK payload.
    ack = (
        f"H|\\^&|||PY-MLLP-LISTENER|||||||P|E1394-97|{astm_ts()}\r"
        "L|1|N\r"
    )
    return ack.encode("ascii", errors="ignore")


def recv_mllp_message(conn: socket.socket, timeout: float) -> bytes:
    conn.settimeout(timeout)
    buf = bytearray()

    # Wait for start block
    while True:
        b = conn.recv(1)
        if not b:
            return b""
        if b == VT:
            break

    # Read until end block
    while True:
        b = conn.recv(1)
        if not b:
            raise ConnectionError("Connection closed before MLLP end block")
        buf.extend(b)
        if len(buf) >= 2 and bytes(buf[-2:]) == END:
            return bytes(buf[:-2])


def write_payload(out_dir: str, payload: bytes) -> str:
    os.makedirs(out_dir, exist_ok=True)
    ts = datetime.now().strftime("%Y-%m-%d-%H-%M-%S-%f")
    path = os.path.join(out_dir, f"mllp_recv_{ts}.ast")
    with open(path, "wb") as f:
        f.write(payload)
    return path


def run_listener(host: str, port: int, timeout: float, out_dir: str, send_ack: bool) -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as srv:
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((host, port))
        srv.listen(5)
        print(f"[{nowstamp()}] MLLP listener ready on {host}:{port}")
        print(f"[{nowstamp()}] Saving payloads to {out_dir}")

        while True:
            conn, addr = srv.accept()
            with conn:
                peer = f"{addr[0]}:{addr[1]}"
                print(f"[{nowstamp()}] Connection from {peer}")
                try:
                    payload = recv_mllp_message(conn, timeout)
                    if not payload:
                        print(f"[{nowstamp()}] Empty/closed connection from {peer}")
                        continue

                    if send_ack:
                        ack_payload = build_mllp_ack_payload()
                        conn.sendall(VT + ack_payload + END)
                        print(f"[{nowstamp()}] Sent MLLP ACK to {peer}")

                    out_file = write_payload(out_dir, payload)
                    txt = payload.decode("ascii", errors="ignore")
                    first_line = txt.split("\r")[0] if txt else ""
                    print(f"[{nowstamp()}] Received {len(payload)} bytes from {peer}")
                    print(f"[{nowstamp()}] First line: {first_line}")
                    print(f"[{nowstamp()}] Saved: {out_file}")
                except Exception as exc:
                    print(f"[{nowstamp()}] Error with {peer}: {exc}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Local MLLP listener for ASTM payloads")
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=6662)
    parser.add_argument("--timeout", type=float, default=15.0)
    default_out_dir = "/data/ASTM-E1394/mllp-in" if os.path.isdir("/data") else "/Users/guilbaud/git/iris-test/data/ASTM-E1394/mllp-in"
    parser.add_argument("--out-dir", default=default_out_dir)
    parser.add_argument("--send-ack", action="store_true", default=False)
    parser.add_argument("--no-send-ack", action="store_false", dest="send_ack")
    args = parser.parse_args()

    return run_listener(args.host, args.port, args.timeout, args.out_dir, args.send_ack)


if __name__ == "__main__":
    raise SystemExit(main())
