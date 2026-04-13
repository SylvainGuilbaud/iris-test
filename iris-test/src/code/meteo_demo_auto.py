#!/usr/bin/env python3
"""
Script de démo météo IRIS avec insertion automatique des données
Version qui exécute directement les commandes dans IRIS
"""

import json
import random
import math
import subprocess
import tempfile
import os
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

class MeteoDemoExecutor:
    def __init__(self):
        self.bulletins = []
    
    def generate_sample_data(self, nombre=20):
        """Génère des exemples de données météo"""
        self.bulletins = []
        
        for i in range(nombre):
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
            self.bulletins.append(bulletin)
        
        print(f"✓ {len(self.bulletins)} bulletins météo générés")
        return self.bulletins
    
    def create_objectscript_file(self):
        """Crée un fichier ObjectScript complet pour l'exécution"""
        
        script_content = []
        
        # En-tête et configuration
        script_content.extend([
            "/// Script de création et insertion de données météo",
            "/// Généré automatiquement pour la démonstration IRIS Vector",
            "",
            "// Configuration de l'espace de noms",
            'SET $NAMESPACE = "IRISAPP"',
            "",
            "// Création de la table",
            "WRITE \"🔧 Création de la table app.meteo...\", !",
            "TRY {",
            "  KILL ^app.meteoD, ^app.meteoS, ^app.meteoI",
            "  &SQL(DROP TABLE IF EXISTS app.meteo)",
            "  &SQL(CREATE TABLE app.meteo (",
            "    id INTEGER IDENTITY PRIMARY KEY,",
            "    ville VARCHAR(100) NOT NULL,",
            "    date_bulletin TIMESTAMP DEFAULT CURRENT_TIMESTAMP,",
            "    temperature DECIMAL(5,2),",
            "    humidite INTEGER,",
            "    pression DECIMAL(7,2),",
            "    vent_vitesse DECIMAL(5,2),",
            "    vent_direction VARCHAR(10),",
            "    condition_meteo VARCHAR(50),",
            "    description_bulletin VARCHAR(500),",
            "    embedding_meteo VECTOR(DOUBLE, 128)",
            "  ))",
            "  WRITE \"✓ Table app.meteo créée avec succès\", !",
            "} CATCH ex {",
            "  WRITE \"✗ Erreur création table: \", ex.DisplayString(), !",
            "  QUIT",
            "}",
            "",
            "// Insertion des données",
            "WRITE \"📥 Insertion des bulletins météo...\", !",
            "SET bulletinsInseres = 0",
            ""
        ])
        
        # Génération des insertions
        for i, bulletin in enumerate(self.bulletins, 1):
            embedding_json = json.dumps(bulletin["embedding"]).replace('"', '""')  # Échapper les guillemets
            
            script_content.extend([
                f"// Bulletin {i} - {bulletin['ville']}",
                "TRY {",
                "  &SQL(INSERT INTO app.meteo (",
                "    ville, temperature, humidite, pression, vent_vitesse,",
                "    vent_direction, condition_meteo, description_bulletin, embedding_meteo",
                "  ) VALUES (",
                f"    \"{bulletin['ville']}\", {bulletin['temperature']}, {bulletin['humidite']},",
                f"    {bulletin['pression']}, {bulletin['vent_vitesse']}, \"{bulletin['vent_direction']}\",",
                f"    \"{bulletin['condition']}\", \"{bulletin['description']}\",",
                f"    TO_VECTOR('{embedding_json}', 'DOUBLE')",
                "  ))",
                "  SET bulletinsInseres = bulletinsInseres + 1",
                "} CATCH ex {",
                f"  WRITE \"✗ Erreur bulletin {i}: \", ex.DisplayString(), !",
                "}",
                ""
            ])
        
        # Pied de page avec vérification
        script_content.extend([
            "WRITE \"✓ \", bulletinsInseres, \" bulletins insérés avec succès!\", !",
            "",
            "// Vérification des données",
            "WRITE \"📊 Vérification des données...\", !",
            "&SQL(SELECT COUNT(*) INTO :total FROM app.meteo)",
            "WRITE \"Total des bulletins en base: \", total, !",
            "",
            "// Test de recherche par similarité",
            "WRITE \"🔍 Test de recherche par similarité...\", !",
            "&SQL(DECLARE c1 CURSOR FOR",
            "  SELECT TOP 3 ville, temperature, condition_meteo,",
            "    VECTOR_COSINE(embedding_meteo, (",
            "      SELECT TOP 1 embedding_meteo FROM app.meteo WHERE ville = 'Paris'",
            "    )) as similarite",
            "  FROM app.meteo WHERE ville != 'Paris'",
            "  ORDER BY similarite DESC)",
            "&SQL(OPEN c1)",
            "FOR {",
            "  &SQL(FETCH c1 INTO :ville, :temp, :condition, :sim)",
            "  QUIT:SQLCODE'=0",
            "  WRITE \"  → \", ville, \": \", temp, \"°C, \", condition, \" (sim: \", $FNUMBER(sim,\"\",3), \")\", !",
            "}",
            "&SQL(CLOSE c1)",
            "",
            "WRITE \"✨ Démonstration terminée avec succès!\", !"
        ])
        
        return "\n".join(script_content)
    
    def execute_iris_script(self, script_content):
        """Exécute le script ObjectScript dans IRIS"""
        
        # Créer un fichier temporaire
        with tempfile.NamedTemporaryFile(mode='w', suffix='.mac', delete=False) as f:
            f.write(script_content)
            script_file = f.name
        
        try:
            print("🚀 Exécution du script dans IRIS...")
            
            # Copier le script dans le conteneur
            copy_cmd = f'docker cp "{script_file}" iris-test:/tmp/meteo_script.mac'
            subprocess.run(copy_cmd, shell=True, check=True)
            
            # Commande pour exécuter le script dans le conteneur IRIS
            cmd = 'docker exec -i iris-test iris session IRIS -U IRISAPP < /tmp/meteo_script.mac'
            
            print(f"💻 Commande: {cmd}")
            
            # Exécuter la commande
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            print("📤 Sortie IRIS:")
            print("-" * 40)
            print(result.stdout)
            
            if result.stderr:
                print("⚠️ Erreurs/Avertissements:")
                print(result.stderr)
            
            if result.returncode == 0:
                print("✅ Script exécuté avec succès!")
            else:
                print(f"❌ Erreur d'exécution (code: {result.returncode})")
        
        except subprocess.TimeoutExpired:
            print("⏰ Timeout - Le script prend trop de temps à s'exécuter")
        except Exception as e:
            print(f"❌ Erreur d'exécution: {e}")
        finally:
            # Nettoyer le fichier temporaire
            try:
                os.unlink(script_file)
                subprocess.run('docker exec iris-test rm -f /tmp/meteo_script.mac', shell=True)
            except:
                pass
    
    def run_demo(self):
        """Exécute la démonstration complète"""
        
        print("🌤️  DÉMONSTRATION MÉTÉO IRIS - INSERTION AUTOMATIQUE")
        print("=" * 60)
        
        # Étape 1: Génération des données
        print("\n1️⃣ Génération des données météo")
        self.generate_sample_data(15)
        
        # Étape 2: Création du script ObjectScript
        print("\n2️⃣ Création du script ObjectScript")
        script = self.create_objectscript_file()
        print("✓ Script ObjectScript généré")
        
        # Étape 3: Exécution du script
        print("\n3️⃣ Exécution dans IRIS")
        self.execute_iris_script(script)
        
        print(f"\n{'='*60}")
        print("🎯 PROCHAINES ÉTAPES:")
        print("1. Vérifiez les données: SELECT COUNT(*) FROM app.meteo")
        print("2. Testez les recherches vectorielles")
        print("3. Explorez les similarités météo entre villes")
        print("="*60)

def main():
    """Point d'entrée principal"""
    demo = MeteoDemoExecutor()
    demo.run_demo()

if __name__ == "__main__":
    main()