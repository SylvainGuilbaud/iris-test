/// Demo script to insert and query patient data with vectors
/// Run this in IRIS Terminal: do ##class(Demo.PatientVectorDemo).RunDemo()

Class Demo.PatientVectorDemo
{

/// Main demo method
ClassMethod RunDemo() As %Status
{
    write "=== Patient Vector Data Demo ===", !
    
    // Ensure table exists first
    write "Checking/creating patient table...", !
    do ..EnsureTableExists()
    
    // Clear existing data (optional)
    write "Clearing existing patient data...", !
    do ..ClearPatientData()
    
    // Insert sample patients
    write "Inserting sample patients with vectors...", !
    do ..InsertSamplePatients()
    
    // Verify the insertions
    write "Verifying data integrity...", !
    do ..VerifyData()
    
    // Query and display
    write "Querying patient data...", !
    do ..QueryPatientData()
    
    // Demonstrate vector operations
    write "Demonstrating vector similarity...", !
    do ..DemonstrateVectorSimilarity()
    
    write "Demo completed successfully!", !
    return $$$OK
}

/// Ensure the patient table exists with vector column
ClassMethod EnsureTableExists()
{
    write "Checking current schema...", !
    &sql(SELECT CURRENT_SCHEMA INTO :currentSchema)
    write "Current schema: ", currentSchema, !
    
    // Try to create schema first
    write "Creating app schema if needed...", !
    &sql(CREATE SCHEMA app)
    if SQLCODE = 0 {
        write "✓ Schema app created", !
    } else {
        write "Schema creation SQLCODE=", SQLCODE, " (may already exist)", !
    }
    
    // Check if table exists in current schema first
    &sql(SELECT COUNT(*) INTO :tableExists FROM INFORMATION_SCHEMA.TABLES 
         WHERE TABLE_NAME = 'patient')
    
    write "Tables found with name 'patient': ", tableExists, !
    
    // Try dropping table first to start fresh
    write "Dropping table if it exists...", !
    &sql(DROP TABLE IF EXISTS app.patient)
    write "Drop table SQLCODE=", SQLCODE, !
    
    // Create the table with explicit schema
    write "Creating app.patient table...", !
    &sql(CREATE TABLE app.patient (
        ID INTEGER IDENTITY PRIMARY KEY,
        name VARCHAR(50),
        comment VECTOR(DOUBLE, 256)
    ))
    
    if SQLCODE = 0 {
        write "✓ Table app.patient created successfully", !
        
        // Verify table creation
        &sql(SELECT COUNT(*) INTO :verifyTable FROM INFORMATION_SCHEMA.TABLES 
             WHERE TABLE_NAME = 'patient' AND TABLE_SCHEMA = 'app')
        write "Table verification: found ", verifyTable, " app.patient table(s)", !
        
    } else {
        write "✗ Table creation failed with SQLCODE=", SQLCODE, !
        
        // Try alternative approach - use USER schema
        write "Trying alternative: creating patient table in USER schema...", !
        &sql(CREATE TABLE patient (
            ID INTEGER IDENTITY PRIMARY KEY,
            name VARCHAR(50),
            comment VECTOR(DOUBLE, 256)
        ))
        
        if SQLCODE = 0 {
            write "✓ Table patient created in USER schema", !
        } else {
            write "✗ Alternative creation also failed: SQLCODE=", SQLCODE, !
        }
    }
}

/// Helper method to determine which patient table exists
ClassMethod GetPatientTableName() As %String
{
    // Check for app.patient first
    &sql(SELECT COUNT(*) INTO :appTable FROM INFORMATION_SCHEMA.TABLES 
         WHERE TABLE_NAME = 'patient' AND TABLE_SCHEMA = 'app')
    
    if (SQLCODE = 0) && (appTable > 0) {
        return "app.patient"
    }
    
    // Check for patient in current schema
    &sql(SELECT COUNT(*) INTO :userTable FROM INFORMATION_SCHEMA.TABLES 
         WHERE TABLE_NAME = 'patient')
    
    if (SQLCODE = 0) && (userTable > 0) {
        return "patient"
    }
    
    // Default fallback
    return "patient"
}

/// Clear existing patient data
ClassMethod ClearPatientData()
{
    set tableName = ..GetPatientTableName()
    write "Using table for clearing: ", tableName, !
    
    // First count existing records
    set sql = "SELECT COUNT(*) FROM " _ tableName
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt INTO :recordCount)
    
    if SQLCODE = 0 {
        write "Found ", recordCount, " existing patient record(s)", !
    } else {
        write "Could not count records: SQLCODE=", SQLCODE, !
    }
    
    // Delete records
    set sql = "DELETE FROM " _ tableName
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt)
    
    if SQLCODE = 0 {
        write "✓ Existing data cleared successfully (", %ROWCOUNT, " rows deleted)", !
    } elseif SQLCODE = 100 {
        write "✓ No data to clear (table empty)", !
    } else {
        write "✗ Error clearing data: SQLCODE=", SQLCODE, !
    }
}

