#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Générateur et envoyeur de messages HL7 TCP avec données aléatoires
Génère des patients des 5 continents avec informations d'hôpitaux français
"""

import socket
import random
import time
from datetime import datetime, timedelta
import uuid

# Port TCP pour l'envoi
TCP_HOST = 'localhost'
TCP_PORT = 29001

# Noms et prénoms par continent
NOMS_PRENOMS = {
    'Europe': {
        'noms': ['Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Petit', 'Durand', 'Leroy', 'Moreau', 'Simon', 
                'Laurent', 'Lefebvre', 'Michel', 'Garcia', 'David', 'Müller', 'Schmidt', 'Schneider', 'Fischer', 'Weber',
                'Meyer', 'Wagner', 'Becker', 'Schulz', 'Hoffmann', 'Rossi', 'Russo', 'Ferrari', 'Esposito', 'Bianchi'],
        'prenoms': ['Pierre', 'Jean', 'Marie', 'François', 'Michel', 'Alain', 'Patrick', 'Philippe', 'Daniel', 'Bernard',
                   'Klaus', 'Hans', 'Wolfgang', 'Günther', 'Heinrich', 'Marco', 'Giuseppe', 'Antonio', 'Francesco', 'Alessandro',
                   'Carlos', 'José', 'Manuel', 'Luis', 'Miguel', 'Ana', 'Carmen', 'Isabel', 'Pilar', 'Dolores']
    },
    'Asie': {
        'noms': ['Wang', 'Li', 'Zhang', 'Liu', 'Chen', 'Yang', 'Huang', 'Zhao', 'Wu', 'Zhou',
                'Tanaka', 'Suzuki', 'Watanabe', 'Sato', 'Ito', 'Nakamura', 'Kobayashi', 'Kim', 'Park', 'Lee',
                'Kumar', 'Singh', 'Sharma', 'Gupta', 'Verma', 'Yadav', 'Patel', 'Shah', 'Khan', 'Ahmed'],
        'prenoms': ['Wei', 'Ming', 'Jun', 'Hui', 'Lei', 'Xin', 'Yang', 'Liang', 'Jing', 'Bin',
                   'Hiroshi', 'Takeshi', 'Akira', 'Kenji', 'Yuki', 'Jin-woo', 'Min-jun', 'Seung-ho',
                   'Raj', 'Amit', 'Rahul', 'Vikash', 'Suresh', 'Priya', 'Anjali', 'Deepika', 'Sunita', 'Kavita']
    },
    'Afrique': {
        'noms': ['Diallo', 'Traoré', 'Keita', 'Coulibaly', 'Koné', 'Camara', 'Touré', 'Sidibé', 'Sangaré', 'Ouattara',
                'Mbeki', 'Nkomo', 'Dlamini', 'Ngcobo', 'Mthembu', 'Ndaba', 'Kone', 'Diabate', 'Dao', 'Sanou'],
        'prenoms': ['Amadou', 'Ibrahim', 'Ousmane', 'Mamadou', 'Abdoulaye', 'Moussa', 'Fatou', 'Aïcha', 'Mariam', 'Aminata',
                   'Kwame', 'Kofi', 'Adjoa', 'Akosua', 'Mandla', 'Sipho', 'Themba', 'Nomsa', 'Thandiwe', 'Precious']
    },
    'Amérique': {
        'noms': ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                'Silva', 'Santos', 'Oliveira', 'Pereira', 'Costa', 'Rodrigues', 'Almeida', 'Nascimento', 'Lima', 'Araújo',
                'González', 'López', 'Hernández', 'Pérez', 'Sánchez', 'Ramírez', 'Cruz', 'Flores', 'Gómez', 'Díaz'],
        'prenoms': ['John', 'Michael', 'William', 'David', 'James', 'Robert', 'Christopher', 'José', 'Carlos', 'Luis',
                   'Maria', 'Ana', 'Carmen', 'Rosa', 'Elena', 'Isabella', 'Sofia', 'Victoria', 'Gabriela', 'Daniela',
                   'João', 'Pedro', 'Carlos', 'Luiz', 'Fernando', 'Rafael', 'Marcos', 'Antonio', 'Francisco', 'Paulo']
    },
    'Océanie': {
        'noms': ['Smith', 'Brown', 'Wilson', 'Taylor', 'White', 'Martin', 'Anderson', 'Thompson', 'Garcia', 'Martinez',
                'Williams', 'Johnson', 'Jones', 'Davis', 'Miller', 'Moore', 'Jackson', 'Lee', 'Harris', 'Clark'],
        'prenoms': ['James', 'Robert', 'John', 'Michael', 'William', 'David', 'Richard', 'Thomas', 'Mark', 'Paul',
                   'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen']
    }
}

# Hôpitaux français (MSH et ZBE)
HOPITAUX_FRANCAIS = [
    {'nom': 'CH PARIS', 'code': '010000075', 'ville': 'PARIS', 'service': 'UF_Cardiologie'},
    {'nom': 'CH LYON', 'code': '020000145', 'ville': 'LYON', 'service': 'UF_Pneumologie'},
    {'nom': 'CHU TOULOUSE', 'code': '030000287', 'ville': 'TOULOUSE', 'service': 'UF_Neurologie'},
    {'nom': 'AP-HP BICHAT', 'code': '010000093', 'ville': 'PARIS', 'service': 'UF_Urgences'},
    {'nom': 'CHU BORDEAUX', 'code': '040000156', 'ville': 'BORDEAUX', 'service': 'UF_Chirurgie'},
    {'nom': 'CHR LILLE', 'code': '050000234', 'ville': 'LILLE', 'service': 'UF_Pediatrie'},
    {'nom': 'CHU RENNES', 'code': '060000187', 'ville': 'RENNES', 'service': 'UF_Oncologie'},
    {'nom': 'CHU STRASBOURG', 'code': '070000298', 'ville': 'STRASBOURG', 'service': 'UF_Radiologie'},
    {'nom': 'CHU NANTES', 'code': '080000165', 'ville': 'NANTES', 'service': 'UF_Gynecologie'},
    {'nom': 'CHU CLERMONT', 'code': '090000219', 'ville': 'CLERMONT FERRAND', 'service': 'UF_Psychiatrie'},
    {'nom': 'CH SOISSONS', 'code': '020000261', 'ville': 'SOISSONS', 'service': 'CS_Cardiologie'},
    {'nom': 'CHU AMIENS', 'code': '100000342', 'ville': 'AMIENS', 'service': 'UF_Dermatologie'},
    {'nom': 'CHU GRENOBLE', 'code': '110000278', 'ville': 'GRENOBLE', 'service': 'UF_Endocrinologie'},
    {'nom': 'CHU NANCY', 'code': '120000189', 'ville': 'NANCY', 'service': 'UF_Rhumatologie'},
    {'nom': 'CHU MONTPELLIER', 'code': '130000254', 'ville': 'MONTPELLIER', 'service': 'UF_Nephologie'}
]

# Villes françaises pour adresses
VILLES_FRANCAISES = [
    {'nom': 'PARIS', 'cp': '75001', 'dept': '75'},
    {'nom': 'MARSEILLE', 'cp': '13001', 'dept': '13'},
    {'nom': 'LYON', 'cp': '69001', 'dept': '69'},
    {'nom': 'TOULOUSE', 'cp': '31000', 'dept': '31'},
    {'nom': 'NICE', 'cp': '06000', 'dept': '06'},
    {'nom': 'NANTES', 'cp': '44000', 'dept': '44'},
    {'nom': 'STRASBOURG', 'cp': '67000', 'dept': '67'},
    {'nom': 'MONTPELLIER', 'cp': '34000', 'dept': '34'},
    {'nom': 'BORDEAUX', 'cp': '33000', 'dept': '33'},
    {'nom': 'LILLE', 'cp': '59000', 'dept': '59'},
    {'nom': 'RENNES', 'cp': '35000', 'dept': '35'},
    {'nom': 'REIMS', 'cp': '51100', 'dept': '51'},
    {'nom': 'SAINT ETIENNE', 'cp': '42000', 'dept': '42'},
    {'nom': 'TOULON', 'cp': '83000', 'dept': '83'},
    {'nom': 'GRENOBLE', 'cp': '38000', 'dept': '38'}
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

def generer_email(prenom, nom):
    """Génère un email basé sur le prénom et nom"""
    domaines = ['gmail.com', 'yahoo.fr', 'hotmail.com', 'orange.fr', 'free.fr', 'wanadoo.fr']
    domaine = random.choice(domaines)
    return f"{prenom.lower()}.{nom.lower()}@{domaine}"

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
    rues = ['rue des Lilas', 'avenue Victor Hugo', 'boulevard de la République', 
            'place de la Mairie', 'rue Jean Jaurès', 'impasse des Roses',
            'rue de la Paix', 'avenue Charles de Gaulle', 'rue des Écoles',
            'boulevard Pasteur', 'rue de la Liberté', 'avenue de la Gare']
    rue = random.choice(rues)
    
    adresse = f"{numero_rue} {rue}^{random.choice(['', '2eme etage', 'Apt 3B', 'Bat A'])}^{ville['nom']}^^{ville['cp']}^FRA^H^^{ville['dept']}{random.randint(100, 999)}"
    
    telephone = generer_telephone()
    email = generer_email(prenom, nom)
    
    # NIR (numéro de sécurité sociale français fictif)
    annee_naissance = date_naissance[:2]
    mois_naissance = date_naissance[4:6]
    dept_naissance = random.choice(['01', '02', '13', '33', '59', '69', '75', '92'])
    commune = random.randint(1, 999)
    ordre = random.randint(1, 999)
    
    sexe_code = '1' if sexe == 'M' else '2'
    nir = f"{sexe_code}{annee_naissance}{mois_naissance}{dept_naissance}{commune:03d}{ordre:03d}"
    
    return {
        'continent': continent,
        'nom': nom,
        'prenom': prenom,
        'sexe': sexe,
        'date_naissance': date_naissance,
        'adresse': adresse,
        'telephone': telephone,
        'email': email,
        'nir': nir,
        'ville': ville
    }

def generer_message_id():
    """Génère un ID de message unique"""
    return f"TD{random.randint(10000000, 99999999)}"

def generer_timestamp():
    """Génère un timestamp au format HL7"""
    return datetime.now().strftime("%Y%m%d%H%M%S")

def generer_hopital():
    """Sélectionne un hôpital français aléatoire"""
    return random.choice(HOPITAUX_FRANCAIS)

def creer_message_hl7(patient, hopital):
    """Crée un message HL7 complet avec les données du patient et de l'hôpital"""
    message_id = generer_message_id()
    timestamp = generer_timestamp()
    
    # MSH - Message Header
    msh = f"MSH|^~\\&|TDR||HOST||{timestamp}||ADT^A03^ADT_A05|{message_id}|P|2.5"
    
    # PID - Patient Identification
    pid_id = f"P{random.randint(1, 9999)}"
    pid = f"PID|1||{pid_id}^^^^PI~{patient['nir']}^^^&1.2.250.1.213.1.4.8&ISO^INS-NIR||{patient['nom']}^{patient['prenom']}^{patient['prenom']}^^Mme^^L~{patient['nom']}^{patient['prenom']}^{patient['prenom']}^^Mme^^D||{patient['date_naissance']}|{patient['sexe']}|||{patient['adresse']}~^^{patient['ville']['nom']}^^{patient['ville']['cp']}^FRA^BDL^^{patient['ville']['dept']}{random.randint(100, 999)}||^PRN^PH^^^^^^^^^{patient['telephone']}~^PRN^CP^^^^^^^^^{generer_telephone()}~^NET^Internet^{patient['email']}||fr|{patient['sexe']}|||||||{patient['ville']['nom']}|||FRA^FRANCE^ISO 3166 alpha-3||||N||VALI"
    
    # PD1 - Patient Additional Demographics
    pd1 = "PD1||U||||||||||N"
    
    # PV1 - Patient Visit
    service_code = f"S{random.randint(100, 999)}"
    visite_timestamp = generer_timestamp()
    pv1 = f"PV1||O|LABO^^^{hopital['nom']}&{hopital['code']}&FINEJ^^^^^^^MIPIH|R||||||{random.randint(10, 999):03d}||||||N|||{service_code}^^^MIPIH^VN^{hopital['nom']}&{hopital['code']}&FINEJ|01|07|N||||||||||||||||||||||{visite_timestamp}||||||{service_code}^^^MIPIH^^{hopital['nom']}&{hopital['code']}&FINEJ"
    
    # ZBE - Segment spécifique français
    zbe = f"ZBE|{service_code}^{hopital['nom']}&{hopital['code']}&FINEJ|{visite_timestamp}||INSERT|N||{hopital['service']}^^^^^MIPIH^UF^{hopital['nom']}&{hopital['code']}&FINEJ^^{random.randint(1000, 9999)}||MH"
    
    # ZFD - Segment additionnel
    zfd = "ZFD|||"
    
    # Assemblage du message complet
    message = f"{msh}\r{pid}\r{pd1}\r{pv1}\r{zbe}\r{zfd}\r"
    
    return message

