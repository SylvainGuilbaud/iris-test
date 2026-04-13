#!/usr/bin/env python3
"""
Script to insert data into app.patient table with vector column
Demonstrates different ways to work with vector data in IRIS
Version with improved connection handling
"""

import random

def insert_patient_with_vector():
    """Insert patient data with vector using Python"""
    
    try:
        # Connect to IRIS with error handling
        import iris
        conn = iris.connect("localhost", 1972, "IRISAPP", "_SYSTEM", "SYS")
        
        # Create a sample 512-dimensional vector
        # Example 1: Random vector
        vector_data = [random.random() for _ in range(512)]
        
        # Example 2: Using numpy (if available)
        # vector_data = np.random.rand(512).tolist()
        
        # Convert vector to IRIS format (JSON array)
        vector_json = str(vector_data)
        
        # Insert using SQL
        cursor = conn.cursor()
        
        # Method 1: Direct SQL INSERT
        sql = "INSERT INTO app.patient (name, comment) VALUES (?, TO_VECTOR(?, 'DOUBLE'))"
        cursor.execute(sql, ["John Doe", vector_json])
        
        # Method 2: Insert with predefined vector
        embedding_vector = [0.1, 0.2, 0.3] + [0.0] * 509  # Fill to 512 dimensions
        cursor.execute(sql, ["Jane Smith", str(embedding_vector)])
        
        conn.commit()
        print("Successfully inserted patient records with vectors")
        
        # Query back the data
        cursor.execute("SELECT ID, name, VECTOR_DOT_PRODUCT(comment, comment) as magnitude FROM app.patient")
        results = cursor.fetchall()
        
        print("\nInserted records:")
        for record in results:
            print(f"ID: {record[0]}, Name: {record[1]}, Vector magnitude: {record[2]:.3f}")
            
        conn.close()
        
    except ImportError:
        print("❌ Module iris non disponible")
        print("💡 Installation requise: pip install intersystems-irispython")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        print("💡 Vérifiez qu'IRIS est démarré et que la table app.patient existe")

if __name__ == "__main__":
    insert_patient_with_vector()
        
        # Method 1: Direct SQL INSERT
        sql = "INSERT INTO app.patient (name, comment) VALUES (?, TO_VECTOR(?, 'DOUBLE'))"
        cursor.execute(sql, ["John Doe", vector_json])
        
        # Method 2: Insert with predefined vector
        embedding_vector = [0.1, 0.2, 0.3] + [0.0] * 253  # Fill to 512 dimensions
        cursor.execute(sql, ["Jane Smith", str(embedding_vector)])
        
        # Method 3: Insert with semantic vector (example text embedding simulation)
        semantic_vector = generate_semantic_vector("diabetes treatment plan")
        cursor.execute(sql, ["Bob Johnson", str(semantic_vector)])
        
        conn.commit()
        print("Successfully inserted patient records with vectors")
        
        # Query back the data
        cursor.execute("SELECT ID, name, VECTOR_DOT_PRODUCT(comment, comment) as magnitude FROM app.patient")
        results = cursor.fetchall()
        
        print("\nInserted records:")
        for row in results:
            print(f"ID: {row[0]}, Name: {row[1]}, Vector Magnitude: {row[2]:.4f}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'conn' in locals():
            conn.close()

def generate_semantic_vector(text):
    """
    Simulate generating a semantic vector for text
    In a real scenario, you'd use a model like BERT, OpenAI embeddings, etc.
    """
    # Simple hash-based vector generation for demonstration
    hash_val = hash(text)
    random.seed(hash_val)
    return [random.random() for _ in range(512)]

def insert_via_objectscript():
    """Generate ObjectScript code for inserting vector data"""
    
    objectscript_code = '''
/// Insert patient data with vector using ObjectScript
ClassMethod InsertPatientWithVector() As %Status
{
    // Create a new patient object
    set patient = ##class(app.patient).%New()
    
    // Set basic properties
    set patient.name = "Alice Johnson"
    
    // Create a vector - Method 1: From array
    set vectorArray = []
    for i = 1:1:512 {
        do vectorArray.%Push($RANDOM(100) / 100)
    }
    set patient.comment = ##class(%Library.Vector).%New()
    do patient.comment.%FromJSON(vectorArray.%ToJSON())
    
    // Save the patient
    set status = patient.%Save()
    if $$$ISERR(status) {
        write "Error saving patient: ", $SYSTEM.Status.GetErrorText(status), !
        return status
    }
    
    write "Patient saved with ID: ", patient.%Id(), !
    
    // Method 2: Create vector directly from list
    set patient2 = ##class(app.patient).%New()
    set patient2.name = "Charlie Brown"
    
    // Create vector from JSON string
    set vectorJSON = "["
    for i = 1:1:512 {
        set vectorJSON = vectorJSON _ ($RANDOM(100) / 100)
        if i < 512 set vectorJSON = vectorJSON _ ","
    }
    set vectorJSON = vectorJSON _ "]"
    
    set patient2.comment = ##class(%Library.Vector).%FromJSON(vectorJSON)
    set status = patient2.%Save()
    
    write "Second patient saved with ID: ", patient2.%Id(), !
    
    return $$$OK
}

/// Insert using SQL
ClassMethod InsertPatientSQL() As %Status
{
    set sql = "INSERT INTO app.patient (name, comment) VALUES (?, TO_VECTOR(?, 'DOUBLE'))"
    
    // Create sample vectors
    set vector1 = "["
    for i = 1:1:512 {
        set vector1 = vector1 _ ($RANDOM(100) / 100)
        if i < 512 set vector1 = vector1 _ ","
    }
    set vector1 = vector1 _ "]"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) return status
    
    set result = statement.%Execute("David Wilson", vector1)
    if result.%SQLCODE < 0 {
        write "SQL Error: ", result.%Message, !
        return $$$ERROR($$$SQLError, result.%SQLCODE, result.%Message)
    }
    
    write "Patient inserted via SQL", !
    return $$$OK
}
'''
    
    return objectscript_code

if __name__ == "__main__":
    print("Patient Vector Data Insertion Examples")
    print("=" * 50)
    
    print("\n1. Python approach:")
    print("Run: python insert_patient_data.py")
    
    print("\n2. ObjectScript approach:")
    print("Add this code to a class method and execute:")
    print(insert_via_objectscript())
    
    print("\n3. Direct SQL approach (Terminal):")
    print("""
-- Insert with random vector
INSERT INTO app.patient (name, comment) 
VALUES ('Test Patient', TO_VECTOR('[0.1,0.2,0.3,0.4]', 'DOUBLE'));

-- Insert with specific vector values
INSERT INTO app.patient (name, comment)
VALUES ('Vector Patient', TO_VECTOR('""" + str([0.1 * i for i in range(512)]) + """', 'DOUBLE'));
    """)