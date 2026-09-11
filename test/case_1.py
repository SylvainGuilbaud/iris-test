#!/usr/bin/env python3
"""Case 1 - client disconnect should not be treated as a fatal service error.

This script simulates a PAS that opens a connection, sends an unsolicited ADT^A28,
then disconnects immediately before waiting for an ACK. The point is to confirm
that the service stays available for the next message and does not report a fatal
error on a normal client-initiated disconnect.
"""

import argparse
import socket
import time
from datetime import datetime

VT = b"\x0b"
FS = b"\x1c"
CR = b"\x0d"


def build_adt_a28(control_id: str) -> str:
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    return "\r".join([
        f"MSH|^~\\&|PAS|HOSPITAL|IRIS|LAB|{now}||ADT^A28^ADT_A05|{control_id}|P|2.5",
        f"EVN|A28|{now}",
        "PID|1||123456789^^^PAS^MR||DOE^JOHN||19800101|M",
        "PV1|1|N",
    ])


def send_then_close(host: str, port: int, message: str, timeout: float = 12.0) -> str:
    frame = VT + message.encode("utf-8") + FS + CR
    with socket.create_connection((host, port), timeout=timeout) as sock:
        sock.sendall(frame)
        sock.shutdown(socket.SHUT_RDWR)
        print(f"[case 1] client disconnected intentionally after sending {message.split('|')[-1]}")
        return "disconnect-sent"


def send_and_wait(host: str, port: int, message: str, timeout: float = 12.0) -> str:
    frame = VT + message.encode("utf-8") + FS + CR
    with socket.create_connection((host, port), timeout=timeout) as sock:
        sock.sendall(frame)
        sock.settimeout(timeout)
        response = b""
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            response += chunk
            if FS in response:
                break
    ack = response.replace(VT, b"").replace(FS, b"").replace(CR, b"\n")
    return ack.decode("utf-8", errors="replace").strip()


def send_follow_up_with_retry(host: str, port: int, message: str, attempts: int = 5) -> str:
    for attempt in range(1, attempts + 1):
        try:
            ack = send_and_wait(host, port, message)
            if ack:
                return ack
        except (OSError, socket.timeout) as exc:
            if attempt == attempts:
                raise exc
        if attempt < attempts:
            print(f"No ACK yet; retrying follow-up connection ({attempt + 1}/{attempts}) ...")
            time.sleep(1)
    return ""


def main() -> int:
    parser = argparse.ArgumentParser(description="Case 1: client disconnect resilience")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=29101)
    parser.add_argument("--count", type=int, default=3, help="normal messages after the disconnect")
    args = parser.parse_args()

    print(f"Connecting to {args.host}:{args.port} ...")
    disconnect_id = f"case-1-disconnect-{datetime.now().strftime('%H%M%S')}"
    try:
        send_then_close(args.host, args.port, build_adt_a28(disconnect_id))
    except (OSError, socket.timeout) as exc:
        print(f"Disconnect simulation failure: {exc}")
        return 1

    successful = 0
    for i in range(1, args.count + 1):
        control_id = f"case-1-follow-up-{datetime.now().strftime('%H%M%S')}-{i:02d}"
        print(f"\n--- follow-up message {i}/{args.count} ---")
        try:
            ack = send_follow_up_with_retry(args.host, args.port, build_adt_a28(control_id))
        except (OSError, socket.timeout) as exc:
            print(f"Transport failure: {exc}")
            return 1
        if not ack:
            print("No ACK received")
            return 1
        successful += 1
        print("ACK received:")
        print(ack)

    print(f"\nResult: disconnect simulated; {successful}/{args.count} follow-up messages received ACKs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
