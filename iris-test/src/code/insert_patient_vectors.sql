-- SQL examples for inserting data into app.patient with vector column
-- Run these directly in IRIS SQL interface or terminal

-- Example 1: Insert with a simple vector
INSERT INTO app.patient (name, comment) 
VALUES ('Alice Johnson', TO_VECTOR('[0.1,0.2,0.3,0.4,0.5]', 'DOUBLE'));

-- Example 2: Insert with a full 256-dimensional vector (zeros)
INSERT INTO app.patient (name, comment) 
VALUES ('Zero Vector Patient', TO_VECTOR('[' || $LISTBUILD($REPEAT("0,", 255) || "0") || ']', 'DOUBLE'));

-- Example 3: Insert with incremental values
INSERT INTO app.patient (name, comment) 
VALUES ('Incremental Patient', TO_VECTOR('[0.001,0.002,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.010,0.011,0.012,0.013,0.014,0.015,0.016]', 'DOUBLE'));

-- Example 4: Medical condition embedding (simulation)
-- Diabetes patient with simulated medical vector
INSERT INTO app.patient (name, comment) 
VALUES ('Diabetes Patient', 
TO_VECTOR('[0.8,0.7,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3,0.4,0.5,0.7,0.8,0.2,0.1,0.9,0.6,0.3]', 'DOUBLE'));

-- Example 5: Cardiac patient vector
INSERT INTO app.patient (name, comment) 
VALUES ('Cardiac Patient', 
TO_VECTOR('[0.2,0.9,0.8,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6,0.4,0.5,0.8,0.2,0.9,0.7,0.1,0.3,0.6]', 'DOUBLE'));

-- Query to verify the insertions
SELECT ID, name, VECTOR_DIMENSIONS(comment) as dimensions, VECTOR_DOT_PRODUCT(comment, comment) as magnitude 
FROM app.patient;

-- Find similar patients using vector similarity
SELECT p1.name as patient1, p2.name as patient2, 
       VECTOR_DOT_PRODUCT(p1.comment, p2.comment) as similarity
FROM app.patient p1, app.patient p2
WHERE p1.ID < p2.ID
ORDER BY similarity DESC;

-- Find patients with vectors similar to a query vector
SELECT name, VECTOR_DOT_PRODUCT(comment, TO_VECTOR('[0.8,0.7,0.2,0.1]', 'DOUBLE')) as similarity
FROM app.patient
ORDER BY similarity DESC;