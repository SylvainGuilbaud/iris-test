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

## Liens utiles

- [IRIS Drivers](https://intersystems-community.github.io/iris-driver-distribution/)
- [Getting Started](https://gettingstarted.intersystems.com/)
- [Developer Community](https://community.intersystems.com/)
- [FR Developer Community](https://fr.community.intersystems.com/)
- [Early Access Program](https://www.intersystems.com/early-access-program/)
- [IRIS MIRRORING](https://github.com/SylvainGuilbaud/IRIS_mirror)
- [IRIS EM CD PREVIEW](https://github.com/SylvainGuilbaud/IRIS_containers_prod)
