/// Test ASTM E1238 Processing
/// This class provides methods to test ASTM E1238 document processing
/// after schema installation
Class test.ASTME1238Test
{

/// Test method to validate E1238 schema and document processing
ClassMethod TestE1238Processing() As %Status
{
    Write "=== ASTM E1238 Test Suite ===", !
    
    // Test 1: Check if E1238 schema is available
    Write "Test 1: Checking E1238 schema availability...", !
    Set st = ..CheckSchemaAvailability()
    If '$$$ISOK(st) Quit st
    
    // Test 2: Test document parsing
    Write "Test 2: Testing document parsing...", !
    Set st = ..TestDocumentParsing()
    If '$$$ISOK(st) Quit st
    
    // Test 3: Test data extraction
    Write "Test 3: Testing data extraction...", !
    Set st = ..TestDataExtraction()
    If '$$$ISOK(st) Quit st
    
    Write "=== All tests completed successfully! ===", !
    Quit $$$OK
}

/// Check if E1238 schema is properly installed and activated
ClassMethod CheckSchemaAvailability() As %Status
{
    Try {
        Set query = "SELECT Name, Standard FROM EnsDocLib.HL7.Schema WHERE Name LIKE '%E1238%'"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set qStatus = tStatement.%Prepare(query)
        If $$$ISERR(qStatus) Quit qStatus
        
        Set tResult = tStatement.%Execute()
        Set found = 0
        While tResult.%Next() {
            Write "  Found schema: ", tResult.%Get("Name"), " (Standard: ", tResult.%Get("Standard"), ")", !
            Set found = 1
        }
        
        If 'found {
            Write "  ERROR: No E1238 schema found!", !
            Quit $$$ERROR($$$GeneralError, "E1238 schema not found")
        }
        
        Write "  OK: E1238 schema is available", !
        Quit $$$OK
        
    } Catch ex {
        Write "  ERROR: ", ex.DisplayString(), !
        Quit ex.AsStatus()
    }
}

/// Test ASTM document parsing
ClassMethod TestDocumentParsing() As %Status
{
    Try {
        // Path to test file
        Set testFile = "/data/ASTM-E1238/test/sampleE1238-clean.astm"
        
        Write "  Reading file: ", testFile, !
        
        // Check if file exists
        Set file = ##class(%File).%New(testFile)
        If '##class(%File).Exists(testFile) {
            Write "  ERROR: Test file not found: ", testFile, !
            Quit $$$ERROR($$$GeneralError, "Test file not found")
        }
        
        // Read file content
        Set stream = ##class(%FileCharacterStream).%New()
        Set stream.Filename = testFile
        Set content = stream.Read()
        
        Write "  File size: ", $Length(content), " characters", !
        Write "  First line: ", $Piece(content, $Char(13,10), 1), !
        
        // Try to parse the document
        Set reader = ##class(EnsLib.EDI.ASTM.Document).%New()
        Set status = reader.ParseDocument(content)
        
        If $$$ISERR(status) {
            Write "  PARSING ERROR: ", $System.Status.GetErrorText(status), !
            Quit status
        }
        
        Write "  OK: Document parsed successfully", !
        Write "  Document type: ", reader.DocType, !
        Write "  Segment count: ", reader.SegCount, !
        
        Quit $$$OK
        
    } Catch ex {
        Write "  ERROR: ", ex.DisplayString(), !
        Quit ex.AsStatus()
    }
}

/// Test data extraction from parsed document
ClassMethod TestDataExtraction() As %Status
{
    Try {
        Set testFile = "/data/ASTM-E1238/test/sampleE1238-clean.astm"
        
        // Parse document
        Set stream = ##class(%FileCharacterStream).%New()
        Set stream.Filename = testFile
        Set content = stream.Read()
        
        Set reader = ##class(EnsLib.EDI.ASTM.Document).%New()
        Set status = reader.ParseDocument(content)
        If $$$ISERR(status) Quit status
        
        // Extract header information
        Set headerSeg = reader.GetSegmentAt(1)
        If headerSeg="" {
            Write "  ERROR: No header segment found!", !
            Quit $$$ERROR($$$GeneralError, "No header found")   
        }
        
        Write "  Header segment: ", headerSeg, !
        
        // Count patients
        Set patientCount = 0
        For i=1:1:reader.SegCount {
            Set seg = reader.GetSegmentAt(i)
            If $Extract(seg,1,2)="P|" {
                Set patientCount = patientCount + 1
                Write "  Patient ", patientCount, ": ", $Piece(seg, "|", 6), !
            }
        }
        
        Write "  OK: Found ", patientCount, " patients", !
        Quit $$$OK
        
    } Catch ex {
        Write "  ERROR: ", ex.DisplayString(), !
        Quit ex.AsStatus()
    }
}

/// Quick test method
ClassMethod QuickTest() As %Status
{
    Write "Quick ASTM E1238 Test", !
    Write "Running schema setup...", !
    
    Do ##class(Setup.ASTME1238).Setup()
    
    Write "Testing document parsing...", !
    Do ..TestDocumentParsing()
    
    Quit $$$OK
}

}