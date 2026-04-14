Class api.PatientAPI Extends %REST.Impl
{

/// Define the resource map for Patient API endpoints
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>

<!-- GET /patient - Get all patients -->
<Route Url="/patient" Method="GET" Call="GetAllPatients" />

<!-- GET /patient/:id - Get patient by ID -->
<Route Url="/patient/:id" Method="GET" Call="GetPatientById" />

<!-- POST /patient - Create new patient -->
<Route Url="/patient" Method="POST" Call="CreatePatient" />

<!-- PUT /patient/:id - Update patient by ID -->
<Route Url="/patient/:id" Method="PUT" Call="UpdatePatient" />

<!-- DELETE /patient/:id - Delete patient by ID -->
<Route Url="/patient/:id" Method="DELETE" Call="DeletePatient" />

<!-- GET /patient/search - Search patients -->
<Route Url="/patient/search" Method="GET" Call="SearchPatients" />

</Routes>
}

/// Get all patients with optional pagination
ClassMethod GetAllPatients() As %Status
{
    #dim %response As %REST.Response
    Try {
        Set limit = +$GET(%request.Data("limit", 1), 50)
        Set offset = +$GET(%request.Data("offset", 1), 0)
        
        If limit > 1000 Set limit = 1000  // Max limit for performance
        If limit <= 0 Set limit = 50
        If offset < 0 Set offset = 0
        
        Set results = []
        Set sql = "SELECT ID, PatientId, MedicalRecordNumber, FirstName, LastName, DateOfBirth, Gender, Phone, Email, AddressLine1, AddressLine2, City, State, PostalCode, Country FROM data.patient ORDER BY ID"
        
        If limit > 0 Set sql = sql _ " %VID LIMIT " _ limit _ " OFFSET " _ offset
        
        Set statement = ##class(%SQL.Statement).%New()
        Set status = statement.%Prepare(sql)
        If $$$ISERR(status) {
            Do ..WriteError(500, "Database error", $System.Status.GetErrorText(status))
            Return $$$OK
        }
        
        Set rset = statement.%Execute()
        Set count = 0
        
        While rset.%Next() {
            Set patient = {}
            Set patient.id = rset.%Get("ID")
            Set patient.patientId = rset.%Get("PatientId")
            Set patient.medicalRecordNumber = rset.%Get("MedicalRecordNumber")
            Set patient.firstName = rset.%Get("FirstName")
            Set patient.lastName = rset.%Get("LastName")
            Set patient.dateOfBirth = rset.%Get("DateOfBirth")
            Set patient.gender = rset.%Get("Gender")
            Set patient.phone = rset.%Get("Phone")
            Set patient.email = rset.%Get("Email")
            Set patient.address = {}
            Set patient.address.addressLine1 = rset.%Get("AddressLine1")
            Set patient.address.addressLine2 = rset.%Get("AddressLine2")
            Set patient.address.city = rset.%Get("City")
            Set patient.address.state = rset.%Get("State")
            Set patient.address.postalCode = rset.%Get("PostalCode")
            Set patient.address.country = rset.%Get("Country")
            
            Do results.%Push(patient)
            Set count = count + 1
        }
        
        // Get total count
        Set countSql = "SELECT COUNT(*) As Total FROM data.patient"
        Set countStmt = ##class(%SQL.Statement).%New()
        Do countStmt.%Prepare(countSql)
        Set countRset = countStmt.%Execute()
        Set total = 0
        If countRset.%Next() Set total = countRset.%Get("Total")
        
        Set response = {}
        Set response.data = results
        Set response.pagination = {}
        Set response.pagination.limit = limit
        Set response.pagination.offset = offset
        Set response.pagination.count = count
        Set response.pagination.total = total
        
        Do %response.SetStatus(200)
        Do %response.SetHeader("Content-Type", "application/json")
        Write response.%ToJSON()
        
    } Catch ex {
        Do ..WriteError(500, "Internal server error", ex.DisplayString())
    }
    
    Return $$$OK
}