def envoyer_message_tcp(message, host=TCP_HOST, port=TCP_PORT):
    """Envoie un message HL7 via TCP - version rapide"""
    sock = None
    try:
        # Création de la socket TCP optimisée
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)  # Désactive l'algorithme de Nagle
        sock.connect((host, port))
        
        # Envoi immédiat du message avec wrapping HL7
        wrapped_message = f"\x0b{message}\x1c\x0d"
        sock.send(wrapped_message.encode('utf-8'))
        print(f"Message envoyé sur {host}:{port}")
        
        # Réception de l'ACK d'IRIS avant le prochain message
        try:
            sock.settimeout(2)  # Timeout pour ACK
            reponse = sock.recv(1024)
            if reponse:
                reponse_str = reponse.decode('utf-8', errors='ignore')
                print("\n--- ACK COMPLET D'IRIS ---")
                # Nettoyer et afficher l'ACK segment par segment
                ack_clean = reponse_str.replace('\x0b', '').replace('\x1c', '').replace('\x0d', '').replace('\r', '\r\n')
                print(ack_clean)
                print("--- FIN ACK ---")
                # Vérifier si c'est un ACK positif
                if 'MSA|AA' in reponse_str or 'ACK' in reponse_str:
                    print("✓ ACK positif reçu")
                else:
                    print("⚠️ Réponse inattendue")
                return True  # ACK reçu, succès
        except socket.timeout:
            print("⚠️ Timeout - pas d'ACK reçu")
            return False  # Pas d'ACK = échec
        except Exception as e:
            print(f"⚠️ Erreur réception ACK: {e}")
            return False
        
    except Exception as e:
        print(f"Erreur lors de l'envoi TCP: {e}")
        return False
    finally:
        if sock:
            try:
                sock.shutdown(socket.SHUT_RDWR)
                sock.close()
            except:
                pass

