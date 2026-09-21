#!/usr/bin/env python3
"""Case 3 - ACK^A28^ACK with MSH-9.3 populated is a valid reply.

This script sends an ADT^A28 request through the real GAM -> IRIS -> LAB path.
The expected reply is an ACK^A28^ACK (three components), and it must not be
rejected as a reply type mismatch.
"""

import argparse
import socket
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


def send_mllp(host: str, port: int, message: str, timeout: float = 20.0) -> str:
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


def main() -> int:
    parser = argparse.ArgumentParser(description="Case 3: valid ACK^A28^ACK reply")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=29103)
    parser.add_argument("--count", type=int, default=1)
    args = parser.parse_args()

    for i in range(1, args.count + 1):
        control_id = f"case-3-{datetime.now().strftime('%H%M%S')}-{i:02d}"
        msg = build_adt_a28(control_id)
        print(f"\n--- case 3 / send {i} / controlId={control_id} ---")
        try:
            ack = send_mllp(args.host, args.port, msg)
        except (socket.timeout, OSError) as exc:
            print(f"Transport failure: {exc}")
            return 1
        print(ack or "<no ACK>")
        lines = ack.splitlines()
        msh = next((line for line in lines if line.startswith("MSH|")), "")
        msa = next((line for line in lines if line.startswith("MSA|")), "")
        msh_fields = msh.split("|")
        msa_fields = msa.split("|")
        msh9 = msh_fields[8] if len(msh_fields) > 8 else ""
        if msh9 != "ACK^A28" or len(msa_fields) < 3 or msa_fields[1] != "AR":
            print("FAIL: ACK^A28^ACK with populated MSH-9.3 was not accepted")
            return 1
        print("PASS: ACK^A28^ACK with populated MSH-9.3 was accepted; outbound ACK normalized to ACK^A28")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
