-- Script météo IRIS simplifié
-- Version sans accents pour compatibilité

-- Nettoyage
DROP TABLE IF EXISTS app.meteo;

-- Création de table
CREATE TABLE app.meteo (
    id INTEGER IDENTITY PRIMARY KEY,
    ville VARCHAR(100) NOT NULL,
    temperature DECIMAL(5,2),
    condition_meteo VARCHAR(50),
    embedding_meteo VECTOR(DOUBLE, 4)
);

-- Données simplifiées (4 dimensions pour test)
INSERT INTO app.meteo (ville, temperature, condition_meteo, embedding_meteo)
VALUES ('Paris', 18.5, 'Ensoleille', TO_VECTOR('[0.1, 0.2, 0.3, 0.4]', 'DOUBLE'));

INSERT INTO app.meteo (ville, temperature, condition_meteo, embedding_meteo)  
VALUES ('Lyon', 16.2, 'Nuageux', TO_VECTOR('[0.2, 0.1, 0.4, 0.3]', 'DOUBLE'));

INSERT INTO app.meteo (ville, temperature, condition_meteo, embedding_meteo)
VALUES ('Marseille', 22.1, 'Ensoleille', TO_VECTOR('[0.15, 0.25, 0.35, 0.45]', 'DOUBLE'));

INSERT INTO app.meteo (ville, temperature, condition_meteo, embedding_meteo)
VALUES ('Toulouse', 19.8, 'Pluie', TO_VECTOR('[0.8, 0.2, 0.1, 0.9]', 'DOUBLE'));

INSERT INTO app.meteo (ville, temperature, condition_meteo, embedding_meteo)
VALUES ('Nice', 24.3, 'Ensoleille', TO_VECTOR('[0.12, 0.22, 0.32, 0.42]', 'DOUBLE'));

-- Verification
SELECT COUNT(*) as total FROM app.meteo;

-- Test de similarité vectorielle
SELECT 
    ville,
    temperature,
    condition_meteo,
    ROUND(VECTOR_COSINE(embedding_meteo, (SELECT embedding_meteo FROM app.meteo WHERE ville = 'Paris')), 3) as similarite
FROM app.meteo 
WHERE ville != 'Paris'
ORDER BY similarite DESC;