/// Insert sample patients with vectors
ClassMethod InsertSamplePatients()
{
    set totalInserted = 0
    set totalErrors = 0
    
    // Determine which table to use
    set tableName = ..GetPatientTableName()
    write "Using table: ", tableName, !
    
    // Patient 1: Diabetes patient with specific vector pattern
    write "Creating diabetes patient vector...", !
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
    
    set sql = "INSERT INTO " _ tableName _ " (name, comment) VALUES ('John Diabetes', TO_VECTOR(?, 'DOUBLE'))"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt USING :diabetesVector)
    
    if SQLCODE = 0 {
        set totalInserted = totalInserted + 1
        write "✓ John Diabetes inserted successfully (ID: ", %ROWID, ")", !
    } else {
        set totalErrors = totalErrors + 1
        write "✗ Error inserting John Diabetes: SQLCODE=", SQLCODE, !
    }
    
    // Patient 2: Cardiac patient
    write "Creating cardiac patient vector...", !
    set cardiacVector = "["
    for i = 1:1:256 {
        if i <= 30 { set value = 0.2 + ($RANDOM(30)/100) }
        elseif i <= 80 { set value = 0.8 + ($RANDOM(20)/100) }
        else { set value = $RANDOM(60)/100 }
        
        set cardiacVector = cardiacVector _ value
        if i < 256 set cardiacVector = cardiacVector _ ","
    }
    set cardiacVector = cardiacVector _ "]"
    
    set sql = "INSERT INTO " _ tableName _ " (name, comment) VALUES ('Jane Cardiac', TO_VECTOR(?, 'DOUBLE'))"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt USING :cardiacVector)
    
    if SQLCODE = 0 {
        set totalInserted = totalInserted + 1
        write "✓ Jane Cardiac inserted successfully (ID: ", %ROWID, ")", !
    } else {
        set totalErrors = totalErrors + 1
        write "✗ Error inserting Jane Cardiac: SQLCODE=", SQLCODE, !
    }
    
    // Patient 3: General checkup (random vector)
    write "Creating general patient vector...", !
    set generalVector = "["
    for i = 1:1:256 {
        set value = $RANDOM(100)/100
        set generalVector = generalVector _ value
        if i < 256 set generalVector = generalVector _ ","
    }
    set generalVector = generalVector _ "]"
    
    set sql = "INSERT INTO " _ tableName _ " (name, comment) VALUES ('Bob General', TO_VECTOR(?, 'DOUBLE'))"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt USING :generalVector)
    
    if SQLCODE = 0 {
        set totalInserted = totalInserted + 1
        write "✓ Bob General inserted successfully (ID: ", %ROWID, ")", !
    } else {
        set totalErrors = totalErrors + 1
        write "✗ Error inserting Bob General: SQLCODE=", SQLCODE, !
    }
    
    write "Insert Summary: ", totalInserted, " successful, ", totalErrors, " errors", !
}

/// Query and display patient data
ClassMethod QueryPatientData()
{
    set tableName = ..GetPatientTableName()
    
    write "Patient Records:", !
    write "ID", $J("", 3), "Name", $J("", 12), "Vector Magnitude", !
    write "---", $J("", 2), "----", $J("", 12), "----------------", !
    
    set sql = "SELECT ID, name, VECTOR_DOT_PRODUCT(comment, comment) as magnitude FROM " _ tableName _ " ORDER BY ID"
    &sql(PREPARE stmt FROM :sql)
    &sql(DECLARE cursor1 CURSOR FOR stmt)
    
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
    set tableName = ..GetPatientTableName()
    
    write "Vector Similarity Analysis:", !
    write "Patient 1", $J("", 8), "Patient 2", $J("", 8), "Similarity", !
    write "---------", $J("", 8), "---------", $J("", 8), "----------", !
    
    set sql = "SELECT p1.name, p2.name, VECTOR_DOT_PRODUCT(p1.comment, p2.comment) as similarity FROM " _ 
              tableName _ " p1, " _ tableName _ " p2 WHERE p1.ID < p2.ID ORDER BY similarity DESC"
    &sql(PREPARE stmt FROM :sql)
    &sql(DECLARE cursor2 CURSOR FOR stmt)
    
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
    
    set sql = "SELECT name, VECTOR_DOT_PRODUCT(comment, TO_VECTOR(?, 'DOUBLE')) as similarity FROM " _ 
              tableName _ " ORDER BY similarity DESC"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt INTO :bestName, :bestSim USING :diabetesQuery)
    
    write "Best match: ", bestName, " (similarity: ", $FNUMBER(bestSim, "", 4), ")", !
}

