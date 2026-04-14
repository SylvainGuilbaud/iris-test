Class api.ConfigSetup
{

/// Install and configure the Patient API
ClassMethod Install() As %Status
{
    Set tSC = $$$OK
    Try {
        Write "===========================================", !
        Write "Installation de l'API Patient REST", !
        Write "===========================================", !
        
        // Compile classes
        Write "Compilation des classes...", !
        Set tSC = $system.OBJ.CompileList("data.patient,api.PatientAPI,api.PatientWebApp", "ck")
        If $$$ISERR(tSC) {
            Write "Erreur lors de la compilation: ", $System.Status.GetErrorText(tSC), !
            Return tSC
        }
        Write "Compilation réussie!", !
        
        // Setup web application
        Write "Configuration de l'application web...", !
        Set tSC = ##class(api.PatientWebApp).Setup()
        If $$$ISERR(tSC) {
            Write "Erreur lors de la configuration: ", $System.Status.GetErrorText(tSC), !
            Return tSC
        }
        
        // Create test data
        Write "Création de données de test...", !
        Do ..CreateTestData()
        
        Write "===========================================", !
        Write "Installation terminée avec succès!", !
        Write "===========================================", !
        Write "L'API Patient REST est maintenant disponible", !
        Write "URL de base: http://localhost:52773/api/v1", !
        Write "===========================================", !
        
        // Display documentation
        Write ##class(api.PatientWebApp).GetApiDocumentation(), !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Write "Erreur durant l'installation: ", ex.DisplayString(), !
    }
    
    Return tSC
}

/// Create test data
ClassMethod CreateTestData() As %Status
{
    Set tSC = $$$OK
    Try {
        // Patient 1
        Set patient1 = ##class(data.patient).%New()
        Set patient1.PatientId = "P001"
        Set patient1.MedicalRecordNumber = "MRN123456"
        Set patient1.FirstName = "Jean"
        Set patient1.LastName = "Dupont"
        Set patient1.DateOfBirth = $zdh("1980-06-15", 3)
        Set patient1.Gender = "M"
        Set patient1.Phone = "+33-1-23-45-67-89"
        Set patient1.Email = "jean.dupont@email.com"
        Set patient1.AddressLine1 = "123 Rue de la Paix"
        Set patient1.City = "Paris"
        Set patient1.State = "Île-de-France"
        Set patient1.PostalCode = "75001"
        Set patient1.Country = "France"
        
        Set status = patient1.%Save()
        If $$$ISERR(status) {
            Write "Erreur patient 1: ", $System.Status.GetErrorText(status), !
        } Else {
            Write "Patient 1 créé (ID: ", patient1.%Id(), ")", !
        }
        
        // Patient 2
        Set patient2 = ##class(data.patient).%New()
        Set patient2.PatientId = "P002"
        Set patient2.MedicalRecordNumber = "MRN789012"
        Set patient2.FirstName = "Marie"
        Set patient2.LastName = "Martin"
        Set patient2.DateOfBirth = $zdh("1975-03-22", 3)
        Set patient2.Gender = "F"
        Set patient2.Phone = "+33-1-98-76-54-32"
        Set patient2.Email = "marie.martin@email.com"
        Set patient2.AddressLine1 = "456 Avenue des Champs"
        Set patient2.AddressLine2 = "Appartement 5B"
        Set patient2.City = "Lyon"
        Set patient2.State = "Auvergne-Rhône-Alpes"
        Set patient2.PostalCode = "69001"
        Set patient2.Country = "France"
        
        Set status = patient2.%Save()
        If $$$ISERR(status) {
            Write "Erreur patient 2: ", $System.Status.GetErrorText(status), !
        } Else {
            Write "Patient 2 créé (ID: ", patient2.%Id(), ")", !
        }
        
        // Patient 3
        Set patient3 = ##class(data.patient).%New()
        Set patient3.PatientId = "P003"
        Set patient3.MedicalRecordNumber = "MRN345678"
        Set patient3.FirstName = "Pierre"
        Set patient3.LastName = "Durand"
        Set patient3.DateOfBirth = $zdh("1990-12-08", 3)
        Set patient3.Gender = "M"
        Set patient3.Phone = "+33-4-56-78-90-12"
        Set patient3.Email = "pierre.durand@email.com"
        Set patient3.AddressLine1 = "789 Boulevard Saint-Germain"
        Set patient3.City = "Marseille"
        Set patient3.State = "Provence-Alpes-Côte d'Azur"
        Set patient3.PostalCode = "13001"
        Set patient3.Country = "France"
        
        Set status = patient3.%Save()
        If $$$ISERR(status) {
            Write "Erreur patient 3: ", $System.Status.GetErrorText(status), !
        } Else {
            Write "Patient 3 créé (ID: ", patient3.%Id(), ")", !
        }
        
        Write "Données de test créées avec succès!", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Write "Erreur création données: ", ex.DisplayString(), !
    }
    
    Return tSC
}

/// Remove the Patient API
ClassMethod Uninstall() As %Status
{
    Set tSC = $$$OK
    Try {
        Write "Suppression de l'API Patient...", !
        
        Set tSC = ##class(api.PatientWebApp).Remove()
        If $$$ISERR(tSC) {
            Write "Erreur suppression: ", $System.Status.GetErrorText(tSC), !
            Return tSC
        }
        
        Write "API Patient supprimée avec succès!", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Write "Erreur: ", ex.DisplayString(), !
    }
    
    Return tSC
}

/// Test the API endpoints
ClassMethod Test() As %Status
{
    Set tSC = $$$OK
    Try {
        Write "Test de l'API Patient...", !
        Write "========================", !
        
        // Test GET all patients
        Write "Test GET /api/v1/patient...", !
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "localhost"
        Set request.Port = 52773
        Set request.Https = 0
        
        Set status = request.Get("/api/v1/patient")
        
        If $$$ISOK(status) {
            Write "Statut: ", request.HttpResponse.StatusCode, !
            If request.HttpResponse.StatusCode = 200 {
                Write "✓ GET tous les patients - OK", !
            } Else {
                Write "✗ GET tous les patients - ERREUR", !
            }
        } Else {
            Write "✗ Erreur requête: ", $System.Status.GetErrorText(status), !
        }
        
        // Test GET patient by ID
        Write "Test GET /api/v1/patient/1...", !
        Set request2 = ##class(%Net.HttpRequest).%New()
        Set request2.Server = "localhost"
        Set request2.Port = 52773
        Set request2.Https = 0
        
        Set status = request2.Get("/api/v1/patient/1")
        
        If $$$ISOK(status) {
            Write "Statut: ", request2.HttpResponse.StatusCode, !
            If request2.HttpResponse.StatusCode = 200 {
                Write "✓ GET patient par ID - OK", !
            } ElseIf request2.HttpResponse.StatusCode = 404 {
                Write "⚠ Patient ID 1 non trouvé (normal si pas de données)", !
            } Else {
                Write "✗ GET patient par ID - ERREUR", !
            }
        } Else {
            Write "✗ Erreur requête: ", $System.Status.GetErrorText(status), !
        }
        
        Write "Tests terminés!", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Write "Erreur durant les tests: ", ex.DisplayString(), !
    }
    
    Return tSC
}

/// Show API status and information
ClassMethod Status() As %Status
{
    Try {
        Write "===========================================", !
        Write "Statut de l'API Patient REST", !
        Write "===========================================", !
        
        // Check if web application exists
        Set webappExists = ##class(%REST.API).IsApplicationAvailable("/api/v1")
        Write "Application web /api/v1: "
        If webappExists {
            Write "✓ Active", !
        } Else {
            Write "✗ Non configurée", !
        }
        
        // Count patients
        Set sql = "SELECT COUNT(*) As Total FROM data.patient"
        Set statement = ##class(%SQL.Statement).%New()
        Do statement.%Prepare(sql)
        Set rset = statement.%Execute()
        Set total = 0
        If rset.%Next() Set total = rset.%Get("Total")
        
        Write "Nombre de patients: ", total, !
        
        // Show endpoints
        Write !, "Endpoints disponibles:", !
        Write "  GET    /api/v1/patient         - Tous les patients", !
        Write "  GET    /api/v1/patient/:id     - Patient par ID", !
        Write "  POST   /api/v1/patient         - Créer patient", !
        Write "  PUT    /api/v1/patient/:id     - Modifier patient", !
        Write "  DELETE /api/v1/patient/:id     - Supprimer patient", !
        Write "  GET    /api/v1/patient/search  - Rechercher patients", !
        
        Write !, "URL de base: http://localhost:52773/api/v1", !
        
    } Catch ex {
        Write "Erreur: ", ex.DisplayString(), !
    }
    
    Return $$$OK
}

}