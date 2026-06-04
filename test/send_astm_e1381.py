#!/usr/bin/env python3
"""
Simple ASTM E1381 test client.

Flow:
1) Connect TCP
2) Send ENQ, wait ACK
3) Send one framed ASTM message: STX + frame + ETX + checksum + CRLF
4) Wait frame ACK
5) Send EOT
6) Optionally handle server ENQ and receive application ACK document
"""

import argparse
import socket
from datetime import datetime


ENQ = 0x05
ACK = 0x06
NAK = 0x15
STX = 0x02
ETX = 0x03
EOT = 0x04
CR = 0x0D
LF = 0x0A


def astm_checksum(data: bytes) -> str:
    # IRIS E1238 CHKSUM compatibility:
    # checksum = 8-bit sum modulo 256 (frame number..ETX), rendered as 2 hex chars.
    value = sum(data) % 256
    return f"{value:02X}"


def build_single_frame(astm_payload: str, frame_no: str = "1") -> bytes:
    # Frame body must include frame number as first char.
    body = (frame_no + astm_payload).encode("ascii", errors="ignore")
    chk_data = body + bytes([ETX])
    checksum = astm_checksum(chk_data).encode("ascii")
    return bytes([STX]) + body + bytes([ETX]) + checksum + bytes([CR, LF])


def recv_byte(sock: socket.socket, timeout: float = 5.0) -> int:
    sock.settimeout(timeout)
    b = sock.recv(1)
    if not b:
        raise ConnectionError("Socket closed by remote peer")
    return b[0]


def recv_until_crlf(sock: socket.socket, timeout: float = 5.0) -> bytes:
    sock.settimeout(timeout)
    buf = bytearray()
    while True:
        b = sock.recv(1)
        if not b:
            break
        buf.extend(b)
        if len(buf) >= 2 and buf[-2:] == bytes([CR, LF]):
            break
    return bytes(buf)


def sample_astm_message() -> str:
    ts = datetime.now().strftime("%Y%m%d%H%M%S")
    # Includes a C segment, then an O segment so IRIS can copy C.2 to O.12.
    lines = [
        # Keep ASTM header field positions aligned with repository sample format.
        f"H|\\^&|||Analyzer^SN123||||||P|E1394-97|{ts}",
        "P|1||PAT001||DOE^JOHN",
        "C|1|COMMENT_C2_VALUE",
        "O|1|ORD001||^^^GLU",
        "R|1|^^^GLU|5.4|mmol/L",
        "L|1|N",
    ]
    return "\r".join(lines) + "\r"


def decode_ctl(b: int) -> str:
    names = {
        ENQ: "ENQ",
        ACK: "ACK",
        NAK: "NAK",
        STX: "STX",
        ETX: "ETX",
        EOT: "EOT",
        CR: "CR",
        LF: "LF",
    }
    return names.get(b, f"0x{b:02X}")


def print_enq_handshake_diagnostics(host: str, port: int) -> None:
    print("Connection closed before ENQ ACK.")
    print("Probable causes:")
    print(" - Business Service is stopped or restarting")
    print(" - AllowedIPAddresses rejects your client IP")
    print(" - Host setting mismatch in TCP listener")
    print("Checks to run in IRIS Portal:")
    print(f" - Service de LIS ASTM E1394 - TCP is Running on {host}:{port}")
    print(" - AllowedIPAddresses includes your source IP")
    print(" - Event Log for de LIS ASTM E1394 - TCP around connection time")


def run(host: str, port: int, timeout: float, app_timeout: float, payload: str) -> int:
    print(f"Connecting to {host}:{port}")
    try:
        sock = socket.create_connection((host, port), timeout=timeout)
    except OSError as exc:
        print(f"Connection failed: {exc}")
        return 10

    with sock:
        # Step 1: ENQ -> ACK
        try:
            sock.sendall(bytes([ENQ]))
            b = recv_byte(sock, timeout)
        except (ConnectionError, BrokenPipeError, ConnectionResetError, TimeoutError, OSError) as exc:
            print(f"Handshake error after ENQ: {exc}")
            print_enq_handshake_diagnostics(host, port)
            return 11

        print(f"Received after ENQ: {decode_ctl(b)}")
        if b != ACK:
            print("Expected ACK after ENQ")
            return 1

        # Step 2: send frame
        frame = build_single_frame(payload, frame_no="1")
        sock.sendall(frame)
        b = recv_byte(sock, timeout)
        print(f"Received after data frame: {decode_ctl(b)}")
        if b == NAK:
            print("Server returned NAK, retransmission needed")
            return 2
        if b != ACK:
            print("Expected ACK after data frame")
            return 3

        # Step 3: EOT to close client send phase
        sock.sendall(bytes([EOT]))
        print("Sent EOT")

        # Step 4: optional server app reply phase
        try:
            b = recv_byte(sock, app_timeout)
        except TimeoutError:
            print(f"No application reply phase detected (timeout {app_timeout}s)")
            return 0

        print(f"Received after EOT: {decode_ctl(b)}")
        if b == ENQ:
            # Server wants to send application ACK document.
            sock.sendall(bytes([ACK]))
            reply_frame = recv_until_crlf(sock, app_timeout)
            if reply_frame and reply_frame[0] == STX:
                print("Received application ACK frame")
                print(reply_frame.decode("ascii", errors="ignore"))
                sock.sendall(bytes([ACK]))
                print("Sent ACK for application ACK frame")
            try:
                e = recv_byte(sock, app_timeout)
                print(f"Received after app ACK frame: {decode_ctl(e)}")
            except TimeoutError:
                pass
        else:
            print("Server did not start ENQ app-reply handshake")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Send one ASTM E1381 message over TCP")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=29010)
    parser.add_argument("--timeout", type=float, default=5.0)
    parser.add_argument("--app-timeout", type=float, default=12.0)
    parser.add_argument("--message-file", default="")
    args = parser.parse_args()

    payload = sample_astm_message()
    if args.message_file:
        with open(args.message_file, "r", encoding="ascii", errors="ignore") as f:
            txt = f.read()
        payload = txt.replace("\r\n", "\r").replace("\n", "\r")
        if not payload.endswith("\r"):
            payload += "\r"

    return run(args.host, args.port, args.timeout, args.app_timeout, payload)


if __name__ == "__main__":
    raise SystemExit(main())