/// Get patient by ID
ClassMethod GetPatientById(id As %String) As %Status
{
    #dim %response As %REST.Response
    Try {
        If id = "" {
            Do ..WriteError(400, "Bad Request", "Patient ID is required")
            Return $$$OK
        }
        
        Set patient = ##class(data.patient).%OpenId(id)
        If '$IsObject(patient) {
            Do ..WriteError(404, "Not Found", "Patient with ID " _ id _ " not found")
            Return $$$OK
        }
        
        Set result = ..PatientToJSON(patient)
        
        Do %response.SetStatus(200)
        Do %response.SetHeader("Content-Type", "application/json")
        Write result.%ToJSON()
        
    } Catch ex {
        Do ..WriteError(500, "Internal server error", ex.DisplayString())
    }
    
    Return $$$OK
}

/// Create new patient
ClassMethod CreatePatient() As %Status
{
    #dim %response As %REST.Response
    Try {
        Set json = ##class(%DynamicObject).%FromJSON(%request.Content)
        
        If '$IsObject(json) {
            Do ..WriteError(400, "Bad Request", "Invalid JSON payload")
            Return $$$OK
        }
        
        // Validate required fields
        Set validation = ..ValidatePatientData(json, "create")
        If validation.hasError {
            Do ..WriteError(400, "Validation Error", validation.message)
            Return $$$OK
        }
        
        Set patient = ##class(data.patient).%New()
        Do ..JSONToPatient(json, patient)
        
        Set status = patient.%Save()
        If $$$ISERR(status) {
            Do ..WriteError(500, "Database error", $System.Status.GetErrorText(status))
            Return $$$OK
        }
        
        Set result = ..PatientToJSON(patient)
        
        Do %response.SetStatus(201)
        Do %response.SetHeader("Content-Type", "application/json")
        Do %response.SetHeader("Location", "/patient/" _ patient.%Id())
        Write result.%ToJSON()
        
    } Catch ex {
        Do ..WriteError(500, "Internal server error", ex.DisplayString())
    }
    
    Return $$$OK
}

/// Update patient by ID
ClassMethod UpdatePatient(id As %String) As %Status
{
    #dim %response As %REST.Response
    Try {
        If id = "" {
            Do ..WriteError(400, "Bad Request", "Patient ID is required")
            Return $$$OK
        }
        
        Set patient = ##class(data.patient).%OpenId(id)
        If '$IsObject(patient) {
            Do ..WriteError(404, "Not Found", "Patient with ID " _ id _ " not found")
            Return $$$OK
        }
        
        Set json = ##class(%DynamicObject).%FromJSON(%request.Content)
        If '$IsObject(json) {
            Do ..WriteError(400, "Bad Request", "Invalid JSON payload")
            Return $$$OK
        }
        
        // Validate data
        Set validation = ..ValidatePatientData(json, "update")
        If validation.hasError {
            Do ..WriteError(400, "Validation Error", validation.message)
            Return $$$OK
        }
        
        Do ..JSONToPatient(json, patient)
        
        Set status = patient.%Save()
        If $$$ISERR(status) {
            Do ..WriteError(500, "Database error", $System.Status.GetErrorText(status))
            Return $$$OK
        }
        
        Set result = ..PatientToJSON(patient)
        
        Do %response.SetStatus(200)
        Do %response.SetHeader("Content-Type", "application/json")
        Write result.%ToJSON()
        
    } Catch ex {
        Do ..WriteError(500, "Internal server error", ex.DisplayString())
    }
    
    Return $$$OK
}

/// Delete patient by ID
ClassMethod DeletePatient(id As %String) As %Status
{
    #dim %response As %REST.Response
    Try {
        If id = "" {
            Do ..WriteError(400, "Bad Request", "Patient ID is required")
            Return $$$OK
        }
        
        Set patient = ##class(data.patient).%OpenId(id)
        If '$IsObject(patient) {
            Do ..WriteError(404, "Not Found", "Patient with ID " _ id _ " not found")
            Return $$$OK
        }
        
        Set status = patient.%DeleteId(id)
        If $$$ISERR(status) {
            Do ..WriteError(500, "Database error", $System.Status.GetErrorText(status))
            Return $$$OK
        }
        
        Do %response.SetStatus(204) // No Content
        
    } Catch ex {
        Do ..WriteError(500, "Internal server error", ex.DisplayString())
    }
    
    Return $$$OK
}

