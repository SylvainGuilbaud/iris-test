#!/usr/bin/env python3
"""
Script météo IRIS version SQL directe
Utilise des commandes SQL pures pour éviter les problèmes d'API ObjectScript
"""

import json
import random

def create_meteo_script():
    """Crée un script SQL complet pour la démonstration météo"""
    
    # Données des villes françaises
    villes = [
        "Paris", "Marseille", "Lyon", "Toulouse", "Nice", 
        "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille"
    ]
    
    conditions = [
        "Ensoleillé", "Partiellement nuageux", "Nuageux", "Couvert", 
        "Bruine", "Pluie légère", "Pluie", "Pluie forte", "Orage",
        "Brouillard", "Neige légère", "Neige"
    ]
    
    directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    
    script_lines = []
    
    # En-tête
    script_lines.extend([
        "-- Script de démonstration météo avec vektors IRIS",
        "-- Version SQL pour compatibilité IRIS 2026.1",
        "",
        "-- Nettoyage et création de table",
        "DROP TABLE IF EXISTS app.meteo;",
        "",
        "CREATE TABLE app.meteo (",
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
        ");",
        "",
        "-- Insertion des données météo",
        ""
    ])
    
    # Génération de 20 bulletins météo
    for i in range(20):
        ville = random.choice(villes)
        temperature = round(random.uniform(-5, 35), 1)
        humidite = random.randint(30, 95)
        pression = round(random.uniform(980, 1040), 1)
        vent_vitesse = round(random.uniform(0, 50), 1)
        vent_direction = random.choice(directions)
        condition = random.choice(conditions)
        
        description = f"Météo {ville}: {condition}, {temperature}°C, vent {vent_direction} {vent_vitesse}km/h"
        
        # Génération d'un embedding simple (128 dimensions)
        embedding = [round(random.gauss(0, 0.5), 4) for _ in range(128)]
        embedding_json = json.dumps(embedding)
        
        script_lines.extend([
            f"-- Bulletin {i+1}: {ville}",
            f"INSERT INTO app.meteo (",
            f"    ville, temperature, humidite, pression, vent_vitesse,",
            f"    vent_direction, condition_meteo, description_bulletin, embedding_meteo",
            f") VALUES (",
            f"    '{ville}', {temperature}, {humidite}, {pression}, {vent_vitesse},",
            f"    '{vent_direction}', '{condition}', '{description}',",
            f"    TO_VECTOR('{embedding_json}', 'DOUBLE')",
            f");",
            ""
        ])
    
    # Requêtes de vérification
    script_lines.extend([
        "-- Vérification des données",
        "SELECT COUNT(*) as total_bulletins FROM app.meteo;",
        "",
        "-- Statistiques générales", 
        "SELECT ",
        "    COUNT(DISTINCT ville) as nb_villes,",
        "    MIN(temperature) as temp_min,",
        "    MAX(temperature) as temp_max,",
        "    ROUND(AVG(temperature), 1) as temp_moyenne",
        "FROM app.meteo;",
        "",
        "-- Top 5 des villes par nombre de bulletins",
        "SELECT ville, COUNT(*) as nb_bulletins",
        "FROM app.meteo", 
        "GROUP BY ville",
        "ORDER BY nb_bulletins DESC;",
        "",
        "-- Test de recherche par similarité vectorielle",
        "-- (cherche les villes avec météo similaire à Paris)",
        "SELECT TOP 3",
        "    ville,",
        "    temperature,", 
        "    condition_meteo,",
        "    ROUND(VECTOR_COSINE(embedding_meteo, (",
        "        SELECT TOP 1 embedding_meteo",
        "        FROM app.meteo",
        "        WHERE ville = 'Paris'",
        "    )), 3) as similarite",
        "FROM app.meteo",
        "WHERE ville != 'Paris'",
        "ORDER BY similarite DESC;",
        ""
    ])
    
    return "\n".join(script_lines)

def main():
    """Génère et affiche le script SQL"""
    
    print("🌤️  SCRIPT MÉTÉO IRIS - VERSION SQL DIRECTE")
    print("=" * 55)
    print("📝 Script SQL généré pour insertion directe dans IRIS:")
    print("-" * 55)
    
    script = create_meteo_script()
    print(script)
    
    print("-" * 55)
    print("💡 INSTRUCTIONS D'UTILISATION:")
    print("1. Copiez le script SQL ci-dessus")
    print("2. Connectez-vous à IRIS:")
    print("   docker exec -it iris-test iris session IRIS -U IRISAPP")
    print("3. Collez et exécutez le script ligne par ligne")
    print("4. Ou sauvegardez dans un fichier et exécutez avec:")
    print("   docker exec -i iris-test iris session IRIS -U IRISAPP < script.sql")
    print("=" * 55)
    
    # Sauvegarde du script dans un fichier
    with open("/Users/guilbaud/git/iris-test/iris-test/src/code/meteo_demo.sql", "w") as f:
        f.write(script)
    
    print("✅ Script sauvegardé dans: iris-test/src/code/meteo_demo.sql")

if __name__ == "__main__":
    main()