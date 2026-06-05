# ASTM E1381/E1394 sur TCP vers Fichier + MLLP

Ce dossier contient une mise en place de flux ASTM TCP avec:

- reception ASTM E1381 (LLP) sur socket TCP
- parsing ASTM E1394 (records H/P/O/R/C/L)
- transformation C.2 vers O.12
- ecriture du message transforme dans un fichier
- emission du message transforme en MLLP vers un autre endpoint (ex: Mirth)
- retour d'un ACK applicatif sur la connexion ASTM initiale

## Composants ajoutes

- Business Operation: `IRISAPP.operation.ASTMRelayWithAck`
- Items de production (desactives par defaut) dans `IRISAPP.prod.test`:
	- `de LIS ASTM E1394 - TCP` (`EnsLib.EDI.ASTM.Service.TCPService`)
	- `Relay ASTM vers fichier+MLLP` (`IRISAPP.operation.ASTMRelayWithAck`)

## Configuration

1. Compiler les classes de `IRISAPP`.
2. Ouvrir la production `IRISAPP.prod.test`.
3. Verifier les reglages de `Relay ASTM vers fichier+MLLP`:
	 - `OutputPath`: dossier de sortie local (defaut `/data/ASTM-E1394/out/`)
	 - `SendToMLLP`: `1` pour activer la sortie MLLP
	 - `MLLPHost`: host du Mirth (defaut `host.docker.internal`)
	- `MLLPPort`: port MLLP (defaut `6662`)
	 - `FailOnMLLPError`: `0` (defaut) pour renvoyer quand meme un ACK applicatif ASTM si le MLLP echoue
4. Activer les 2 items:
	 - `de LIS ASTM E1394 - TCP`
	 - `Relay ASTM vers fichier+MLLP`

## Notes importantes

- Le low-level E1381 (ENQ/ACK, STX/ETX/LRC, retries/timeouts) est gere par `EnsLib.EDI.ASTM.Service.TCPService`.
- `IRISAPP.operation.ASTMRelayWithAck` est en `INVOCATION="InProc"` pour permettre un ACK applicatif immediat sur la meme connexion TCP.
- La transformation implementee est simple et lineaire:
	- memorise la derniere valeur `C.2`
	- injecte cette valeur dans chaque `O.12` suivant
- Le payload envoye en MLLP est encadre par `VT` (`0x0B`) et `FS+CR` (`0x1C0D`).

## Test bout en bout

1. Compiler la classe operation:

	- `IRISAPP.operation.ASTMRelayWithAck`

2. Dans la production `IRISAPP.prod.test`, activer:

	- `de LIS ASTM E1394 - TCP`
	- `Relay ASTM vers fichier+MLLP`

3. Sur Mirth (ou un listener MLLP), demarrer un channel MLLP en ecoute sur le port configure (defaut `6662`).

4. Depuis le host, envoyer un message ASTM E1381 de test:

```bash
cd /Users/guilbaud/git/iris-test
python3 test/send_astm_e1381.py --host 127.0.0.1 --port 29010
```

	Si la phase de reponse applicative est lente (ex: timeout MLLP), augmenter le delai d'attente:

```bash
python3 test/send_astm_e1381.py --host 127.0.0.1 --port 29010 --app-timeout 15
```

5. Verifier les resultats:

	- Le script doit afficher `ACK` apres `ENQ` puis apres la trame.
	- Un fichier `ASTM_E1394_*.ast` doit etre cree dans `/data/ASTM-E1394/out/` (dans le conteneur, monte sur `data/ASTM-E1394/out/` cote host).
	- Dans le fichier de sortie, verifier que la valeur de `C.2` est bien copiee dans `O.12`.
	- Dans Mirth, verifier la reception du message MLLP correspondant.

	Verification automatique de la regle C.2 -> O.12:

```bash
cd /Users/guilbaud/git/iris-test
python3 test/verify_astm_c2_to_o12.py
```

	Avec un fichier precis:

```bash
python3 test/verify_astm_c2_to_o12.py --file /Users/guilbaud/git/iris-test/data/ASTM-E1394/out/ASTM_E1394_XXXX.ast
```

	Codes retour:

	- `0`: verification OK
	- `1`: ecart detecte
	- `2`: fichier introuvable/non disponible

6. Cas de test negatif (optionnel):

	- Arreter temporairement le listener MLLP.
	- Rejouer le script.
	- Le message doit etre ecrit en fichier mais le traitement doit remonter une erreur de connexion MLLP cote IRIS.

## Listener Python (sans Mirth)

Si Mirth n'est pas disponible, utiliser le listener local:

1. Demarrer le listener sur le host:

```bash
cd /Users/guilbaud/git/iris-test/test
python3 mllp_listener.py --host 0.0.0.0 --port 6662
```

Par defaut, le listener ne renvoie pas d'ACK (mode fire-and-forget).

Pour activer l'ACK:

```bash
python3 mllp_listener.py --host 0.0.0.0 --port 6662 --send-ack
```

Pour desactiver l'ACK:

```bash
python3 mllp_listener.py --host 0.0.0.0 --port 6662 --no-send-ack
```

2. Dans l'operation `Relay ASTM vers fichier+MLLP`, regler:

	- `SendToMLLP=1`
	- `MLLPHost=host.docker.internal` si le listener tourne sur le host
	- `MLLPHost=127.0.0.1` si le listener tourne dans le conteneur `iris-test`
	- `MLLPPort=6662`
	- `WaitForMLLPAck=1` si le listener renvoie un ACK MLLP, sinon mettre `0` pour un envoi fire-and-forget

3. Rejouer un envoi ASTM E1381.

4. Verifier les payloads recus:

	- Dossier de sortie listener: `/Users/guilbaud/git/iris-test/data/ASTM-E1394/mllp-in`
	- Le listener affiche la premiere ligne recue et le fichier ecrit.


