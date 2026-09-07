# IRIS Test

This project contains tests and demonstrations for InterSystems IRIS®.

The French documentation is available in [README-fr.md](README-fr.md).

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-with-Git)
- [Visual Studio Code and the InterSystems extensions](https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=GVSCO)
- [Python](https://www.python.org/downloads/)
- [Developer Community account](https://community.intersystems.com/)
- [Access to the InterSystems Containers repository](https://containers.intersystems.com/contents)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/SylvainGuilbaud/iris-test
```

2. Change to the repository directory:

```bash
cd iris-test
```

3. Start the services:

```bash
./start.sh
```

4. Wait for the services to start, then verify that the containers are `healthy`:

```bash
docker-compose ps
```

5. Open the IRIS Management Portal at http://localhost:10773/csp/sys/%25CSP.Portal.Home.zen

Credentials:

- Username: `_SYSTEM`
- Password: `SYS`

## Interoperability demonstrations

The `IRISAPP.prod.test` production contains two additional demonstration flows.

### 1. GAM-LAB flow: ACK, AR, and AA

This flow reproduces a synchronous HL7 exchange between a GAM system and a laboratory system:

```text
GAM
  -> de GAM ADT^A28 - TCP (port 29020)
  -> routeur Lab
  -> vers Lab HL7 - TCP
  -> Lab simulateur (AR)
```

The LAB simulator returns a negative application ACK with `MSA-1=AR`. The operation handles it with:

```text
ReplyCodeActions = :?R=C,:?E=F,:~=F,:?A=C,:*=F,:I?=W,:T?=C
StayConnected = 30
NoFailWhileDisconnected = 1
```

The rejection is logged without an infinite retry loop or a blocking technical error. The inbound service uses `AckMode=App`, and GAM receives an application ACK with `MSA-1=AA` when the synchronous exchange completes.

Run the test from the host machine:

```bash
python3 test/send_lab.py
python3 test/send_lab.py -n 3
```

The Visual Trace is available in the IRIS Management Portal:

```text
Interoperability -> View -> Message Viewer -> Visual Trace
```

Screenshots of the flow:

- [ACK AA trace](docs/flux%20GAM%20ACK%20AR/traceACK=AA.jpg)
- [ACK AR trace](docs/flux%20GAM%20ACK%20AR/traceACK=AR.jpg)
- [Initial ADT^A28 message](docs/flux%20GAM%20ACK%20AR/traceMessageADT_A28_init.jpg)

### 2. Prescription-to-robot flow

This flow receives an HL7 `ORM^O01` order, routes it to a simulated preparation robot, and demonstrates nominal and invalid scenarios:

```text
Prescription system
  -> de prescription ORM - TCP (port 29030)
  -> routeur robot
  -> robot de préparation
```

The test includes four scenarios:

- `ORDER-OK-500MG`: accepted order with a 500 mg dose;
- `ORDER-OK-1000MG`: accepted order with a 1000 mg dose;
- `ORDER-MISSING-DOSE`: business rejection because the dose is missing;
- `ORDER-MISSING-RXE`: invalid message because the RXE segment is missing.

Run all scenarios:

```bash
python3 test/send_robot_order.py
```

Run only successful or failing scenarios:

```bash
python3 test/send_robot_order.py --scenario working
python3 test/send_robot_order.py --scenario failing
```

The script displays the received MLLP ACK and its `MSA-1` code. The nominal scenario returns `AA`. The missing-RXE scenario returns `AE`; the missing-dose scenario is logged as a business rejection by the `robot de préparation` operation. Details are available in the Visual Trace and production logs.

## Useful links

- [IRIS Drivers](https://intersystems-community.github.io/iris-driver-distribution/)
- [Getting Started](https://gettingstarted.intersystems.com/)
- [Developer Community](https://community.intersystems.com/)
- [French Developer Community](https://fr.community.intersystems.com/)
- [Early Access Program](https://www.intersystems.com/early-access-program/)
- [IRIS MIRRORING](https://github.com/SylvainGuilbaud/IRIS_mirror)
- [IRIS EM CD PREVIEW](https://github.com/SylvainGuilbaud/IRIS_containers_prod)
