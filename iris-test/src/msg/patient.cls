Class msg.patient Extends Ens.Request
{

Property PatientId As %String(MAXLEN = 50);

Property MedicalRecordNumber As %String(MAXLEN = 50);

Property FirstName As %String(MAXLEN = 100);

Property LastName As %String(MAXLEN = 100);

Property DateOfBirth As %Date;

Property Gender As %String(MAXLEN = 20);

Property Phone As %String(MAXLEN = 30);

Property Email As %String(MAXLEN = 255);

Property AddressLine1 As %String(MAXLEN = 255);

Property AddressLine2 As %String(MAXLEN = 255);

Property City As %String(MAXLEN = 100);

Property State As %String(MAXLEN = 100);

Property PostalCode As %String(MAXLEN = 20);

Property Country As %String(MAXLEN = 100);


Storage Default
{
<Data name="patientDefaultData">
<Subscript>"patient"</Subscript>
<Value name="1">
<Value>PatientId</Value>
</Value>
<Value name="2">
<Value>MedicalRecordNumber</Value>
</Value>
<Value name="3">
<Value>FirstName</Value>
</Value>
<Value name="4">
<Value>LastName</Value>
</Value>
<Value name="5">
<Value>DateOfBirth</Value>
</Value>
<Value name="6">
<Value>Gender</Value>
</Value>
<Value name="7">
<Value>Phone</Value>
</Value>
<Value name="8">
<Value>Email</Value>
</Value>
<Value name="9">
<Value>AddressLine1</Value>
</Value>
<Value name="10">
<Value>AddressLine2</Value>
</Value>
<Value name="11">
<Value>City</Value>
</Value>
<Value name="12">
<Value>State</Value>
</Value>
<Value name="13">
<Value>PostalCode</Value>
</Value>
<Value name="14">
<Value>Country</Value>
</Value>
</Data>
<DefaultData>patientDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
