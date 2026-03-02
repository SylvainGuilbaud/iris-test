# IRIS Test

Ce projet sert de tests sur InterSystems IRIS®

## Pré-requis

- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Visual Studio Code + extensions InterSystems](https://docs.intersystems.com/components/csp/docbook/DocBook.UI.Page.cls?KEY=GVSCO)
- [Python](https://www.python.org/downloads/)
- [Compte Developer Community](https://community.intersystems.com/)
- [Login au repo Containers InterSystems](https://containers.intersystems.com/contents)

## Installation

1. Cloner ce repo:

```bash
git clone https://github.com/SylvainGuilbaud/iris-test
```

2. Aller dans le répertoire du repo cloné:

```bash
cd iris-test
```

3. Démarrer les services:

```bash
./start.sh
```
4. Attendre que les services soient démarrés (environ 2 minutes) et vérifier que tous les conteneurs sont en état "healthy":

```bash
docker-compose ps
```

5. Se connecter à l'interface de gestion d'IRIS (http://localhost:10773/csp/sys/%25CSP.Portal.Home.zen) avec les identifiants suivants:
- Username: _SYSTEM
- Password: SYS

## liens utiles
- [IRIS Drivers](https://intersystems-community.github.io/iris-driver-distribution/)
- [Getting Started](https://gettingstarted.intersystems.com/)
- [Developer Community](https://community.intersystems.com/)
- [FR Developer Community](https://fr.community.intersystems.com/)
- [Early Access Program](https://www.intersystems.com/early-access-program/)
- [IRIS MIRRORING](https://github.com/SylvainGuilbaud/IRIS_mirror)
- [IRIS EM CD PREVIEW](https://github.com/SylvainGuilbaud/IRIS_containers_prod)
