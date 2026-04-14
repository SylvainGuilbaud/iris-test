Class msg.response.sql Extends Ens.Response
{

Property inserted As %Integer;

Property updated As %Integer;

Property status As %Status;


Storage Default
{
<Data name="sqlDefaultData">
<Subscript>"sql"</Subscript>
<Value name="1">
<Value>inserted</Value>
</Value>
<Value name="2">
<Value>updated</Value>
</Value>
<Value name="3">
<Value>status</Value>
</Value>
</Data>
<DefaultData>sqlDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}