/// Search patients by various criteria
ClassMethod SearchPatients() As %Status
{
    #dim %response As %REST.Response
    Try {
        Set firstName = $GET(%request.Data("firstName", 1), "")
        Set lastName = $GET(%request.Data("lastName", 1), "")
        Set email = $GET(%request.Data("email", 1), "")
        Set patientId = $GET(%request.Data("patientId", 1), "")
        Set medicalRecordNumber = $GET(%request.Data("medicalRecordNumber", 1), "")
        Set limit = +$GET(%request.Data("limit", 1), 50)
        Set offset = +$GET(%request.Data("offset", 1), 0)
        
        If limit > 1000 Set limit = 1000
        If limit <= 0 Set limit = 50
        If offset < 0 Set offset = 0
        
        Set sql = "SELECT ID, PatientId, MedicalRecordNumber, FirstName, LastName, DateOfBirth, Gender, Phone, Email, AddressLine1, AddressLine2, City, State, PostalCode, Country FROM data.patient WHERE 1=1"
        
        If firstName '= "" Set sql = sql _ " AND UPPER(FirstName) LIKE UPPER('%" _ firstName _ "%')"
        If lastName '= "" Set sql = sql _ " AND UPPER(LastName) LIKE UPPER('%" _ lastName _ "%')"
        If email '= "" Set sql = sql _ " AND UPPER(Email) LIKE UPPER('%" _ email _ "%')"
        If patientId '= "" Set sql = sql _ " AND UPPER(PatientId) LIKE UPPER('%" _ patientId _ "%')"
        If medicalRecordNumber '= "" Set sql = sql _ " AND UPPER(MedicalRecordNumber) LIKE UPPER('%" _ medicalRecordNumber _ "%')"
        
        Set sql = sql _ " ORDER BY LastName, FirstName"
        If limit > 0 Set sql = sql _ " %VID LIMIT " _ limit _ " OFFSET " _ offset
        
        Set statement = ##class(%SQL.Statement).%New()
        Set status = statement.%Prepare(sql)
        If $$$ISERR(status) {
            Do ..WriteError(500, "Database error", $System.Status.GetErrorText(status))
            Return $$$OK
        }
        
        Set rset = statement.%Execute()
        Set results = []
        Set count = 0
        
        While rset.%Next() {
            Set patient = {}
            Set patient.id = rset.%Get("ID")
            Set patient.patientId = rset.%Get("PatientId")
            Set patient.medicalRecordNumber = rset.%Get("MedicalRecordNumber")
            Set patient.firstName = rset.%Get("FirstName")
            Set patient.lastName = rset.%Get("LastName")
            Set patient.dateOfBirth = rset.%Get("DateOfBirth")
            Set patient.gender = rset.%Get("Gender")
            Set patient.phone = rset.%Get("Phone")
            Set patient.email = rset.%Get("Email")
            Set patient.address = {}
            Set patient.address.addressLine1 = rset.%Get("AddressLine1")
            Set patient.address.addressLine2 = rset.%Get("AddressLine2")
            Set patient.address.city = rset.%Get("City")
            Set patient.address.state = rset.%Get("State")
            Set patient.address.postalCode = rset.%Get("PostalCode")
            Set patient.address.country = rset.%Get("Country")
            
            Do results.%Push(patient)
            Set count = count + 1
        }
        
        Set response = {}
        Set response.data = results
        Set response.pagination = {}
        Set response.pagination.limit = limit
        Set response.pagination.offset = offset
        Set response.pagination.count = count
        Set response.searchCriteria = {}
        If firstName '= "" Set response.searchCriteria.firstName = firstName
        If lastName '= "" Set response.searchCriteria.lastName = lastName
        If email '= "" Set response.searchCriteria.email = email
        If patientId '= "" Set response.searchCriteria.patientId = patientId
        If medicalRecordNumber '= "" Set response.searchCriteria.medicalRecordNumber = medicalRecordNumber
        
        Do %response.SetStatus(200)
        Do %response.SetHeader("Content-Type", "application/json")
        Write response.%ToJSON()
        
    } Catch ex {
        Do ..WriteError(500, "Internal server error", ex.DisplayString())
    }
    
    Return $$$OK
}

/// Convert Patient object to JSON
ClassMethod PatientToJSON(patient As data.patient) As %DynamicObject
{
    Set json = {}
    Set json.id = patient.%Id()
    Set json.patientId = patient.PatientId
    Set json.medicalRecordNumber = patient.MedicalRecordNumber
    Set json.firstName = patient.FirstName
    Set json.lastName = patient.LastName
    Set json.dateOfBirth = patient.DateOfBirth
    Set json.gender = patient.Gender
    Set json.phone = patient.Phone
    Set json.email = patient.Email
    Set json.address = {}
    Set json.address.addressLine1 = patient.AddressLine1
    Set json.address.addressLine2 = patient.AddressLine2
    Set json.address.city = patient.City
    Set json.address.state = patient.State
    Set json.address.postalCode = patient.PostalCode
    Set json.address.country = patient.Country
    
    Return json
}

