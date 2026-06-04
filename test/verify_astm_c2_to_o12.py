#!/usr/bin/env python3
"""
Verify ASTM transformation rule: C.2 -> O.12.

Behavior:
- Reads the newest ASTM output file (or a provided file)
- Tracks latest C.2 value
- Verifies each following O.12 equals latest C.2
- Exits with code 0 on success, non-zero on failure
"""

import argparse
import glob
import os
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Verify ASTM C.2 -> O.12 mapping")
    parser.add_argument(
        "--dir",
        default="/Users/guilbaud/git/iris-test/data/ASTM-E1394/out",
        help="Directory containing transformed ASTM files",
    )
    parser.add_argument(
        "--pattern",
        default="ASTM_E1394_*.ast",
        help="Filename pattern used to select output files",
    )
    parser.add_argument(
        "--file",
        default="",
        help="Specific ASTM file to verify (overrides --dir/--pattern)",
    )
    return parser.parse_args()


def find_latest_file(folder: str, pattern: str) -> str:
    files = glob.glob(os.path.join(folder, pattern))
    if not files:
        return ""
    files.sort(key=os.path.getmtime, reverse=True)
    return files[0]


def normalize_lines(text: str) -> list[str]:
    return [ln for ln in text.replace("\r\n", "\r").replace("\n", "\r").split("\r") if ln]


def verify_c2_to_o12(lines: list[str]) -> tuple[bool, list[str]]:
    errors: list[str] = []
    latest_c2 = ""
    o_count = 0

    for idx, line in enumerate(lines, start=1):
        fields = line.split("|")
        if not fields:
            continue

        rec = fields[0]
        if rec == "C":
            latest_c2 = fields[2] if len(fields) > 2 else ""
        elif rec == "O":
            o_count += 1
            o12 = fields[12] if len(fields) > 12 else ""
            if latest_c2 and o12 != latest_c2:
                errors.append(
                    f"Line {idx}: expected O.12='{latest_c2}' from latest C.2 but got '{o12}'"
                )

    if o_count == 0:
        errors.append("No O record found in message")

    return len(errors) == 0, errors


def main() -> int:
    args = parse_args()
    target_file = args.file or find_latest_file(args.dir, args.pattern)

    if not target_file:
        print("ERROR: no ASTM output file found")
        return 2

    if not os.path.exists(target_file):
        print(f"ERROR: file not found: {target_file}")
        return 2

    with open(target_file, "r", encoding="ascii", errors="ignore") as f:
        content = f.read()

    lines = normalize_lines(content)
    ok, errors = verify_c2_to_o12(lines)

    print(f"Checked file: {target_file}")
    if ok:
        print("OK: C.2 -> O.12 mapping is valid")
        return 0

    print("FAILED: mapping check found issues")
    for err in errors:
        print(f" - {err}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
