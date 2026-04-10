/// ObjectScript methods for inserting patient data with vectors
/// Add these methods to your app.patient class or create a separate utility class

/// Quick method to insert a patient with a random vector
ClassMethod InsertSamplePatient(name As %String = "Sample Patient") As %Status
{
    // Create new patient
    set patient = ..%New()
    set patient.name = name
    
    // Create a 256-dimensional vector with random values
    set vectorJSON = "["
    for i = 1:1:256 {
        set value = $RANDOM(100) / 100  // Random value between 0 and 1
        set vectorJSON = vectorJSON _ value
        if i < 256 set vectorJSON = vectorJSON _ ","
    }
    set vectorJSON = vectorJSON _ "]"
    
    // Convert to vector
    set patient.comment = ##class(%Library.Vector).%FromJSON(vectorJSON)
    
    // Save
    set status = patient.%Save()
    if $$$ISERR(status) {
        write "Error: ", $SYSTEM.Status.GetErrorText(status), !
    } else {
        write "Created patient ID: ", patient.%Id(), " with vector", !
    }
    
    return status
}

/// Insert patient with specific vector values
ClassMethod InsertPatientWithVector(name As %String, vectorData As %String) As %Status
{
    set patient = ..%New()
    set patient.name = name
    set patient.comment = ##class(%Library.Vector).%FromJSON(vectorData)
    
    set status = patient.%Save()
    if $$$ISERR(status) {
        write "Error: ", $SYSTEM.Status.GetErrorText(status), !
    } else {
        write "Created patient: ", name, " (ID: ", patient.%Id(), ")", !
    }
    
    return status
}

/// Batch insert multiple patients with vectors
ClassMethod InsertBatchPatients() As %Status
{
    set status = $$$OK
    
    // Sample data with different vector patterns
    set data = ""
    set data(1) = "John Doe^[" _ $LB("medical", "diabetes", "treatment") _ "]"
    set data(2) = "Jane Smith^[" _ $LB("surgical", "cardiac", "procedure") _ "]" 
    set data(3) = "Bob Johnson^[" _ $LB("emergency", "trauma", "care") _ "]"
    
    for i = 1:1:3 {
        set record = data(i)
        set name = $PIECE(record, "^", 1)
        set keywords = $PIECE(record, "^", 2)
        
        // Generate vector based on keywords (simplified)
        set vectorJSON = ..GenerateVectorFromKeywords(keywords)
        set status = ..InsertPatientWithVector(name, vectorJSON)
        quit:$$$ISERR(status)
    }
    
    return status
}

/// Helper method to generate vector from keywords
ClassMethod GenerateVectorFromKeywords(keywords As %String) As %String
{
    // Simple approach: hash keywords to generate reproducible vector
    set hash = $SYSTEM.Encryption.MD5Hash(keywords)
    set vectorJSON = "["
    
    for i = 1:1:256 {
        // Use hash to create pseudo-random but reproducible values
        set pos = ((i - 1) # $LENGTH(hash)) + 1
        set charCode = $ASCII($EXTRACT(hash, pos))
        set value = (charCode # 100) / 100
        set vectorJSON = vectorJSON _ value
        if i < 256 set vectorJSON = vectorJSON _ ","
    }
    set vectorJSON = vectorJSON _ "]"
    
    return vectorJSON
}