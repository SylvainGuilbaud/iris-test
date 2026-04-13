#!/usr/bin/env python3
"""
Script de démo pour gérer des bulletins météo avec des données vectorielles
Crée une table app.meteo avec des vektors pour les bulletins météo des grandes villes françaises
"""

import json
import random
import math
from datetime import datetime, timedelta
try:
    import intersystems_iris_python as iris_native
except ImportError:
    try:
        import intersystems_iris as iris_native
    except ImportError:
        print("❌ Erreur: Bibliothèque IRIS non trouvée. Installez: pip install intersystems-irispython")
        exit(1)

# Données des principales villes françaises
VILLES_FRANCAISES = [
    {"nom": "Paris", "lat": 48.8566, "lon": 2.3522, "population": 2161000},
    {"nom": "Marseille", "lat": 43.2965, "lon": 5.3698, "population": 861635},
    {"nom": "Lyon", "lat": 45.7640, "lon": 4.8357, "population": 513275},
    {"nom": "Toulouse", "lat": 43.6047, "lon": 1.4442, "population": 471941},
    {"nom": "Nice", "lat": 43.7102, "lon": 7.2620, "population": 342637},
    {"nom": "Nantes", "lat": 47.2184, "lon": -1.5536, "population": 303382},
    {"nom": "Strasbourg", "lat": 48.5734, "lon": 7.7521, "population": 277270},
    {"nom": "Montpellier", "lat": 43.6110, "lon": 3.8767, "population": 277639},
    {"nom": "Bordeaux", "lat": 44.8378, "lon": -0.5792, "population": 249712},
    {"nom": "Lille", "lat": 50.6292, "lon": 3.0573, "population": 232741},
    {"nom": "Rennes", "lat": 48.1173, "lon": -1.6778, "population": 217728},
    {"nom": "Reims", "lat": 49.2583, "lon": 4.0317, "population": 182460},
    {"nom": "Le Havre", "lat": 49.4944, "lon": 0.1079, "population": 170147},
    {"nom": "Saint-Étienne", "lat": 45.4397, "lon": 4.3872, "population": 171017},
    {"nom": "Toulon", "lat": 43.1242, "lon": 5.9280, "population": 163760}
]

CONDITIONS_METEO = [
    "Ensoleillé", "Partiellement nuageux", "Nuageux", "Couvert", 
    "Bruine", "Pluie légère", "Pluie", "Pluie forte", "Orage",
    "Brouillard", "Neige légère", "Neige", "Grêle", "Vent fort"
]

