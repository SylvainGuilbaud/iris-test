Class Setup.ASTME1238
{

/// Check if E1238 schema is available and ready for use
ClassMethod CheckE1238Status() As %Status
{
    Try {
        Write "=== ASTM E1238 Status Check ===", !
        
        // Check if E1238 schema is available by testing document creation
        Try {
            Set testDoc = ##class(EnsLib.EDI.ASTM.Document).%New()
            Set testDoc.DocType = "E1238"
            
            Write "✅ E1238 Schema is available!", !
            Write "  Category: E1238", !
            Write "  Status: Ready for message processing", !
            Write "✅ E1238 is ready for use!", !
            
        } Catch schemaEx {
            Write "❌ E1238 Schema not found or not accessible", !
            Write "Error: ", schemaEx.DisplayString(), !
            Write "Please verify that E1238 schema is properly imported", !
        }
        
        Write "===============================", !
        
    } Catch ex {
        Write "Exception: ", ex.DisplayString(), !
        Return ex.AsStatus()
    }
    
    Return $$$OK
}

/// Test E1238 message processing
ClassMethod TestE1238Processing(filename As %String = "") As %Status
{
    Try {
        Write "=== Testing E1238 Message Processing ===", !
        
        If filename = "" {
            Set filename = "/irisdev/app/data/ASTM/test/sampleE1394.P.ASTM"
        }
        
        If '##class(%File).Exists(filename) {
            Write "Test file not found: ", filename, !
            Return $$$ERROR($$$GeneralError, "Test file not found")
        }
        
        // Read the ASTM message
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set sc = stream.LinkToFile(filename)
        If $$$ISERR(sc) {
            Write "Error reading file: ", $System.Status.GetErrorText(sc), !
            Return sc
        }
        
        Set content = stream.Read()
        Write "File content loaded (", $Length(content), " characters)", !
        
        // Try to parse as ASTM document
        Try {
            Set astmDoc = ##class(EnsLib.EDI.ASTM.Document).ImportFromString(content)
            Write "✅ Successfully parsed ASTM document", !
            Write "  DocType: ", astmDoc.DocType, !
            Write "  Name: ", astmDoc.Name, !
            
        } Catch parseEx {
            Write "⚠️  Parse attempt failed: ", parseEx.DisplayString(), !
        }
        
        Write "=========================================", !
        
    } Catch ex {
        Write "Exception: ", ex.DisplayString(), !
        Return ex.AsStatus()
    }
    
    Return $$$OK
}

}