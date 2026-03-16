#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de démonstration des messages HL7 générés aléatoirement
Affiche 3 exemples de messages sans envoi TCP
"""

import random
import time
from datetime import datetime, timedelta

# Importer les données et fonctions du script principal
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Reprise des données du script principal
NOMS_PRENOMS = {
    'Europe': {
        'noms': ['Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Petit', 'Durand', 'Leroy', 'Moreau', 'Simon'],
        'prenoms': ['Pierre', 'Jean', 'Marie', 'François', 'Michel', 'Alain', 'Patrick', 'Philippe', 'Daniel', 'Bernard']
    },
    'Asie': {
        'noms': ['Wang', 'Li', 'Zhang', 'Liu', 'Chen', 'Yang', 'Huang', 'Zhao', 'Wu', 'Zhou'],
        'prenoms': ['Wei', 'Ming', 'Jun', 'Hui', 'Lei', 'Xin', 'Yang', 'Liang', 'Jing', 'Bin']
    },
    'Afrique': {
        'noms': ['Diallo', 'Traoré', 'Keita', 'Coulibaly', 'Koné', 'Camara', 'Touré', 'Sidibé', 'Sangaré', 'Ouattara'],
        'prenoms': ['Amadou', 'Ibrahim', 'Ousmane', 'Mamadou', 'Abdoulaye', 'Moussa', 'Fatou', 'Aïcha', 'Mariam', 'Aminata']
    },
    'Amérique': {
        'noms': ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'],
        'prenoms': ['John', 'Michael', 'William', 'David', 'James', 'Robert', 'Christopher', 'José', 'Carlos', 'Luis']
    },
    'Océanie': {
        'noms': ['Smith', 'Brown', 'Wilson', 'Taylor', 'White', 'Martin', 'Anderson', 'Thompson', 'Garcia', 'Martinez'],
        'prenoms': ['James', 'Robert', 'John', 'Michael', 'William', 'David', 'Richard', 'Thomas', 'Mark', 'Paul']
    }
}

HOPITAUX_FRANCAIS = [
    {'nom': 'CH PARIS', 'code': '010000075', 'ville': 'PARIS', 'service': 'UF_Cardiologie'},
    {'nom': 'CHU TOULOUSE', 'code': '030000287', 'ville': 'TOULOUSE', 'service': 'UF_Neurologie'},
    {'nom': 'CHU BORDEAUX', 'code': '040000156', 'ville': 'BORDEAUX', 'service': 'UF_Chirurgie'},
    {'nom': 'CH SOISSONS', 'code': '020000261', 'ville': 'SOISSONS', 'service': 'CS_Cardiologie'},
    {'nom': 'CHU LYON', 'code': '020000145', 'ville': 'LYON', 'service': 'UF_Pneumologie'}
]

VILLES_FRANCAISES = [
    {'nom': 'PARIS', 'cp': '75001', 'dept': '75'},
    {'nom': 'MARSEILLE', 'cp': '13001', 'dept': '13'},
    {'nom': 'LYON', 'cp': '69001', 'dept': '69'},
    {'nom': 'TOULOUSE', 'cp': '31000', 'dept': '31'},
    {'nom': 'NICE', 'cp': '06000', 'dept': '06'}
]

def generer_date_naissance():
    """Génère une date de naissance aléatoire entre 18 et 90 ans"""
    aujourd_hui = datetime.now()
    age_min = timedelta(days=18*365)
    age_max = timedelta(days=90*365)
    
    date_max = aujourd_hui - age_min
    date_min = aujourd_hui - age_max
    
    delta = date_max - date_min
    jours_aleatoires = random.randint(0, delta.days)
    date_naissance = date_min + timedelta(days=jours_aleatoires)
    
    return date_naissance.strftime("%Y%m%d%H%M%S")

def generer_telephone():
    """Génère un numéro de téléphone français aléatoire"""
    prefixes = ['01', '02', '03', '04', '05', '06', '07']
    prefix = random.choice(prefixes)
    reste = ''.join([str(random.randint(0, 9)) for _ in range(8)])
    return f"{prefix}{reste}"

def generer_patient():
    """Génère les informations d'un patient aléatoire"""
    continent = random.choice(list(NOMS_PRENOMS.keys()))
    donnees_continent = NOMS_PRENOMS[continent]
    
    nom = random.choice(donnees_continent['noms'])
    prenom = random.choice(donnees_continent['prenoms'])
    sexe = random.choice(['M', 'F'])
    date_naissance = generer_date_naissance()
    
    # Adresse française
    ville = random.choice(VILLES_FRANCAISES)
    numero_rue = random.randint(1, 999)
    rues = ['rue des Lilas', 'avenue Victor Hugo', 'boulevard de la République']
    rue = random.choice(rues)
    
    adresse = f"{numero_rue} {rue}^{random.choice(['', '2eme etage', 'Apt 3B'])}^{ville['nom']}^^{ville['cp']}^FRA^H^^{ville['dept']}{random.randint(100, 999)}"
    
    telephone = generer_telephone()
    
    # NIR fictif
    annee_naissance = date_naissance[:2]
    mois_naissance = date_naissance[4:6]
    dept_naissance = random.choice(['01', '02', '13', '33', '59', '69', '75', '92'])
    sexe_code = '1' if sexe == 'M' else '2'
    nir = f"{sexe_code}{annee_naissance}{mois_naissance}{dept_naissance}{random.randint(100, 999):03d}{random.randint(1, 999):03d}"
    
    return {
        'continent': continent,
        'nom': nom,
        'prenom': prenom,
        'sexe': sexe,
        'date_naissance': date_naissance,
        'adresse': adresse,
        'telephone': telephone,
        'nir': nir,
        'ville': ville
    }