class MeteoDemo:
    def __init__(self):
        self.connection = None
        
    def connect_to_iris(self):
        """Se connecte à IRIS dans l'espace de noms IRISAPP"""
        try:
            # Connexion avec la bibliothèque officielle InterSystems
            connection_string = {
                'hostname': 'localhost',
                'port': 1972,
                'namespace': 'IRISAPP',
                'username': '_SYSTEM',
                'password': 'SYS'
            }
            self.connection = iris_native.connect(**connection_string)
            print("✓ Connexion à IRIS établie (namespace: IRISAPP)")
            return True
        except Exception as e:
            print(f"✗ Erreur de connexion à IRIS: {e}")
            print("💡 Vérifiez que IRIS est démarré et que les paramètres sont corrects")
            return False
    
    def create_meteo_table(self):
        """Crée la table app.meteo avec colonne VECTOR"""
        try:
            # Supprimer la table si elle existe
            drop_sql = "DROP TABLE IF EXISTS app.meteo"
            self.cursor.execute(drop_sql)
            
            # Créer la nouvelle table avec colonne VECTOR
            create_sql = """
            CREATE TABLE app.meteo (
                id INTEGER IDENTITY PRIMARY KEY,
                ville VARCHAR(100) NOT NULL,
                date_bulletin TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                temperature DECIMAL(5,2),
                humidite INTEGER,
                pression DECIMAL(7,2),
                vent_vitesse DECIMAL(5,2),
                vent_direction VARCHAR(10),
                condition_meteo VARCHAR(50),
                description_bulletin VARCHAR(500),
                embedding_meteo VECTOR(DOUBLE, 128) -- Vector pour l'embedding des données météo
            )
            """
            self.cursor.execute(create_sql)
            self.connection.commit()
            print("✓ Table app.meteo créée avec succès")
            return True
        except Exception as e:
            print(f"✗ Erreur lors de la création de la table: {e}")
            return False
    
    def generate_meteo_embedding(self, temperature, humidite, pression, vent_vitesse, condition_index):
        """Génère un vecteur d'embedding pour les données météo (128 dimensions)"""
        # Normalisation des valeurs météo pour créer un embedding sémantique
        
        # Dimensions 0-9: Température (encodage thermique)
        temp_normalized = (temperature + 20) / 60  # Normalise entre -20°C et 40°C
        temp_encoding = [math.sin(temp_normalized * math.pi * i) for i in range(10)]
        
        # Dimensions 10-19: Humidité (encodage en pourcentage)
        hum_normalized = humidite / 100
        hum_encoding = [math.cos(hum_normalized * math.pi * i) for i in range(10)]
        
        # Dimensions 20-29: Pression (encodage barométrique)
        press_normalized = (pression - 900) / 200  # Normalise entre 900 et 1100 hPa
        press_encoding = [math.sin(press_normalized * math.pi * i) for i in range(10)]
        
        # Dimensions 30-39: Vitesse du vent
        wind_normalized = min(vent_vitesse / 100, 1)  # Normalise jusqu'à 100 km/h
        wind_encoding = [math.cos(wind_normalized * math.pi * i) for i in range(10)]
        
        # Dimensions 40-53: Conditions météo (one-hot-like encoding)
        condition_encoding = [0.0] * 14
        if condition_index < 14:
            condition_encoding[condition_index] = 1.0
        
        # Dimensions 54-63: Variations saisonnières
        seasonal_encoding = [random.gauss(0, 0.1) for _ in range(10)]
        
        # Dimensions 64-127: Noise et features complexes
        complex_features = []
        for i in range(64):
            # Combinaisons non-linéaires des features météo
            feature = (temp_normalized * math.sin(i)) + (hum_normalized * math.cos(i * 0.5))
            feature += (press_normalized * math.sin(i * 0.3)) + random.gauss(0, 0.05)
            complex_features.append(feature)
        
        # Combiner tous les encodages
        embedding = (temp_encoding + hum_encoding + press_encoding + 
                    wind_encoding + condition_encoding + seasonal_encoding + 
                    complex_features)
        
        return embedding[:128]  # S'assurer qu'on a exactement 128 dimensions
    
    def generate_bulletin_meteo(self, ville):
        """Génère un bulletin météo fictif pour une ville"""
        # Variation selon la latitude (plus froid au nord)
        temp_base = 15 + (ville["lat"] - 48) * 0.5
        
        # Variation saisonnière simplifiée
        today = datetime.now()
        seasonal_factor = math.sin((today.month - 6) * math.pi / 6)
        
        # Génération des données météo
        temperature = round(temp_base + seasonal_factor * 10 + random.gauss(0, 3), 1)
        humidite = max(20, min(100, int(60 + random.gauss(0, 15))))
        pression = round(1013 + random.gauss(0, 15), 1)
        vent_vitesse = round(max(0, random.gauss(15, 8)), 1)
        
        directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        vent_direction = random.choice(directions)
        
        condition_index = random.randint(0, len(CONDITIONS_METEO) - 1)
        condition = CONDITIONS_METEO[condition_index]
        
        # Génération d'une description narrative
        descriptions = [
            f"Ciel {condition.lower()} sur {ville['nom']}. Température agréable à {temperature}°C.",
            f"Conditions {condition.lower()} observées. Vent de {vent_direction} à {vent_vitesse} km/h.",
            f"Bulletin météo pour {ville['nom']}: {condition}, ressenti {temperature}°C avec {humidite}% d'humidité.",
            f"Météo du jour: {condition.lower()}, baromètre à {pression} hPa, vent modéré."
        ]
        description = random.choice(descriptions)
        
        # Génération de l'embedding
        embedding = self.generate_meteo_embedding(temperature, humidite, pression, 
                                                 vent_vitesse, condition_index)
        
        return {
            "ville": ville["nom"],
            "temperature": temperature,
            "humidite": humidite,
            "pression": pression,
            "vent_vitesse": vent_vitesse,
            "vent_direction": vent_direction,
            "condition_meteo": condition,
            "description": description,
            "embedding": embedding
        }
    
    def insert_bulletins_meteo(self, nombre_bulletins=50):
        """Insère des bulletins météo fictifs dans la base"""
        try:
            bulletins_inseres = 0
            
            for i in range(nombre_bulletins):
                ville = random.choice(VILLES_FRANCAISES)
                bulletin = self.generate_bulletin_meteo(ville)
                
                # Date aléatoire dans les 30 derniers jours
                date_bulletin = datetime.now() - timedelta(days=random.randint(0, 30))
                
                # Insertion avec TO_VECTOR pour l'embedding
                insert_sql = """
                INSERT INTO app.meteo (
                    ville, date_bulletin, temperature, humidite, pression,
                    vent_vitesse, vent_direction, condition_meteo, description_bulletin,
                    embedding_meteo
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TO_VECTOR(?, 'DOUBLE'))
                """
                
                # Utilisation de l'API IRIS native
                iris_call = iris_native.execute_query(
                    self.connection,
                    insert_sql,
                    bulletin["ville"],
                    date_bulletin.strftime("%Y-%m-%d %H:%M:%S"),
                    bulletin["temperature"],
                    bulletin["humidite"],
                    bulletin["pression"],
                    bulletin["vent_vitesse"],
                    bulletin["vent_direction"],
                    bulletin["condition_meteo"],
                    bulletin["description"],
                    json.dumps(bulletin["embedding"])
                )
                
                bulletins_inseres += 1
                if bulletins_inseres % 10 == 0:
                    print(f"  → {bulletins_inseres} bulletins insérés...")
            
            self.connection.commit()
            print(f"✓ {bulletins_inseres} bulletins météo insérés avec succès")
            return True
            
        except Exception as e:
            print(f"✗ Erreur lors de l'insertion: {e}")
            return False
    
    def recherche_bulletins_similaires(self, ville_reference, limite=5):
        """Trouve les bulletins météo similaires à une ville donnée"""
        try:
            print(f"\n🔍 Recherche de bulletins similaires à {ville_reference}...")
            
            # Obtenir le vecteur de référence
            ref_sql = """
            SELECT ville, temperature, humidite, condition_meteo, embedding_meteo
            FROM app.meteo 
            WHERE ville = ?
            ORDER BY date_bulletin DESC
            LIMIT 1
            """
            self.cursor.execute(ref_sql, [ville_reference])
            ref_result = self.cursor.fetchone()
            
            if not ref_result:
                print(f"✗ Aucun bulletin trouvé pour {ville_reference}")
                return
            
            print(f"📋 Bulletin de référence: {ref_result[0]} - {ref_result[1]}°C, {ref_result[2]}% humidité, {ref_result[3]}")
            
            # Recherche par similarité vectorielle
            similarity_sql = """
            SELECT 
                ville,
                temperature,
                humidite,
                condition_meteo,
                description_bulletin,
                VECTOR_COSINE(embedding_meteo, (
                    SELECT embedding_meteo FROM app.meteo 
                    WHERE ville = ? 
                    ORDER BY date_bulletin DESC LIMIT 1
                )) as similarite
            FROM app.meteo 
            WHERE ville != ?
            ORDER BY similarite DESC
            LIMIT ?
            """
            
            self.cursor.execute(similarity_sql, [ville_reference, ville_reference, limite])
            results = self.cursor.fetchall()
            
            print(f"\n📊 Top {limite} bulletins les plus similaires:")
            print("-" * 80)
            
            for i, result in enumerate(results, 1):
                ville, temp, hum, condition, description, similarite = result
                print(f"{i:2}. {ville:12} | {temp:5.1f}°C | {hum:3}% | {condition:15} | Sim: {similarite:.3f}")
                print(f"    📝 {description[:70]}...")
                print()
            
        except Exception as e:
            print(f"✗ Erreur lors de la recherche: {e}")
    
    def recherche_par_conditions(self, temp_min=None, temp_max=None, condition=None):
        """Recherche de bulletins avec des critères spécifiques"""
        try:
            print(f"\n🔎 Recherche avec critères personnalisés...")
            
            where_clauses = []
            params = []
            
            if temp_min is not None:
                where_clauses.append("temperature >= ?")
                params.append(temp_min)
            
            if temp_max is not None:
                where_clauses.append("temperature <= ?")
                params.append(temp_max)
            
            if condition:
                where_clauses.append("condition_meteo LIKE ?")
                params.append(f"%{condition}%")
            
            where_sql = " AND ".join(where_clauses) if where_clauses else "1=1"
            
            search_sql = f"""
            SELECT ville, date_bulletin, temperature, humidite, condition_meteo, description_bulletin
            FROM app.meteo 
            WHERE {where_sql}
            ORDER BY date_bulletin DESC
            LIMIT 10
            """
            
            self.cursor.execute(search_sql, params)
            results = self.cursor.fetchall()
            
            print(f"📋 Résultats trouvés: {len(results)} bulletins")
            print("-" * 80)
            
            for result in results:
                ville, date, temp, hum, condition, description = result
                print(f"🏙️  {ville:12} | {date.strftime('%d/%m %H:%M'):12} | {temp:5.1f}°C | {condition}")
                print(f"   📝 {description[:65]}...")
                print()
                
        except Exception as e:
            print(f"✗ Erreur lors de la recherche: {e}")
    
    def afficher_statistiques(self):
        """Affiche des statistiques sur les données météo"""
        try:
            print("\n📊 Statistiques des données météo:")
            print("=" * 50)
            
            # Nombre total de bulletins
            count_sql = "SELECT COUNT(*) FROM app.meteo"
            self.cursor.execute(count_sql)
            total = self.cursor.fetchone()[0]
            print(f"📈 Total des bulletins: {total}")
            
            # Bulletins par ville
            city_sql = """
            SELECT ville, COUNT(*) as nb_bulletins
            FROM app.meteo 
            GROUP BY ville 
            ORDER BY nb_bulletins DESC
            LIMIT 5
            """
            self.cursor.execute(city_sql)
            city_results = self.cursor.fetchall()
            
            print(f"\n🏙️  Top 5 villes (nb bulletins):")
            for ville, count in city_results:
                print(f"   {ville:12}: {count:3} bulletins")
            
            # Statistiques de température
            temp_sql = """
            SELECT 
                MIN(temperature) as temp_min,
                MAX(temperature) as temp_max,
                AVG(temperature) as temp_moy
            FROM app.meteo
            """
            self.cursor.execute(temp_sql)
            temp_min, temp_max, temp_moy = self.cursor.fetchone()
            
            print(f"\n🌡️  Températures:")
            print(f"   Minimum: {temp_min:.1f}°C")
            print(f"   Maximum: {temp_max:.1f}°C")
            print(f"   Moyenne: {temp_moy:.1f}°C")
            
            # Conditions les plus fréquentes
            condition_sql = """
            SELECT condition_meteo, COUNT(*) as frequence
            FROM app.meteo 
            GROUP BY condition_meteo 
            ORDER BY frequence DESC
            LIMIT 5
            """
            self.cursor.execute(condition_sql)
            condition_results = self.cursor.fetchall()
            
            print(f"\n☁️  Conditions les plus fréquentes:")
            for condition, freq in condition_results:
                print(f"   {condition:15}: {freq:3} fois")
        
        except Exception as e:
            print(f"✗ Erreur lors du calcul des statistiques: {e}")
    
    def close_connection(self):
        """Ferme la connexion à IRIS"""
        if self.connection:
            self.connection.close()
            print("✓ Connexion fermée")

def main():
    """Fonction principale de démonstration"""
    demo = MeteoDemo()
    
    print("🌤️  DÉMO MÉTÉO AVEC VECTORS IRIS")
    print("=" * 40)
    
    # Étape 1: Connexion
    if not demo.connect_to_iris():
        return
    
    # Étape 2: Création de table
    if not demo.create_meteo_table():
        return
    
    # Étape 3: Insertion de données
    print("\n📥 Insertion de bulletins météo...")
    if not demo.insert_bulletins_meteo(30):
        return
    
    # Étape 4: Recherches de démonstration
    print("\n" + "=" * 50)
    print("🔍 DÉMONSTRATIONS DE RECHERCHE")
    print("=" * 50)
    
    # Recherche par similarité vectorielle
    demo.recherche_bulletins_similaires("Paris", 5)
    
    # Recherche par conditions
    demo.recherche_par_conditions(temp_min=20, condition="Ensoleillé")
    
    # Recherche par plage de température
    demo.recherche_par_conditions(temp_min=5, temp_max=15)
    
    # Affichage des statistiques
    demo.afficher_statistiques()
    
    # Nettoyage
    demo.close_connection()
    print("\n✨ Démonstration terminée!")

if __name__ == "__main__":
    main()