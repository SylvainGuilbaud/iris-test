Class api.PatientWebApp Extends %Web.REST 
{

/// Application name
Parameter ApplicationName = "Patient API";

/// Application root URL
Parameter URL = "/api/v1";

/// Dispatch class for routing
Parameter DispatchClass = "api.PatientAPI";

/// Enable CORS for cross-origin requests
Parameter HandleCorsRequest = 1;

/// Setup method called when creating the application
ClassMethod Setup() As %Status
{
    Set tSC = $$$OK
    Try {
        // Create web application configuration
        Do ##class(%REST.API).CreateApplication("PatientAPI", "/api/v1", "api.PatientAPI")
        Write "Patient API web application created successfully!", !
        Write "API endpoint: /api/v1/patient", !
        Write "Available routes:", !
        Write "  GET    /api/v1/patient         - Get all patients", !
        Write "  GET    /api/v1/patient/:id     - Get patient by ID", !
        Write "  POST   /api/v1/patient         - Create new patient", !
        Write "  PUT    /api/v1/patient/:id     - Update patient by ID", !
        Write "  DELETE /api/v1/patient/:id     - Delete patient by ID", !
        Write "  GET    /api/v1/patient/search  - Search patients", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error setting up Patient API: ", $System.Status.GetErrorText(tSC), !
    }
    
    Return tSC
}

/// Remove the web application
ClassMethod Remove() As %Status
{
    Set tSC = $$$OK
    Try {
        Do ##class(%REST.API).DeleteApplication("/api/v1")
        Write "Patient API web application removed successfully!", !
        
    } Catch ex {
        Set tSC = ex.AsStatus()
        Write "Error removing Patient API: ", $System.Status.GetErrorText(tSC), !
    }
    
    Return tSC
}

/// Get API documentation
ClassMethod GetApiDocumentation() As %String
{
    Set doc = "Patient API Documentation" _ $C(10) _ $C(10)
    Set doc = doc _ "Base URL: /api/v1" _ $C(10) _ $C(10)
    
    Set doc = doc _ "ENDPOINTS:" _ $C(10)
    Set doc = doc _ "=========" _ $C(10) _ $C(10)
    
    Set doc = doc _ "1. GET /patient" _ $C(10)
    Set doc = doc _ "   Description: Get all patients with pagination" _ $C(10)
    Set doc = doc _ "   Query Parameters:" _ $C(10)
    Set doc = doc _ "     - limit: Number of records to return (default: 50, max: 1000)" _ $C(10)
    Set doc = doc _ "     - offset: Number of records to skip (default: 0)" _ $C(10)
    Set doc = doc _ "   Response: 200 OK with patient array and pagination info" _ $C(10) _ $C(10)
    
    Set doc = doc _ "2. GET /patient/:id" _ $C(10)
    Set doc = doc _ "   Description: Get specific patient by ID" _ $C(10)
    Set doc = doc _ "   Path Parameters:" _ $C(10)
    Set doc = doc _ "     - id: Patient internal ID" _ $C(10)
    Set doc = doc _ "   Response: 200 OK with patient data or 404 Not Found" _ $C(10) _ $C(10)
    
    Set doc = doc _ "3. POST /patient" _ $C(10)
    Set doc = doc _ "   Description: Create new patient" _ $C(10)
    Set doc = doc _ "   Request Body: JSON with patient data" _ $C(10)
    Set doc = doc _ "   Required fields: firstName, lastName" _ $C(10)
    Set doc = doc _ "   Response: 201 Created with patient data" _ $C(10) _ $C(10)
    
    Set doc = doc _ "4. PUT /patient/:id" _ $C(10)
    Set doc = doc _ "   Description: Update existing patient" _ $C(10)
    Set doc = doc _ "   Path Parameters:" _ $C(10)
    Set doc = doc _ "     - id: Patient internal ID" _ $C(10)
    Set doc = doc _ "   Request Body: JSON with patient data (partial updates allowed)" _ $C(10)
    Set doc = doc _ "   Response: 200 OK with updated patient data or 404 Not Found" _ $C(10) _ $C(10)
    
    Set doc = doc _ "5. DELETE /patient/:id" _ $C(10)
    Set doc = doc _ "   Description: Delete patient by ID" _ $C(10)
    Set doc = doc _ "   Path Parameters:" _ $C(10)
    Set doc = doc _ "     - id: Patient internal ID" _ $C(10)
    Set doc = doc _ "   Response: 204 No Content or 404 Not Found" _ $C(10) _ $C(10)
    
    Set doc = doc _ "6. GET /patient/search" _ $C(10)
    Set doc = doc _ "   Description: Search patients by criteria" _ $C(10)
    Set doc = doc _ "   Query Parameters:" _ $C(10)
    Set doc = doc _ "     - firstName: Search by first name (partial match)" _ $C(10)
    Set doc = doc _ "     - lastName: Search by last name (partial match)" _ $C(10)
    Set doc = doc _ "     - email: Search by email (partial match)" _ $C(10)
    Set doc = doc _ "     - patientId: Search by patient ID (partial match)" _ $C(10)
    Set doc = doc _ "     - medicalRecordNumber: Search by medical record number (partial match)" _ $C(10)
    Set doc = doc _ "     - limit: Number of records to return (default: 50, max: 1000)" _ $C(10)
    Set doc = doc _ "     - offset: Number of records to skip (default: 0)" _ $C(10)
    Set doc = doc _ "   Response: 200 OK with matching patients and search criteria" _ $C(10) _ $C(10)
    
    Set doc = doc _ "JSON STRUCTURE:" _ $C(10)
    Set doc = doc _ "===============" _ $C(10) _ $C(10)
    Set doc = doc _ "Patient Object:" _ $C(10)
    Set doc = doc _ "{" _ $C(10)
    Set doc = doc _ "  ""id"": ""1""," _ $C(10)
    Set doc = doc _ "  ""patientId"": ""P001""," _ $C(10)
    Set doc = doc _ "  ""medicalRecordNumber"": ""MRN123456""," _ $C(10)
    Set doc = doc _ "  ""firstName"": ""John""," _ $C(10)
    Set doc = doc _ "  ""lastName"": ""Doe""," _ $C(10)
    Set doc = doc _ "  ""dateOfBirth"": ""1980-01-15""," _ $C(10)
    Set doc = doc _ "  ""gender"": ""M""," _ $C(10)
    Set doc = doc _ "  ""phone"": ""+1-555-123-4567""," _ $C(10)
    Set doc = doc _ "  ""email"": ""john.doe@email.com""," _ $C(10)
    Set doc = doc _ "  ""address"": {" _ $C(10)
    Set doc = doc _ "    ""addressLine1"": ""123 Main St""," _ $C(10)
    Set doc = doc _ "    ""addressLine2"": ""Apt 4B""," _ $C(10)
    Set doc = doc _ "    ""city"": ""New York""," _ $C(10)
    Set doc = doc _ "    ""state"": ""NY""," _ $C(10)
    Set doc = doc _ "    ""postalCode"": ""10001""," _ $C(10)
    Set doc = doc _ "    ""country"": ""USA""" _ $C(10)
    Set doc = doc _ "  }" _ $C(10)
    Set doc = doc _ "}" _ $C(10) _ $C(10)
    
    Set doc = doc _ "ERROR RESPONSES:" _ $C(10)
    Set doc = doc _ "================" _ $C(10)
    Set doc = doc _ "All errors return JSON with structure:" _ $C(10)
    Set doc = doc _ "{" _ $C(10)
    Set doc = doc _ "  ""error"": ""Error Type""," _ $C(10)
    Set doc = doc _ "  ""message"": ""Detailed error message""," _ $C(10)
    Set doc = doc _ "  ""timestamp"": ""2026-04-14 10:30:45""," _ $C(10)
    Set doc = doc _ "  ""statusCode"": 400" _ $C(10)
    Set doc = doc _ "}" _ $C(10)
    
    Return doc
}

}