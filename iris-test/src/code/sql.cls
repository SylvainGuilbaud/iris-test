Class code.sql Extends %RegisteredObject
{

ClassMethod select(age As %Integer) As %Status
{
    Set sc = $$$OK
    Set query = "SELECT Name, Age FROM data.Patients WHERE Age > "_age
    Set statement = ##class(%SQL.Statement).%New()
    Set status = statement.%Prepare(query)
    Return sc
}

}
