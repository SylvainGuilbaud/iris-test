#!/usr/bin/env python3
"""
Script de démo météo IRIS - Version utilisant les classes ObjectScript existantes
Utilise la classe app.meteo.cls pour générer directement les données
"""

import json
import random

# Données des principales villes françaises
VILLES_FRANCAISES = [
    "Paris", "Marseille", "Lyon", "Toulouse", "Nice", 
    "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille"
]

def generate_objectscript_commands():
    """Génère les commandes ObjectScript à exécuter manuellement"""
    
    print("🌤️  GÉNÉRATION DE COMMANDES OBJECTSCRIPT MÉTÉO")
    print("=" * 55)
    
    # Commandes de base
    commands = []
    commands.append('SET $NAMESPACE = "IRISAPP"')
    commands.append('')
    commands.append('// Utilisation de la classe app.meteo existante')
    commands.append('// Génération de données météo fictives')
    commands.append('')
    commands.append('WRITE "🌤️ Génération de bulletins météo...", !')
    commands.append('DO ##class(app.meteo).GenererDonneesFictives(25)')
    commands.append('')
    commands.append('WRITE "📊 Affichage des statistiques...", !')
    commands.append('DO ##class(app.meteo).AfficherStatistiques()')
    commands.append('')
    commands.append('WRITE "🔍 Test de recherche par similarité...", !')
    commands.append('DO ##class(app.meteo).RechercherBulletinsSimilaires("Paris", 5)')
    commands.append('')
    commands.append('WRITE "🌡️ Recherche par température (15-25°C)...", !')
    commands.append('DO ##class(app.meteo).RechercherParCriteres(15, 25, "")')
    commands.append('')
    commands.append('WRITE "☀️ Recherche conditions ensoleillées...", !')
    commands.append('DO ##class(app.meteo).RechercherParCriteres("", "", "Ensoleillé")')
    commands.append('')
    commands.append('WRITE "✨ Démonstration terminée!", !')
    
    print("📋 COMMANDES À EXÉCUTER DANS LE TERMINAL IRIS:")
    print("-" * 55)
    for cmd in commands:
        print(cmd)
    
    print()
    print("-" * 55)
    print("💡 INSTRUCTIONS:")
    print("1. Connectez-vous au terminal IRIS:")
    print("   docker exec -it iris-test iris terminal")
    print("2. Copiez-collez les commandes ci-dessus")
    print("3. Explorez les données avec les requêtes SQL")
    print("-" * 55)

def generate_sql_queries():
    """Génère les requêtes SQL de démonstration"""
    
    queries = [
        {
            "titre": "📊 Statistiques générales",
            "description": "Vue d'ensemble des données météo",
            "sql": """
SELECT 
    COUNT(*) as total_bulletins,
    COUNT(DISTINCT ville) as nb_villes,
    MIN(temperature) as temp_min,
    MAX(temperature) as temp_max,
    ROUND(AVG(temperature), 1) as temp_moyenne
FROM app.meteo
            """
        },
        {
            "titre": "🔍 TOP 5 - Similarité avec Paris",
            "description": "Villes avec météo similaire à Paris (recherche vectorielle)",
            "sql": """
SELECT TOP 5
    ville,
    temperature,
    condition_meteo,
    ROUND(VECTOR_COSINE(embedding_meteo, (
        SELECT TOP 1 embedding_meteo 
        FROM app.meteo 
        WHERE ville = 'Paris'
        ORDER BY date_bulletin DESC
    )), 3) as similarite
FROM app.meteo 
WHERE ville != 'Paris'
ORDER BY similarite DESC
            """
        },
        {
            "titre": "🌡️ Recherche par température (15-25°C)",
            "description": "Bulletins dans une plage de température spécifique",
            "sql": """
SELECT 
    ville,
    temperature,
    humidite,
    condition_meteo,
    description_bulletin
FROM app.meteo 
WHERE temperature BETWEEN 15 AND 25
ORDER BY temperature DESC
            """
        },
        {
            "titre": "☀️ Conditions ensoleillées",
            "description": "Tous les bulletins avec temps ensoleillé",
            "sql": """
SELECT 
    ville,
    temperature,
    humidite,
    condition_meteo,
    DATE_FORMAT(date_bulletin, '%d/%m %H:%i') as date_fmt
FROM app.meteo 
WHERE condition_meteo LIKE '%Ensoleillé%'
ORDER BY temperature DESC
            """
        },
        {
            "titre": "🏙️ Répartition par ville",
            "description": "Nombre de bulletins par ville",
            "sql": """
SELECT 
    ville,
    COUNT(*) as nb_bulletins,
    ROUND(AVG(temperature), 1) as temp_moyenne,
    MIN(temperature) as temp_min,
    MAX(temperature) as temp_max
FROM app.meteo 
GROUP BY ville 
ORDER BY nb_bulletins DESC
            """
        },
        {
            "titre": "🌪️ Conditions météo les plus fréquentes",
            "description": "Répartition des conditions météorologiques",
            "sql": """
SELECT 
    condition_meteo,
    COUNT(*) as frequence,
    ROUND(AVG(temperature), 1) as temp_moyenne,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM app.meteo), 1) as pourcentage
FROM app.meteo 
GROUP BY condition_meteo 
ORDER BY frequence DESC
            """
        }
    ]
    
    print("\n🔎 REQUÊTES SQL DE DÉMONSTRATION")
    print("=" * 50)
    
    for i, query in enumerate(queries, 1):
        print(f"\n{i}️⃣  {query['titre']}")
        print(f"📝 {query['description']}")
        print("-" * 40)
        print(query['sql'].strip())
        print()

def main():
    """Fonction principale"""
    generate_objectscript_commands()
    generate_sql_queries()
    
    print("\n" + "="*60)
    print("🎯 RÉSUMÉ DES ÉTAPES:")
    print("1. Les commandes ObjectScript utilisent la classe app.meteo existing")
    print("2. Exécutez-les dans le terminal IRIS Docker")
    print("3. Testez les requêtes SQL pour explorer les données")
    print("4. Expérimentez avec les recherches vectorielles")
    print("="*60)

if __name__ == "__main__":
    main()