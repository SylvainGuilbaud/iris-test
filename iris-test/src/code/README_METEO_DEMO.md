# Démo Météo avec Vektors IRIS

Cette démo illustre l'utilisation des types VECTOR d'IRIS pour gérer des bulletins météo des grandes villes françaises avec des fonctionnalités de recherche par similarité vectorielle.

## 🌤️ Vue d'ensemble

La démo comprend:
- Une table `app.meteo` avec des colonnes pour les données météo et un VECTOR d'embedding
- Des bulletins météo fictifs pour 15 grandes villes françaises
- Des recherches par similarité vectorielle et par critères
- Des statistiques sur les données météo

## 📁 Fichiers de la démonstration

### 1. Scripts Python
- **`meteo_demo.py`** - Script principal de démonstration en Python
  - Connexion à IRIS (namespace IRISAPP)
  - Création de la table avec colonne VECTOR
  - Génération et insertion de données météo
  - Recherches et analyses

### 2. Classes ObjectScript
- **`meteo.cls`** - Classe IRIS pour la table app.meteo
  - Définition des propriétés avec VECTOR
  - Méthodes pour insérer et rechercher des données
  - Génération de données fictives

## 🚀 Comment exécuter la démo

### Prérequis
- IRIS en fonctionnement sur localhost:1972
- Namespace IRISAPP configuré
- Bibliothèque Python `iris` installée

### Étape 1: Exécution du script Python
```bash
cd /Users/guilbaud/git/iris-test/iris-test/src/code/
python3 meteo_demo.py
```

### Étape 2: Utilisation des méthodes ObjectScript
Connectez-vous au terminal IRIS et exécutez:

```objectscript
// Se connecter à IRISAPP
SET $NAMESPACE = "IRISAPP"

// Générer des données fictives
DO ##class(app.meteo).GenererDonneesFictives(30)

// Rechercher des bulletins similaires à Paris
DO ##class(app.meteo).RechercherBulletinsSimilaires("Paris", 5)

// Rechercher par critères de température
DO ##class(app.meteo).RechercherParCriteres(20, 30, "Ensoleillé")

// Afficher les statistiques
DO ##class(app.meteo).AfficherStatistiques()
```

## 📊 Structure des données

### Table app.meteo
| Colonne | Type | Description |
|---------|------|-------------|
| id | INTEGER | Clé primaire auto-incrémentée |
| ville | VARCHAR(100) | Nom de la ville |
| date_bulletin | TIMESTAMP | Date et heure du bulletin |
| temperature | DECIMAL(5,2) | Température en °C |
| humidite | INTEGER | Pourcentage d'humidité |
| pression | DECIMAL(7,2) | Pression atmosphérique en hPa |
| vent_vitesse | DECIMAL(5,2) | Vitesse du vent en km/h |
| vent_direction | VARCHAR(10) | Direction du vent (N, NE, E, etc.) |
| condition_meteo | VARCHAR(50) | Condition (Ensoleillé, Nuageux, etc.) |
| description_bulletin | VARCHAR(500) | Description textuelle |
| **embedding_meteo** | **VECTOR(DOUBLE, 128)** | **Vekteur d'embedding météo** |

### Villes françaises incluses
Paris, Marseille, Lyon, Toulouse, Nice, Nantes, Strasbourg, Montpellier, Bordeaux, Lille, Rennes, Reims, Le Havre, Saint-Étienne, Toulon

## 🔍 Fonctionnalités de recherche

### 1. Recherche par similarité vectorielle
La démo utilise `VECTOR_COSINE()` pour trouver des bulletins météo similaires basés sur l'embedding à 128 dimensions qui encode:
- Température (dimensions 0-9)
- Humidité (dimensions 10-19) 
- Pression (dimensions 20-29)
- Vitesse du vent (dimensions 30-39)
- Conditions météo (dimensions 40-53)
- Variations saisonnières (dimensions 54-63)
- Features complexes (dimensions 64-127)

### 2. Recherche par critères
- Filtre par plage de température
- Filtre par condition météo
- Combinaison de critères multiples

### 3. Statistiques
- Nombre total de bulletins
- Répartition par ville
- Statistiques de température (min, max, moyenne)
- Conditions météo les plus fréquentes

## 🧮 Algorithmes d'embedding

L'embedding vectoriel est généré en combinant:

1. **Encodage thermique**: Température normalisée avec fonctions sinusoïdales
2. **Encodage humidité**: Pourcentage d'humidité avec fonctions cosinusoïdales  
3. **Encodage barométrique**: Pression atmosphérique normalisée
4. **Encodage éolien**: Vitesse du vent normalisée
5. **Encodage conditions**: Représentation pseudo one-hot des conditions météo
6. **Features saisonnières**: Variations temporelles
7. **Features complexes**: Combinaisons non-linéaires des paramètres météo

## 📈 Exemple de requêtes SQL

### Recherche par similarité
```sql
SELECT ville, temperature, condition_meteo,
       VECTOR_COSINE(embedding_meteo, 
                    (SELECT embedding_meteo FROM app.meteo 
                     WHERE ville = 'Paris' 
                     ORDER BY date_bulletin DESC LIMIT 1)) as similarite
FROM app.meteo 
WHERE ville != 'Paris'
ORDER BY similarite DESC
LIMIT 5
```

### Recherche par critères
```sql
SELECT ville, temperature, humidite, condition_meteo
FROM app.meteo 
WHERE temperature BETWEEN 15 AND 25
  AND condition_meteo LIKE '%Ensoleillé%'
ORDER BY date_bulletin DESC
```

## 🎯 Cas d'usage démontrés

1. **Prédiction météo**: Trouver des villes avec des conditions similaires
2. **Analyse climatique**: Grouper des bulletins par similarité météo
3. **Recommandations**: Suggérer des destinations avec un climat souhaité
4. **Détection d'anomalies**: Identifier des conditions météo inhabituelles
5. **Classification automatique**: Regrouper des conditions météo similaires

## 🔧 Personnalisation

Pour adapter la démo à vos besoins:

1. **Modifier les villes**: Éditez la liste `VILLES_FRANCAISES` dans `meteo_demo.py`
2. **Ajuster l'embedding**: Modifiez `generate_meteo_embedding()` pour d'autres features
3. **Étendre les conditions**: Ajoutez des conditions météo dans `CONDITIONS_METEO`
4. **Changer les dimensions**: Modifiez la taille du vekteur (par défaut 128)

## 📋 Notes techniques

- Les vekteurs sont stockés au format DOUBLE avec 128 dimensions
- La similarité vectorielle utilise la distance cosinus
- Les embeddings sont générés via des fonctions mathématiques deterministes
- La démo supporte la recherche en temps réel
- Les données sont persistées dans l'extent IRIS standard

---
*Démo créée pour illustrer les capacités des vektors IRIS avec des données météo française* 🇫🇷