/// Verify data integrity and vector properties
ClassMethod VerifyData()
{
    set tableName = ..GetPatientTableName()
    
    write "Data Verification:", !
    write "=================", !
    write "Using table: ", tableName, !
    
    set sql = "SELECT COUNT(*) FROM " _ tableName
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt INTO :totalCount)
    write "Total patients: ", totalCount, !
    
    set sql = "SELECT COUNT(*) FROM " _ tableName _ " WHERE comment IS NOT NULL"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt INTO :vectorCount)
    write "Patients with vectors: ", vectorCount, !
    
    set sql = "SELECT COUNT(*) FROM " _ tableName _ " WHERE comment IS NULL"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt INTO :nullCount)
    write "Patients without vectors: ", nullCount, !
    
    if vectorCount > 0 {
        set sql = "SELECT AVG(VECTOR_DOT_PRODUCT(comment, comment)) FROM " _ tableName _ " WHERE comment IS NOT NULL"
        &sql(PREPARE stmt FROM :sql)
        &sql(EXECUTE stmt INTO :avgMagnitude)
        write "Average vector magnitude: ", $FNUMBER(avgMagnitude, "", 4), !
        
        set sql = "SELECT MAX(VECTOR_DOT_PRODUCT(comment, comment)) FROM " _ tableName _ " WHERE comment IS NOT NULL"
        &sql(PREPARE stmt FROM :sql)
        &sql(EXECUTE stmt INTO :maxMagnitude)
        write "Max vector magnitude: ", $FNUMBER(maxMagnitude, "", 4), !
        
        set sql = "SELECT MIN(VECTOR_DOT_PRODUCT(comment, comment)) FROM " _ tableName _ " WHERE comment IS NOT NULL"
        &sql(PREPARE stmt FROM :sql)
        &sql(EXECUTE stmt INTO :minMagnitude)
        write "Min vector magnitude: ", $FNUMBER(minMagnitude, "", 4), !
        
        // Verify vector dimensions
        set sql = "SELECT VECTOR_DIMENSIONS(comment) FROM " _ tableName _ " WHERE comment IS NOT NULL"
        &sql(PREPARE stmt FROM :sql)
        &sql(EXECUTE stmt INTO :dimensions)
        if SQLCODE = 0 {
            write "Vector dimensions: ", dimensions, !
        }
    }
    
    write "Verification complete.", !
}

/// Quick test to verify basic insert functionality
ClassMethod QuickTest() As %Status
{
    write "=== Quick Insert Test ===", !
    
    // Ensure table exists first
    do ..EnsureTableExists()
    
    // Get table name
    set tableName = ..GetPatientTableName()
    write "Using table: ", tableName, !
    
    // Simple test vector
    set testVector = "["
    for i = 1:1:256 {
        set testVector = testVector _ (i/256)
        if i < 256 set testVector = testVector _ ","
    }
    set testVector = testVector _ "]"
    
    // Insert test patient
    set sql = "INSERT INTO " _ tableName _ " (name, comment) VALUES ('Test Patient', TO_VECTOR(?, 'DOUBLE'))"
    &sql(PREPARE stmt FROM :sql)
    &sql(EXECUTE stmt USING :testVector)
    
    if SQLCODE = 0 {
        write "✓ Test patient inserted successfully (ID: ", %ROWID, ")", !
        
        // Verify retrieval
        set sql = "SELECT name, VECTOR_DOT_PRODUCT(comment, comment) as magnitude FROM " _ tableName _ " WHERE ID = ?"
        &sql(PREPARE stmt FROM :sql)
        &sql(EXECUTE stmt INTO :retrievedName, :magnitude USING :%ROWID)
        
        if SQLCODE = 0 {
            write "✓ Test patient retrieved: ", retrievedName, " (magnitude: ", $FNUMBER(magnitude, "", 4), ")", !
            write "✓ Insert test PASSED!", !
        } else {
            write "✗ Error retrieving test patient: SQLCODE=", SQLCODE, !
        }
    } else {
        write "✗ Error inserting test patient: SQLCODE=", SQLCODE, !
        write "✗ Insert test FAILED!", !
    }
    
    return $$$OK
}

/// Quick setup method to just create table
ClassMethod QuickSetup() As %Status
{
    write "=== Quick Table Setup ===", !
    do ..EnsureTableExists()
    write "Setup complete!", !
    return $$$OK
}

}