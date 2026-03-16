# 🏥 Générateur HL7 International - Mode d'emploi

Ce système génère et envoie des messages HL7 avec des données de patients aléatoires des 5 continents vers des hôpitaux français.

## 📁 Fichiers

- `send_tcp.python` - **Script principal** : génère et envoie les messages via TCP
- `demo_hl7.py` - **Démonstration** : affiche des exemples sans envoi TCP
- `README_HL7.md` - Cette documentation

## 🌍 Données générées

### Patients internationaux :
- **Europe** : Pierre Martin, Klaus Müller, Giuseppe Rossi...
- **Asie** : Wei Wang, Hiroshi Tanaka, Raj Kumar...
- **Afrique** : Amadou Diallo, Kwame Nkomo...
- **Amérique** : John Smith, José González, João Silva...
- **Océanie** : James Brown, Patricia Wilson...

### Hôpitaux français (15) :
- CH PARIS, CHU TOULOUSE, AP-HP BICHAT...
- Codes FINESS réels : 010000075, 030000287...
- Services : Cardiologie, Neurologie, Chirurgie...

### Données aléatoires :
- ✅ Dates de naissance (18-90 ans)
- ✅ Adresses françaises complètes
- ✅ Téléphones français valides
- ✅ Emails réalistes
- ✅ NIR (sécurité sociale) fictifs

## 🚀 Utilisation

### 1. **Démonstration (sans envoi TCP)** :
```bash
python3 demo_hl7.py
```
▶️ Affiche 3 exemples de patients avec messages HL7

### 2. **Production (envoi TCP sur port 29001)** :
```bash
python3 send_tcp.python
```
▶️ Interface interactive :
- Nombre de messages à envoyer
- Intervalle entre messages
- Statistiques d'envoi

## 📋 Format des messages HL7

Structure complète conforme HL7 v2.5 :
- **MSH** : En-tête de message
- **PID** : Identification patient 
- **PD1** : Données additionnelles patient
- **PV1** : Informations de visite
- **ZBE** : Segment spécifique français
- **ZFD** : Segment additionnel

## ⚙️ Configuration TCP

- **Host** : localhost
- **Port** : 29001 (configurable dans le code)
- **Timeout** : 2 secondes pour réponse
- **Encodage** : UTF-8

## 📊 Exemples de sortie

```
PATIENT: Wei Wang (Asie)
Sexe: F, Né(e) le: 19791115
HOPITAL: CH SOISSONS - SOISSONS (CS_Cardiologie)

MSH|^~\&|TDR||HOST||20260316175911||ADT^A03^ADT_A05|TD86537493|P|2.5
PID|1||P8827^^^^PI~2191159269696^^^&1.2.250.1.213.1.4.8&ISO^INS-NIR||Wang^Xin^Xin...
ZBE|S528^CH SOISSONS&020000261&FINEJ|20260316175911||INSERT|N||CS_Cardiologie...
```

## 🔧 Personnalisation

Vous pouvez modifier dans `send_tcp.python` :
- `TCP_HOST` et `TCP_PORT` pour la destination
- `NOMS_PRENOMS` pour ajouter d'autres noms
- `HOPITAUX_FRANCAIS` pour d'autres hôpitaux
- `VILLES_FRANCAISES` pour d'autres villes

## 🎯 Cas d'usage

- ✅ Tests de systèmes HL7
- ✅ Simulation de flux hospitaliers
- ✅ Validation d'intégrations
- ✅ Benchmarks de performance
- ✅ Démonstrations clients