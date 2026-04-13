Class Tutorial.ProductionTest Extends %UnitTest.TestProduction
{

Parameter PRODUCTION = "Tutorial.ExampleProduction";

Parameter IGNOREPRODUCTIONERRORS = 1;

Method OnAfterProductionStart() As %Status
{
 Set request = ##class(Ens.StringRequest).%New()
 set request.StringValue="Hello Productions"
 Set tSC = ..SendRequest( "Tutorial.ExampleOperation" ,request, 
                                                       .response,1,40)
 Do $$$AssertEquals(response.StringValue,"OK","Response should contain OK.")
 Set request.StringValue=""
 Set tSC = ..SendRequest( "Tutorial.ExampleOperation" ,request, 
                                                        .response,1,40)
 Set tSC = ..SendRequest( "Tutorial.ExampleOperation" ,request, 
                                                        .response,1,40)                                               
 Return $$$OK
}

Method CheckResults(ByRef Log As %String, New As %String) As %Status
{
 Set tSC = $$$OK 
 merge ^myLog=Log
 merge ^myNew=New
 Set r = $$$AssertEquals($Get(New),3,"Should be 3 (found: "_+$Get(New)_")")

 Set text = $Get(Log(1,"Text"))
 Do $$$AssertEquals(text,"OK","Should be 'OK' (found: '"_text_"')")

 Set text = $Get(Log(2,"Text"))
 Do $$$AssertEquals(text,"ERROR","Should be 'ERROR' (found: '"_text_"')")

 if 'r set tSC=..Error("Expected event log entries don't match")

 Return tSC
}

Method CheckErrors() As %Status
{
 Set tSC = $$$OK
 Set s = ..GetEventLog("error","","",.err,.new)
 merge ^myErr=err
 merge ^myNewErrors=new

 Set s1 = $$$AssertEquals(new,2,"Should be 2 new errors(found: "_+$Get(new)_")")

 Set text = $Get(err(1,"Text"))
 Set eText = "Test error case"
 Set s2 = $$$AssertTrue(text[eText,"Should contain '"_eText_"'(found: '"_text_"')")

 if 's1||'s2 set tSC=..Error("Expected error entries don't match")
 Return tSC
}

}
