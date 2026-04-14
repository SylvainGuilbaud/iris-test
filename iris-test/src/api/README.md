# API Patient REST - Guide d'utilisation et exemples

## Installation et Configuration

### 1. Installation de l'API
```objectscript
// Dans le terminal IRIS
USER> do ##class(api.ConfigSetup).Install()
```

### 2. Vérification du statut
```objectscript
USER> do ##class(api.ConfigSetup).Status()
```

### 3. Test de l'API
```objectscript
USER> do ##class(api.ConfigSetup).Test()
```

### 4. Désinstallation (si nécessaire)
```objectscript
USER> do ##class(api.ConfigSetup).Uninstall()
```

## Endpoints de l'API

**URL de base :** `http://localhost:52773/api/v1`

### 1. Récupérer tous les patients
```bash
# Récupérer tous les patients
curl -X GET "http://localhost:52773/api/v1/patient"

# Avec pagination
curl -X GET "http://localhost:52773/api/v1/patient?limit=10&offset=0"
```

### 2. Récupérer un patient par ID
```bash
curl -X GET "http://localhost:52773/api/v1/patient/1"
```

### 3. Créer un nouveau patient
```bash
curl -X POST "http://localhost:52773/api/v1/patient" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "P004",
    "medicalRecordNumber": "MRN901234",
    "firstName": "Sophie",
    "lastName": "Lemoine",
    "dateOfBirth": "1985-09-12",
    "gender": "F",
    "phone": "+33-2-34-56-78-90",
    "email": "sophie.lemoine@email.com",
    "address": {
      "addressLine1": "12 Rue Victor Hugo",
      "addressLine2": "",
      "city": "Toulouse",
      "state": "Occitanie",
      "postalCode": "31000",
      "country": "France"
    }
  }'
```

### 4. Modifier un patient existant
```bash
curl -X PUT "http://localhost:52773/api/v1/patient/1" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+33-1-99-88-77-66",
    "email": "nouveau.email@example.com",
    "address": {
      "addressLine1": "456 Nouvelle Adresse",
      "city": "Paris",
      "state": "Île-de-France",
      "postalCode": "75002",
      "country": "France"
    }
  }'
```

### 5. Supprimer un patient
```bash
curl -X DELETE "http://localhost:52773/api/v1/patient/1"
```

### 6. Rechercher des patients
```bash
# Recherche par nom
curl -X GET "http://localhost:52773/api/v1/patient/search?lastName=Dupont"

# Recherche par prénom
curl -X GET "http://localhost:52773/api/v1/patient/search?firstName=Jean"

# Recherche par email
curl -X GET "http://localhost:52773/api/v1/patient/search?email=@email.com"

# Recherche combinée
curl -X GET "http://localhost:52773/api/v1/patient/search?firstName=Marie&lastName=Martin"

# Recherche avec pagination
curl -X GET "http://localhost:52773/api/v1/patient/search?lastName=Du&limit=5&offset=0"
```

## Exemples de réponses JSON

### Réponse successful - Liste de patients
```json
{
  "data": [
    {
      "id": "1",
      "patientId": "P001",
      "medicalRecordNumber": "MRN123456",
      "firstName": "Jean",
      "lastName": "Dupont",
      "dateOfBirth": "1980-06-15",
      "gender": "M",
      "phone": "+33-1-23-45-67-89",
      "email": "jean.dupont@email.com",
      "address": {
        "addressLine1": "123 Rue de la Paix",
        "addressLine2": "",
        "city": "Paris",
        "state": "Île-de-France",
        "postalCode": "75001",
        "country": "France"
      }
    }
  ],
  "pagination": {
    "limit": 50,
    "offset": 0,
    "count": 1,
    "total": 3
  }
}
```

### Réponse d'erreur
```json
{
  "error": "Validation Error",
  "message": "First name is required",
  "timestamp": "2026-04-14 10:30:45",
  "statusCode": 400
}
```

## Validation des données

### Champs obligatoires (création)
- `firstName` - Prénom du patient
- `lastName` - Nom de famille du patient

### Validations automatiques
- **Email** : Format email valide si fourni
- **Date de naissance** : Format YYYY-MM-DD, ne peut pas être dans le futur
- **Genre** : Valeurs acceptées : M, F, Male, Female, Other, Unknown

