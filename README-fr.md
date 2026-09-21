# IRIS Test

Ce projet sert de tests sur InterSystems IRIS®.

## Pré-requis

- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-with-Git)
- [Visual Studio Code et extensions InterSystems](https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=GVSCO)
- [Python](https://www.python.org/downloads/)
- [Compte Developer Community](https://community.intersystems.com/)
- [Accès au dépôt Containers InterSystems](https://containers.intersystems.com/contents)

## Installation

1. Cloner ce dépôt :

```bash
git clone https://github.com/SylvainGuilbaud/iris-test
```

2. Aller dans le répertoire du dépôt :

```bash
cd iris-test
```

3. Démarrer les services :

```bash
./start.sh
```

4. Attendre le démarrage des services, puis vérifier que les conteneurs sont en état `healthy` :

```bash
docker-compose ps
```

5. Se connecter au portail de gestion IRIS : http://localhost:10773/csp/sys/%25CSP.Portal.Home.zen

Identifiants :

- Nom d'utilisateur : `_SYSTEM`
- Mot de passe : `SYS`

## Cas d'usage d'interopérabilité

La production `IRISAPP.prod.test` contient deux flux de démonstration supplémentaires.

### 1. Flux GAM - LAB : ACK, AR et AA

Ce flux reproduit un échange HL7 synchrone entre un système GAM et un LAB :

```text
GAM
  -> de GAM ADT^A28 - TCP (port 29020)
  -> routeur Lab
  -> vers Lab HL7 - TCP
  -> Lab simulateur (AR)
```

Le simulateur LAB renvoie un ACK négatif `AR`. L'opération traite ce rejet avec :

```text
ReplyCodeActions = :?R=C,:?E=F,:~=F,:?A=C,:*=F,:I?=W,:T?=C
StayConnected = 30
NoFailWhileDisconnected = 1
```

Le rejet est journalisé sans retry infini ni erreur technique bloquante. Le service entrant utilise `AckMode=App` et GAM reçoit un ACK applicatif `AA` lorsque l'échange synchrone est terminé.

Tester depuis la machine hôte :

```bash
python3 test/send_lab.py
python3 test/send_lab.py -n 3
```

Le Visual Trace est visible dans le portail IRIS :

```text
Interoperability -> View -> Message Viewer -> Visual Trace
```

Captures d'écran du flux :

- [Trace ACK AA](docs/flux%20GAM%20ACK%20AR/traceACK=AA.jpg)
- [Trace ACK AR](docs/flux%20GAM%20ACK%20AR/traceACK=AR.jpg)
- [Message ADT^A28 initial](docs/flux%20GAM%20ACK%20AR/traceMessageADT_A28_init.jpg)

### 2. Flux prescription - robot de préparation

Ce flux montre la réception d'un ordre HL7 `ORM^O01`, son routage vers un robot simulé et la gestion de scénarios nominaux ou invalides :

```text
Prescription
  -> de prescription ORM - TCP (port 29030)
  -> routeur robot
  -> robot de préparation
```

Le test contient quatre scénarios :

- `ORDER-OK-500MG` : ordre accepté avec une dose de 500 mg ;
- `ORDER-OK-1000MG` : ordre accepté avec une dose de 1000 mg ;
- `ORDER-MISSING-DOSE` : rejet métier car la dose est absente ;
- `ORDER-MISSING-RXE` : message invalide car le segment RXE est absent.

Lancer tous les scénarios :

```bash
python3 test/send_robot_order.py
```

Lancer uniquement les scénarios nominaux ou en erreur :

```bash
python3 test/send_robot_order.py --scenario working
python3 test/send_robot_order.py --scenario failing
```

Le script affiche l'ACK MLLP reçu et le code `MSA-1`. Le scénario nominal retourne `AA`. Le scénario sans segment RXE retourne `AE` ; le scénario sans dose est journalisé comme rejet métier dans l'opération `robot de préparation`. Le détail est consultable dans le Visual Trace et dans les logs de production.

### 3. Flux des tickets WRC

La production contient également trois flux techniques. Chaque service reçoit un message HL7 `ADT^A28` en MLLP :

```text
Cas 1 : case 1 service - TCP (port 29101) -> case 1 router -> case 1 operation
Cas 2 : case 2 service - TCP (port 29102) -> vers Lab HL7 - TCP -> Lab simulateur (AR)
Cas 3 : case 3 service - TCP (port 29103) -> vers Lab HL7 - TCP -> Lab simulateur (AR)
```

Lancer un test direct :

```bash
python3 test/case_1.py
python3 test/case_2.py
python3 test/case_3.py
```

Le cas 1 simule une déconnexion du client immédiatement après l'envoi, puis envoie plusieurs messages de suivi sur de nouvelles connexions. Le cas 2 reproduit le WRC 1014756 : le `MSA-1=AR` du LAB est retourné au lieu d'un `CE` synthétique. Le cas 3 reproduit le WRC 1014797 : `ACK^A28^ACK` avec `MSH-9.3` renseigné est accepté par le contrôle de type ; l'ACK sortant peut être normalisé en `ACK^A28`.

Lancer les scénarios de stabilité avec horodatage :

```bash
./test/run_case_1_scenarios.sh
./test/run_case_2_scenarios.sh
./test/run_case_3_scenarios.sh
```

Chaque script exécute un scénario court, moyen et étendu avec 3, 5 et 10 messages. Les résultats sont affichés dans le terminal et enregistrés dans `test/logs/`, dans des fichiers nommés `case_1_YYYYMMDD_HHMMSS.log`, `case_2_YYYYMMDD_HHMMSS.log` et `case_3_YYYYMMDD_HHMMSS.log`.

Vérifier le résultat dans les logs :

```bash
grep -E 'RESULT|SUMMARY|FINAL' test/logs/case_1_*.log
grep -E 'RESULT|SUMMARY|FINAL' test/logs/case_2_*.log
grep -E 'RESULT|SUMMARY|FINAL' test/logs/case_3_*.log
```

Pour chaque cas, vérifier également **Interoperability -> View -> Message Viewer -> Visual Trace** dans IRIS. Confirmer que le message passe par le service, le routeur et l'opération attendus, puis contrôler le `DocType`, le `MSH-9` et le `MSA-1` de la réponse. Les erreurs de production sont consultables dans l'Event Log, en filtrant sur `case 1 service - TCP`, `case 2 service - TCP` ou `case 3 service - TCP`.

## Liens utiles

- [IRIS Drivers](https://intersystems-community.github.io/iris-driver-distribution/)
- [Getting Started](https://gettingstarted.intersystems.com/)
- [Developer Community](https://community.intersystems.com/)
- [FR Developer Community](https://fr.community.intersystems.com/)
- [Early Access Program](https://www.intersystems.com/early-access-program/)
- [IRIS MIRRORING](https://github.com/SylvainGuilbaud/IRIS_mirror)
- [IRIS EM CD PREVIEW](https://github.com/SylvainGuilbaud/IRIS_containers_prod)