/// Convert JSON to Patient object
ClassMethod JSONToPatient(json As %DynamicObject, patient As data.patient) As %Status
{
    If json.%IsDefined("patientId") Set patient.PatientId = json.patientId
    If json.%IsDefined("medicalRecordNumber") Set patient.MedicalRecordNumber = json.medicalRecordNumber
    If json.%IsDefined("firstName") Set patient.FirstName = json.firstName
    If json.%IsDefined("lastName") Set patient.LastName = json.lastName
    If json.%IsDefined("dateOfBirth") Set patient.DateOfBirth = json.dateOfBirth
    If json.%IsDefined("gender") Set patient.Gender = json.gender
    If json.%IsDefined("phone") Set patient.Phone = json.phone
    If json.%IsDefined("email") Set patient.Email = json.email
    
    If json.%IsDefined("address") && $IsObject(json.address) {
        Set address = json.address
        If address.%IsDefined("addressLine1") Set patient.AddressLine1 = address.addressLine1
        If address.%IsDefined("addressLine2") Set patient.AddressLine2 = address.addressLine2
        If address.%IsDefined("city") Set patient.City = address.city
        If address.%IsDefined("state") Set patient.State = address.state
        If address.%IsDefined("postalCode") Set patient.PostalCode = address.postalCode
        If address.%IsDefined("country") Set patient.Country = address.country
    }
    
    Return $$$OK
}

/// Validate patient data
ClassMethod ValidatePatientData(json As %DynamicObject, operation As %String = "create") As %DynamicObject
{
    Set result = {}
    Set result.hasError = 0
    Set result.message = ""
    
    // Required fields validation for creation
    If operation = "create" {
        If '$IsObject(json) || json.%Size() = 0 {
            Set result.hasError = 1
            Set result.message = "Request body cannot be empty"
            Return result
        }
        
        If 'json.%IsDefined("firstName") || (json.firstName = "") {
            Set result.hasError = 1
            Set result.message = "First name is required"
            Return result
        }
        
        If 'json.%IsDefined("lastName") || (json.lastName = "") {
            Set result.hasError = 1
            Set result.message = "Last name is required"
            Return result
        }
    }
    
    // Email format validation
    If json.%IsDefined("email") && (json.email '= "") {
        Set emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        If '##class(%Regex.Matcher).%New(emailPattern).Match(json.email) {
            Set result.hasError = 1
            Set result.message = "Invalid email format"
            Return result
        }
    }
    
    // Date of birth validation
    If json.%IsDefined("dateOfBirth") && (json.dateOfBirth '= "") {
        Try {
            Set dob = $zdh(json.dateOfBirth, 3)  // ISO date format
            If dob > +$h {
                Set result.hasError = 1
                Set result.message = "Date of birth cannot be in the future"
                Return result
            }
        } Catch {
            Set result.hasError = 1
            Set result.message = "Invalid date format for dateOfBirth (expected: YYYY-MM-DD)"
            Return result
        }
    }
    
    // Gender validation
    If json.%IsDefined("gender") && (json.gender '= "") {
        Set validGenders = "M,F,Male,Female,Other,Unknown"
        If '($LISTFIND($LISTFROMSTRING(validGenders), json.gender)) {
            Set result.hasError = 1
            Set result.message = "Invalid gender. Valid values: M, F, Male, Female, Other, Unknown"
            Return result
        }
    }
    
    Return result
}

/// Write error response
ClassMethod WriteError(statusCode As %Integer, error As %String, message As %String = "") As %Status
{
    #dim %response As %REST.Response
    
    Set errorResponse = {}
    Set errorResponse.error = error
    Set errorResponse.message = message
    Set errorResponse.timestamp = $ZTIMESTAMP
    Set errorResponse.statusCode = statusCode
    
    Do %response.SetStatus(statusCode)
    Do %response.SetHeader("Content-Type", "application/json")
    Write errorResponse.%ToJSON()
    
    Return $$$OK
}

}