def creer_message_hl7_demo(patient, hopital):
    """Crée un message HL7 pour démonstration"""
    message_id = f"TD{random.randint(10000000, 99999999)}"
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    
    # Message HL7 simplifié pour la démo
    msh = f"MSH|^~\\&|TDR||HOST||{timestamp}||ADT^A03^ADT_A05|{message_id}|P|2.5"
    pid_id = f"P{random.randint(1, 9999)}"
    pid = f"PID|1||{pid_id}^^^^PI~{patient['nir']}^^^&1.2.250.1.213.1.4.8&ISO^INS-NIR||{patient['nom']}^{patient['prenom']}^^||{patient['date_naissance']}|{patient['sexe']}|||{patient['adresse']}||^PRN^PH^^^^^^^^^{patient['telephone']}||fr|{patient['sexe']}||||||||||||||||VALI"
    
    service_code = f"S{random.randint(100, 999)}"
    pv1 = f"PV1||O|LABO^^^{hopital['nom']}&{hopital['code']}&FINEJ|R||||||||||||{service_code}^^^MIPIH^VN^{hopital['nom']}&{hopital['code']}&FINEJ"
    zbe = f"ZBE|{service_code}^{hopital['nom']}&{hopital['code']}&FINEJ|{timestamp}||INSERT|N||{hopital['service']}^^^^^MIPIH^UF"
    
    return f"{msh}\r{pid}\r{pv1}\r{zbe}\r"

def main():
    """Démonstration de 3 messages HL7"""
    print("🏥 === DÉMONSTRATION GÉNÉRATEUR HL7 INTERNATIONAL === 🌍")
    print("Génération de 3 exemples de patients des 5 continents\n")
    
    for i in range(3):
        print(f"\n{'='*60}")
        print(f"                    PATIENT {i+1}/3")
        print('='*60)
        
        patient = generer_patient()
        hopital = random.choice(HOPITAUX_FRANCAIS)
        
        # Affichage des informations
        print(f"🌍 CONTINENT: {patient['continent']}")
        print(f"👤 PATIENT: {patient['prenom']} {patient['nom']}")
        print(f"⚧️  SEXE: {patient['sexe']}")
        print(f"🎂 NÉ(E) LE: {patient['date_naissance'][:8]}")
        print(f"🏠 ADRESSE: {patient['adresse'].replace('^', ' ')}")
        print(f"📞 TÉLÉPHONE: {patient['telephone']}")
        print(f"🆔 NIR: {patient['nir']}")
        print(f"🏥 HÔPITAL: {hopital['nom']} - {hopital['ville']}")
        print(f"🏥 SERVICE: {hopital['service']}")
        
        # Message HL7
        message = creer_message_hl7_demo(patient, hopital)
        print(f"\n📋 MESSAGE HL7:")
        print("-" * 40)
        for ligne in message.split('\r'):
            if ligne.strip():
                print(ligne)
        
        if i < 2:
            print("\n⏳ Génération du patient suivant...")
            time.sleep(1)
    
    print(f"\n{'='*60}")
    print("✅ Démonstration terminée!")
    print("💡 Pour envoyer les messages via TCP sur le port 29001,")
    print("   exécutez simplement: python3 send_tcp.python")
    print('='*60)

if __name__ == "__main__":
    main()