#!/usr/bin/env python3
"""
Script de démo météo IRIS - Version simplifiée avec ObjectScript
Utilise les commandes ObjectScript depuis Python pour gérer les vektors
"""

import json
import random
import math
from datetime import datetime, timedelta

# Données des principales villes françaises
VILLES_FRANCAISES = [
    {"nom": "Paris", "lat": 48.8566, "lon": 2.3522},
    {"nom": "Marseille", "lat": 43.2965, "lon": 5.3698},
    {"nom": "Lyon", "lat": 45.7640, "lon": 4.8357},
    {"nom": "Toulouse", "lat": 43.6047, "lon": 1.4442},
    {"nom": "Nice", "lat": 43.7102, "lon": 7.2620},
    {"nom": "Nantes", "lat": 47.2184, "lon": -1.5536},
    {"nom": "Strasbourg", "lat": 48.5734, "lon": 7.7521},
    {"nom": "Montpellier", "lat": 43.6110, "lon": 3.8767},
    {"nom": "Bordeaux", "lat": 44.8378, "lon": -0.5792},
    {"nom": "Lille", "lat": 50.6292, "lon": 3.0573}
]

CONDITIONS_METEO = [
    "Ensoleillé", "Partiellement nuageux", "Nuageux", "Couvert", 
    "Bruine", "Pluie légère", "Pluie", "Pluie forte", "Orage",
    "Brouillard", "Neige légère", "Neige", "Grêle", "Vent fort"
]

