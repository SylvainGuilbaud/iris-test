Class data.patient Extends (%Persistent, %XML.Adaptor)
{

Property PatientId As %String(MAXLEN = 50);

Property MedicalRecordNumber As %String(MAXLEN = 50);

Property FirstName As %String(MAXLEN = 100);

Property LastName As %String(MAXLEN = 100);

Property DateOfBirth As %Date(FORMAT =4);

Property Gender As %String(MAXLEN = 20);

Property Phone As %String(MAXLEN = 30);

Property Email As %String(MAXLEN = 255);

Property AddressLine1 As %String(MAXLEN = 255);

Property AddressLine2 As %String(MAXLEN = 255);

Property City As %String(MAXLEN = 100);

Property State As %String(MAXLEN = 100);

Property PostalCode As %String(MAXLEN = 20);

Property Country As %String(MAXLEN = 100);

Property CreationDate As %DateTime [InitialExpression = {$ZDATETIME($HOROLOG,3)}];
Property LastUpdateDate As %DateTime;

Storage Default
{
<Data name="patientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientId</Value>
</Value>
<Value name="3">
<Value>MedicalRecordNumber</Value>
</Value>
<Value name="4">
<Value>FirstName</Value>
</Value>
<Value name="5">
<Value>LastName</Value>
</Value>
<Value name="6">
<Value>DateOfBirth</Value>
</Value>
<Value name="7">
<Value>Gender</Value>
</Value>
<Value name="8">
<Value>Phone</Value>
</Value>
<Value name="9">
<Value>Email</Value>
</Value>
<Value name="10">
<Value>AddressLine1</Value>
</Value>
<Value name="11">
<Value>AddressLine2</Value>
</Value>
<Value name="12">
<Value>City</Value>
</Value>
<Value name="13">
<Value>State</Value>
</Value>
<Value name="14">
<Value>PostalCode</Value>
</Value>
<Value name="15">
<Value>Country</Value>
</Value>
<Value name="16">
<Value>CreationDate</Value>
</Value>
<Value name="17">
<Value>LastUpdateDate</Value>
</Value>
</Data>
<DataLocation>^data.patientD</DataLocation>
<DefaultData>patientDefaultData</DefaultData>
<IdLocation>^data.patientD</IdLocation>
<IndexLocation>^data.patientI</IndexLocation>
<StreamLocation>^data.patientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
