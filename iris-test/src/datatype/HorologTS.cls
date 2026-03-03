Class datatype.HorologTS Extends %Library.DataType
{

Parameter LOGICALTYPE = "%String";

Parameter MAXLEN = 23;

ClassMethod LogicalToStorage(val As %String) As %String
{
    quit $ZDATETIMEH(val,3)
}

ClassMethod StorageToLogical(val As %String) As %String
{
    quit $ZDATETIME(val,3)
}

}