### Limites de longueur
- `patientId` : 50 caractères max
- `medicalRecordNumber` : 50 caractères max
- `firstName` : 100 caractères max
- `lastName` : 100 caractères max
- `gender` : 20 caractères max
- `phone` : 30 caractères max
- `email` : 255 caractères max
- `addressLine1/2` : 255 caractères max
- `city` : 100 caractères max
- `state` : 100 caractères max
- `postalCode` : 20 caractères max
- `country` : 100 caractères max

## Tests avec Python

### Exemple de script Python pour tester l'API
```python
import requests
import json

base_url = "http://localhost:52773/api/v1"

# Test GET all patients
response = requests.get(f"{base_url}/patient")
print(f"GET all patients: {response.status_code}")
if response.status_code == 200:
    data = response.json()
    print(f"Nombre de patients: {data['pagination']['total']}")

# Test CREATE patient
new_patient = {
    "patientId": "P999",
    "medicalRecordNumber": "TEST999",
    "firstName": "Test",
    "lastName": "Patient",
    "dateOfBirth": "1990-01-01",
    "gender": "M",
    "phone": "+33-1-00-00-00-00",
    "email": "test@example.com",
    "address": {
        "addressLine1": "Test Address",
        "city": "Test City",
        "state": "Test State",
        "postalCode": "12345",
        "country": "France"
    }
}

response = requests.post(f"{base_url}/patient", 
                        json=new_patient, 
                        headers={"Content-Type": "application/json"})
print(f"CREATE patient: {response.status_code}")
if response.status_code == 201:
    created_patient = response.json()
    patient_id = created_patient["id"]
    print(f"Patient créé avec ID: {patient_id}")
    
    # Test GET specific patient
    response = requests.get(f"{base_url}/patient/{patient_id}")
    print(f"GET patient {patient_id}: {response.status_code}")
    
    # Test UPDATE patient
    update_data = {"phone": "+33-1-11-11-11-11"}
    response = requests.put(f"{base_url}/patient/{patient_id}", 
                           json=update_data,
                           headers={"Content-Type": "application/json"})
    print(f"UPDATE patient {patient_id}: {response.status_code}")
    
    # Test DELETE patient
    response = requests.delete(f"{base_url}/patient/{patient_id}")
    print(f"DELETE patient {patient_id}: {response.status_code}")

# Test SEARCH
response = requests.get(f"{base_url}/patient/search?firstName=Jean")
print(f"SEARCH patients: {response.status_code}")
if response.status_code == 200:
    data = response.json()
    print(f"Patients trouvés: {data['pagination']['count']}")
```

## Tests avec Postman

### Collection Postman
Vous pouvez créer une collection Postman avec les endpoints suivants :

1. **GET All Patients**
   - URL: `GET {{base_url}}/patient`
   - Variables: `base_url = http://localhost:52773/api/v1`

2. **GET Patient by ID**
   - URL: `GET {{base_url}}/patient/{{patient_id}}`
   - Variables: `patient_id = 1`

3. **CREATE Patient**
   - URL: `POST {{base_url}}/patient`
   - Headers: `Content-Type: application/json`
   - Body: Raw JSON (voir exemple ci-dessus)

4. **UPDATE Patient**
   - URL: `PUT {{base_url}}/patient/{{patient_id}}`
   - Headers: `Content-Type: application/json`
   - Body: Raw JSON avec les champs à modifier

5. **DELETE Patient**
   - URL: `DELETE {{base_url}}/patient/{{patient_id}}`

6. **SEARCH Patients**
   - URL: `GET {{base_url}}/patient/search`
   - Params: `firstName`, `lastName`, `email`, etc.

## Troubleshooting

### Erreurs communes

1. **404 - Application not found**
   ```
   Solution: Vérifiez que l'API est installée avec do ##class(api.ConfigSetup).Install()
   ```

2. **500 - Compilation error**
   ```
   Solution: Recompilez les classes avec $system.OBJ.CompileList("data.patient,api.PatientAPI,api.PatientWebApp","ck")
   ```

3. **400 - Validation error**
   ```
   Solution: Vérifiez que les champs obligatoires (firstName, lastName) sont fournis
   ```

### Vérifications de santé
```objectscript
// Vérifier si l'application web existe
USER> write ##class(%REST.API).IsApplicationAvailable("/api/v1")

// Compter les patients
USER> &sql(SELECT COUNT(*) FROM data.patient)

// Vérifier la compilation des classes
USER> write $system.OBJ.IsUpToDate("api.PatientAPI")
```