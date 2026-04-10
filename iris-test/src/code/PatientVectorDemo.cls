/// Demo script to insert and query patient data with vectors
/// Run this in IRIS Terminal: do ##class(Demo.PatientVectorDemo).RunDemo()

Class Demo.PatientVectorDemo
{

/// Main demo method
ClassMethod RunDemo() As %Status
{
    write "=== Patient Vector Data Demo ===", !
    
    // Clear existing data (optional)
    write "Clearing existing patient data...", !
    do ..ClearPatientData()
    
    // Insert sample patients
    write "Inserting sample patients with vectors...", !
    do ..InsertSamplePatients()
    
    // Query and display
    write "Querying patient data...", !
    do ..QueryPatientData()
    
    // Demonstrate vector operations
    write "Demonstrating vector similarity...", !
    do ..DemonstrateVectorSimilarity()
    
    return $$$OK
}

/// Clear existing patient data
ClassMethod ClearPatientData()
{
    &sql(DELETE FROM app.patient)
    if SQLCODE = 0 {
        write "Existing data cleared.", !
    } else {
        write "Note: ", %msg, !
    }
}

/// Insert sample patients with vectors
ClassMethod InsertSamplePatients()
{
    // Patient 1: Diabetes patient with specific vector pattern
    set diabetesVector = "["
    for i = 1:1:256 {
        // Simulate medical condition vector with diabetes indicators high
        if i <= 50 { set value = 0.7 + ($RANDOM(30)/100) }
        elseif i <= 100 { set value = 0.3 + ($RANDOM(40)/100) }
        else { set value = $RANDOM(50)/100 }
        
        set diabetesVector = diabetesVector _ value
        if i < 256 set diabetesVector = diabetesVector _ ","
    }
    set diabetesVector = diabetesVector _ "]"
    
    &sql(INSERT INTO app.patient (name, comment) 
         VALUES ('John Diabetes', TO_VECTOR(:diabetesVector, 'DOUBLE')))
    
    // Patient 2: Cardiac patient
    set cardiacVector = "["
    for i = 1:1:256 {
        if i <= 30 { set value = 0.2 + ($RANDOM(30)/100) }
        elseif i <= 80 { set value = 0.8 + ($RANDOM(20)/100) }
        else { set value = $RANDOM(60)/100 }
        
        set cardiacVector = cardiacVector _ value
        if i < 256 set cardiacVector = cardiacVector _ ","
    }
    set cardiacVector = cardiacVector _ "]"
    
    &sql(INSERT INTO app.patient (name, comment) 
         VALUES ('Jane Cardiac', TO_VECTOR(:cardiacVector, 'DOUBLE')))
    
    // Patient 3: General checkup (random vector)
    set generalVector = "["
    for i = 1:1:256 {
        set value = $RANDOM(100)/100
        set generalVector = generalVector _ value
        if i < 256 set generalVector = generalVector _ ","
    }
    set generalVector = generalVector _ "]"
    
    &sql(INSERT INTO app.patient (name, comment) 
         VALUES ('Bob General', TO_VECTOR(:generalVector, 'DOUBLE')))
    
    write "Inserted 3 sample patients", !
}

/// Query and display patient data
ClassMethod QueryPatientData()
{
    write "Patient Records:", !
    write "ID", $J("", 3), "Name", $J("", 12), "Vector Magnitude", !
    write "---", $J("", 2), "----", $J("", 12), "----------------", !
    
    &sql(DECLARE cursor1 CURSOR FOR
         SELECT ID, name, VECTOR_DOT_PRODUCT(comment, comment) as magnitude
         FROM app.patient
         ORDER BY ID)
    
    &sql(OPEN cursor1)
    
    for {
        &sql(FETCH cursor1 INTO :id, :name, :magnitude)
        quit:SQLCODE'=0
        
        write id, $J("", 5-$LENGTH(id)), name, $J("", 17-$LENGTH(name)), $FNUMBER(magnitude, "", 4), !
    }
    
    &sql(CLOSE cursor1)
}

/// Demonstrate vector similarity calculations
ClassMethod DemonstrateVectorSimilarity()
{
    write "Vector Similarity Analysis:", !
    write "Patient 1", $J("", 8), "Patient 2", $J("", 8), "Similarity", !
    write "---------", $J("", 8), "---------", $J("", 8), "----------", !
    
    &sql(DECLARE cursor2 CURSOR FOR
         SELECT p1.name, p2.name, 
                VECTOR_DOT_PRODUCT(p1.comment, p2.comment) as similarity
         FROM app.patient p1, app.patient p2
         WHERE p1.ID < p2.ID
         ORDER BY similarity DESC)
    
    &sql(OPEN cursor2)
    
    for {
        &sql(FETCH cursor2 INTO :name1, :name2, :similarity)
        quit:SQLCODE'=0
        
        write name1, $J("", 17-$LENGTH(name1)), name2, $J("", 17-$LENGTH(name2)), $FNUMBER(similarity, "", 4), !
    }
    
    &sql(CLOSE cursor2)
    
    // Find most similar to a diabetes pattern
    write !, "Similarity to Diabetes Pattern:", !
    set diabetesQuery = "["
    for i = 1:1:256 {
        if i <= 50 { set value = 0.8 }
        else { set value = 0.2 }
        set diabetesQuery = diabetesQuery _ value
        if i < 256 set diabetesQuery = diabetesQuery _ ","
    }
    set diabetesQuery = diabetesQuery _ "]"
    
    &sql(SELECT name, VECTOR_DOT_PRODUCT(comment, TO_VECTOR(:diabetesQuery, 'DOUBLE')) as similarity
         INTO :bestName, :bestSim
         FROM app.patient
         ORDER BY similarity DESC)
    
    write "Best match: ", bestName, " (similarity: ", $FNUMBER(bestSim, "", 4), ")", !
}

}