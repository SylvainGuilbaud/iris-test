#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Testeur du flux GAM -> IRIS -> LAB de la production IRISAPP.prod.test.

Envoie un ou plusieurs ADT^A28 en MLLP sur le Business Service
"de GAM ADT^A28 - TCP" (port 29020) et affiche l'ACK applicatif renvoye.

Cas d'usage illustre (StayConnected + ReplyCodeActions) :
  - le LAB (ici le simulateur "Lab simulateur (AR) - TCP") repond AR ;
  - l'operation "vers Lab HL7 - TCP" traite AR en Completed OK (pas de retry
    infini, pas de reconstruction CE) et journalise/alerte via OnReplyDocument ;
  - GAM recoit un ACK applicatif (AckMode=App).

Usage :
  python3 send_lab.py                 # 1 message sur localhost:29020
  python3 send_lab.py -n 5            # 5 messages
  python3 send_lab.py --host 1.2.3.4 --port 29020
"""

import argparse
import socket
import sys
from datetime import datetime

# Framing MLLP : <VT> message <FS><CR>
VT, FS, CR = b"\x0b", b"\x1c", b"\x0d"


def build_adt_a28(control_id: str) -> str:
    """Construit un ADT^A28 (nouveau patient) HL7 v2.5 minimal."""
    now = datetime.now().strftime("%Y%m%d%H%M%S")
    segments = [
        f"MSH|^~\\&|GAM|IHE|IRIS|TD|{now}||ADT^A28^ADT_A05|{control_id}|P|2.5",
        f"EVN|A28|{now}",
        "PID|1||1^^^GAM^PI||DOE^JOHN||19800101|M",
        "PV1|1|N",
    ]
    return "\r".join(segments)


def send_mllp(host: str, port: int, message: str, timeout: float = 25.0) -> str:
    """Envoie un message MLLP et retourne l'ACK decode (segments separes par \\n)."""
    frame = VT + message.encode("utf-8") + FS + CR
    with socket.create_connection((host, port), timeout=timeout) as sock:
        sock.sendall(frame)
        sock.settimeout(timeout)
        buf = b""
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            buf += chunk
            if FS in buf:
                break
    ack = buf.replace(VT, b"").replace(FS, b"").replace(CR, b"\n")
    return ack.decode("utf-8", errors="replace").strip()


def main() -> int:
    parser = argparse.ArgumentParser(description="Testeur du flux GAM -> LAB (MLLP)")
    parser.add_argument("--host", default="localhost", help="hote du service (defaut: localhost)")
    parser.add_argument("--port", type=int, default=29020, help="port MLLP (defaut: 29020)")
    parser.add_argument("-n", "--count", type=int, default=1, help="nombre de messages (defaut: 1)")
    args = parser.parse_args()

    ok = 0
    for i in range(1, args.count + 1):
        control_id = f"LAB{datetime.now().strftime('%H%M%S')}{i:03d}"
        message = build_adt_a28(control_id)
        print(f"\n--- Envoi {i}/{args.count} (ControlId={control_id}) vers {args.host}:{args.port} ---")
        try:
            ack = send_mllp(args.host, args.port, message)
        except (socket.timeout, OSError) as exc:
            print(f"ECHEC: {exc}")
            continue
        if not ack:
            print("Aucun ACK recu (vide)")
            continue
        ok += 1
        print("ACK recu :")
        print(ack)
        msa = next((line for line in ack.split("\n") if line.startswith("MSA")), "")
        code = msa.split("|")[1] if "|" in msa else "?"
        print(f"=> MSA-1 = {code}  ({'accepte' if code in ('AA', 'CA') else code})")

    print(f"\nTermine : {ok}/{args.count} ACK recus.")
    print("Trace du rejet AR cote operation :")
    print("  docker exec -i iris-test iris session iris -U IRISAPP <<'EOF'")
    print("  SuperUser")
    print("  SYS")
    print("  set rs=##class(%SQL.Statement).%ExecDirect(,\"SELECT TOP 3 Type,$EXTRACT(Text,1,200) T FROM Ens_Util.Log WHERE ConfigName='vers Lab HL7 - TCP' ORDER BY ID DESC\") while rs.%Next() { write \"[T\",rs.Type,\"] \",rs.T,! }")
    print("  halt")
    print("  EOF")
    return 0 if ok == args.count else 1


if __name__ == "__main__":
    sys.exit(main())
