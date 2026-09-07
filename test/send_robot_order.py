#!/usr/bin/env python3
"""Run working and failing ORM^O01 scenarios through the robot demo flow."""

import argparse
import socket
from datetime import datetime

VT, FS, CR = b"\x0b", b"\x1c", b"\x0d"


def build_order(control_id: str, dose: str, include_rxe: bool = True, medication: str = "FLUOROURACIL") -> str:
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    segments = [
        f"MSH|^~\\&|PRESCRIPTION|HOSPITAL|IRIS|DEMO|{now}||ORM^O01^ORM_O01|{control_id}|P|2.5",
        f"PID|1||PATIENT01^^^HOSPITAL^MR||DOE^JOHN||19800101|M",
        f"ORC|NW|{control_id}||||||||{now}",
    ]
    if include_rxe:
        segments.append(f"RXE|{medication}|{dose}|mg|IV")
    return "\r".join(segments)


def send(host: str, port: int, message: str) -> str:
    with socket.create_connection((host, port), timeout=20) as sock:
        sock.sendall(VT + message.encode() + FS + CR)
        sock.settimeout(20)
        response = b""
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            response += chunk
            if FS in response:
                break
    return response.replace(VT, b"").replace(FS, b"").replace(CR, b"\n").decode(errors="replace").strip()


def get_msa_code(ack: str) -> str:
    msa = next((line for line in ack.split("\n") if line.startswith("MSA|")), "")
    fields = msa.split("|")
    return fields[1] if len(fields) > 1 else "?"


def main() -> int:
    parser = argparse.ArgumentParser(description="Test des scenarios prescription -> robot")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=29030)
    parser.add_argument(
        "--scenario",
        choices=("all", "working", "failing"),
        default="all",
        help="scenarios a executer (defaut: all)",
    )
    args = parser.parse_args()

    cases = [
        {
            "id": "ORDER-OK-500MG",
            "label": "Working: standard fluorouracil order",
            "dose": "500",
            "include_rxe": True,
            "expected": "accepted",
        },
        {
            "id": "ORDER-OK-1000MG",
            "label": "Working: high-dose order",
            "dose": "1000",
            "include_rxe": True,
            "expected": "accepted",
        },
        {
            "id": "ORDER-MISSING-DOSE",
            "label": "Failing: RXE present but dose missing",
            "dose": "",
            "include_rxe": True,
            "expected": "rejected",
        },
        {
            "id": "ORDER-MISSING-RXE",
            "label": "Failing: medication segment missing",
            "dose": "",
            "include_rxe": False,
            "expected": "rejected",
        },
    ]
    selected = [
        case for case in cases
        if args.scenario == "all"
        or (args.scenario == "working" and case["expected"] == "accepted")
        or (args.scenario == "failing" and case["expected"] == "rejected")
    ]

    passed = 0
    for case in selected:
        print(f"\n--- {case['label']} [{case['id']}] ---")
        try:
            ack = send(
                args.host,
                args.port,
                build_order(case["id"], case["dose"], case["include_rxe"]),
            )
        except (OSError, socket.timeout) as exc:
            print(f"Transport failure: {exc}")
            continue

        msa_code = get_msa_code(ack)
        print(ack or "No ACK received")
        print(f"Business expectation: {case['expected']}")
        print(f"Technical MSA-1: {msa_code}")
        if msa_code == "AA":
            print("The production completed the synchronous exchange; inspect the operation log for the business warning.")
        passed += 1

    print(f"\nScenarios completed: {passed}/{len(selected)}")
    print("Visual Trace path: de prescription ORM - TCP -> routeur robot -> robot de preparation")
    return 0 if passed == len(selected) else 1


if __name__ == "__main__":
    raise SystemExit(main())