class MeteoDemoSimple:
    def __init__(self):
        self.connection = None
    
    def connect_iris(self):
        """Connexion à IRIS avec gestion d'erreurs"""
        try:
            import iris
            # Tentative de connexion standard
            self.connection = iris.connect("localhost", 1972, "IRISAPP", "_SYSTEM", "SYS")
            print("✓ Connexion à IRIS établie (namespace: IRISAPP)")
            return True
        except ImportError:
            print("⚠️  Module iris non disponible. Installation requise:")
            print("   pip install intersystems-irispython")
            return False
        except Exception as e:
            print(f"✗ Erreur de connexion à IRIS: {e}")
            print("💡 Solutions possibles:")
            print("   1. Vérifiez qu'IRIS est démarré")
            print("   2. Vérifiez les paramètres de connexion")
            print("   3. Utilisez la version ObjectScript: iris terminal")
            return False
    
    def create_table_via_objectscript(self):
        """Crée la table via commandes ObjectScript"""
        commands = [
            'SET $NAMESPACE = "IRISAPP"',
            'TRY {',
            '  KILL ^app.meteoD, ^app.meteoS, ^app.meteoI',
            '  &SQL(DROP TABLE IF EXISTS app.meteo)',
            '  &SQL(CREATE TABLE app.meteo (',
            '    id INTEGER IDENTITY PRIMARY KEY,',
            '    ville VARCHAR(100) NOT NULL,', 
            '    date_bulletin TIMESTAMP DEFAULT CURRENT_TIMESTAMP,',
            '    temperature DECIMAL(5,2),',
            '    humidite INTEGER,',
            '    pression DECIMAL(7,2),',
            '    vent_vitesse DECIMAL(5,2),',
            '    vent_direction VARCHAR(10),',
            '    condition_meteo VARCHAR(50),',
            '    description_bulletin VARCHAR(500),',
            '    embedding_meteo VECTOR(DOUBLE, 128)',
            '  ))',
            '  WRITE "✓ Table app.meteo créée avec succès", !',
            '} CATCH ex {',
            '  WRITE "✗ Erreur: ", ex.DisplayString(), !',
            '}'
        ]
        
        print("📋 Commandes ObjectScript pour créer la table:")
        print("-" * 50)
        for cmd in commands:
            print(cmd)
        print("-" * 50)
        print("💡 Copiez et collez ces commandes dans le terminal IRIS")
    
    def generate_sample_data(self):
        """Génère des exemples de données météo"""
        bulletins = []
        
        for i in range(20):
            ville = random.choice(VILLES_FRANCAISES)
            
            # Génération des données météo
            temperature = round(random.uniform(-5, 35), 1)
            humidite = random.randint(30, 95)
            pression = round(random.uniform(980, 1040), 1)
            vent_vitesse = round(random.uniform(0, 50), 1)
            
            directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
            vent_direction = random.choice(directions)
            condition = random.choice(CONDITIONS_METEO)
            
            description = f"Météo {ville['nom']}: {condition}, {temperature}°C, vent {vent_direction} {vent_vitesse}km/h"
            
            # Génération d'un embedding simple (128 dimensions)
            embedding = [random.gauss(0, 0.5) for _ in range(128)]
            
            bulletin = {
                "ville": ville["nom"],
                "temperature": temperature,
                "humidite": humidite,
                "pression": pression,
                "vent_vitesse": vent_vitesse,
                "vent_direction": vent_direction,
                "condition": condition,
                "description": description,
                "embedding": embedding
            }
            bulletins.append(bulletin)
        
        return bulletins
    
    def generate_objectscript_inserts(self, bulletins):
        """Génère les commandes ObjectScript d'insertion"""
        print("📝 Commandes ObjectScript pour insérer les données:")
        print("-" * 60)
        print('SET $NAMESPACE = "IRISAPP"')
        print('TRY {')
        
        for i, bulletin in enumerate(bulletins, 1):
            # Préparation de l'embedding JSON
            embedding_json = json.dumps(bulletin["embedding"])
            
            print(f'  // Bulletin {i} - {bulletin["ville"]}')
            print(f'  &SQL(INSERT INTO app.meteo (')
            print(f'    ville, temperature, humidite, pression, vent_vitesse,')
            print(f'    vent_direction, condition_meteo, description_bulletin, embedding_meteo')
            print(f'  ) VALUES (')
            print(f'    "{bulletin["ville"]}", {bulletin["temperature"]}, {bulletin["humidite"]},')
            print(f'    {bulletin["pression"]}, {bulletin["vent_vitesse"]}, "{bulletin["vent_direction"]}",')
            print(f'    "{bulletin["condition"]}", "{bulletin["description"]}",')
            print(f'    TO_VECTOR(\'{embedding_json}\', \'DOUBLE\')')
            print(f'  ))')
            print()
        
        print('  WRITE "✓ Données insérées avec succès", !')
        print('} CATCH ex {')
        print('  WRITE "✗ Erreur: ", ex.DisplayString(), !')
        print('}')
        print("-" * 60)
    
    def generate_query_examples(self):
        """Génère des exemples de requêtes de recherche"""
        queries = [
            {
                "titre": "🔍 Recherche par similarité vectorielle avec Paris",
                "sql": """
SELECT TOP 5
    ville,
    temperature,
    condition_meteo,
    VECTOR_COSINE(embedding_meteo, (
        SELECT TOP 1 embedding_meteo 
        FROM app.meteo 
        WHERE ville = 'Paris'
    )) as similarite
FROM app.meteo 
WHERE ville != 'Paris'
ORDER BY similarite DESC
                """
            },
            {
                "titre": "🌡️ Recherche par température (15-25°C)",
                "sql": """
SELECT ville, temperature, humidite, condition_meteo, description_bulletin
FROM app.meteo 
WHERE temperature BETWEEN 15 AND 25
ORDER BY temperature DESC
                """
            },
            {
                "titre": "☀️ Recherche des conditions ensoleillées",
                "sql": """
SELECT ville, temperature, condition_meteo, description_bulletin
FROM app.meteo 
WHERE condition_meteo LIKE '%Ensoleillé%'
ORDER BY temperature DESC
                """
            },
            {
                "titre": "📊 Statistiques générales",
                "sql": """
SELECT 
    COUNT(*) as total_bulletins,
    COUNT(DISTINCT ville) as nb_villes,
    MIN(temperature) as temp_min,
    MAX(temperature) as temp_max,
    AVG(temperature) as temp_moyenne
FROM app.meteo
                """
            },
            {
                "titre": "🏙️ Bulletins par ville (top 5)",
                "sql": """
SELECT ville, COUNT(*) as nb_bulletins
FROM app.meteo 
GROUP BY ville 
ORDER BY nb_bulletins DESC
                """
            }
        ]
        
        print("🔎 EXEMPLES DE REQUÊTES DE RECHERCHE")
        print("=" * 50)
        
        for query in queries:
            print(f"\n{query['titre']}")
            print("-" * 40)
            print(query['sql'].strip())
            print()
    
    def demo_complete(self):
        """Démonstration complète"""
        print("🌤️  DÉMONSTRATION MÉTÉO IRIS - VERSION OBJECTSCRIPT")
        print("=" * 55)
        
        # Étape 1: Test de connexion
        print("\n1️⃣ Test de connexion Python (optionnel)")
        self.connect_iris()
        
        # Étape 2: Création de table
        print("\n2️⃣ Création de la table app.meteo")
        self.create_table_via_objectscript()
        
        # Étape 3: Génération des données
        print(f"\n3️⃣ Génération de données météo fictives")
        bulletins = self.generate_sample_data()
        print(f"✓ {len(bulletins)} bulletins générés")
        
        # Étape 4: Commandes d'insertion
        print(f"\n4️⃣ Insertion des données")
        self.generate_objectscript_inserts(bulletins)
        
        # Étape 5: Exemples de recherche  
        print(f"\n5️⃣ Recherches et analyses")
        self.generate_query_examples()
        
        print("\n" + "=" * 55)
        print("✨ INSTRUCTIONS FINALES:")
        print("1. Copiez les commandes ObjectScript ci-dessus")
        print("2. Connectez-vous au terminal IRIS: iris terminal")
        print("3. Collez et exécutez les commandes")
        print("4. Testez les requêtes de recherche")
        print("=" * 55)

if __name__ == "__main__":
    demo = MeteoDemoSimple()
    demo.demo_complete()