def afficher_message(patient, hopital, message):
    """Affiche les informations du patient et de l'hôpital"""
    print("\n" + "="*80)
    print(f"PATIENT: {patient['prenom']} {patient['nom']} ({patient['continent']})")
    print(f"Sexe: {patient['sexe']}, Né(e) le: {patient['date_naissance'][:8]}")
    print(f"Adresse: {patient['adresse'].replace('^', ' ')}")
    print(f"Téléphone: {patient['telephone']}, Email: {patient['email']}")
    print(f"HOPITAL: {hopital['nom']} - {hopital['ville']} ({hopital['service']})")
    print(f"Code hôpital: {hopital['code']}")
    print("\nMESSAGE HL7:")
    print("-" * 40)
    for ligne in message.split('\r'):
        if ligne:
            print(ligne)
    print("="*80)

def main():
    """Fonction principale"""
    print("=== Générateur de messages HL7 TCP ===")
    print(f"Destination: {TCP_HOST}:{TCP_PORT}")
    
    try:
        nombre_messages = int(input("\nNombre de messages à envoyer (défaut: 5): ") or "5")
        
        print(f"\nGénération et envoi de {nombre_messages} messages HL7...")
        
        succes = 0
        echecs = 0
        
        for i in range(nombre_messages):
            print(f"\n[{i+1}/{nombre_messages}] Génération du patient...")
            
            # Génération des données
            patient = generer_patient()
            hopital = generer_hopital()
            message = creer_message_hl7(patient, hopital)
            
            # Affichage des informations
            afficher_message(patient, hopital, message)
            
            # Envoi du message
            print(f"Envoi du message sur {TCP_HOST}:{TCP_PORT}...")
            if envoyer_message_tcp(message):
                succes += 1
                print("✓ Message envoyé avec succès!")
            else:
                echecs += 1
                print("✗ Échec de l'envoi")
            
            # Envoi continu sans délai
        
        print(f"\n=== RÉSUMÉ ===")
        print(f"Messages envoyés avec succès: {succes}")
        print(f"Échecs: {echecs}")
        print(f"Total: {nombre_messages}")
        
    except KeyboardInterrupt:
        print("\n\nArrêt du programme par l'utilisateur.")
    except ValueError:
        print("Erreur: Veuillez entrer des nombres valides.")
    except Exception as e:
        print(f"Erreur inattendue: {e}")

if __name__ == "__main__":
    main()
