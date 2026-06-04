Class Demo.PatientDemographics Extends %Persistent
{
Property SourceDocumentId As %String(MAXLEN = 128);

Property MRN As %String(MAXLEN = 64);

Property AssigningAuthority As %String(MAXLEN = 128);

Property FamilyName As %String(MAXLEN = 128);

Property GivenName As %String(MAXLEN = 128);

Property BirthDate As %Date;

Property Gender As %String(MAXLEN = 32);

Property AddressLine1 As %String(MAXLEN = 256);

Property City As %String(MAXLEN = 128);

Property State As %String(MAXLEN = 128);

Property PostalCode As %String(MAXLEN = 32);

Property Country As %String(MAXLEN = 64);

Property Race As %String(MAXLEN = 128);

Property EthnicGroup As %String(MAXLEN = 128);

Property MaritalStatus As %String(MAXLEN = 128);

Property Phone As %String(MAXLEN = 64);

Property Email As %String(MAXLEN = 256);

Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3,1)} ];

Index MRNIdx On (MRN, AssigningAuthority);
Storage Default
{
<Data name="PatientDemographicsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SourceDocumentId</Value>
</Value>
<Value name="3">
<Value>MRN</Value>
</Value>
<Value name="4">
<Value>AssigningAuthority</Value>
</Value>
<Value name="5">
<Value>FamilyName</Value>
</Value>
<Value name="6">
<Value>GivenName</Value>
</Value>
<Value name="7">
<Value>BirthDate</Value>
</Value>
<Value name="8">
<Value>Gender</Value>
</Value>
<Value name="9">
<Value>AddressLine1</Value>
</Value>
<Value name="10">
<Value>City</Value>
</Value>
<Value name="11">
<Value>State</Value>
</Value>
<Value name="12">
<Value>PostalCode</Value>
</Value>
<Value name="13">
<Value>Country</Value>
</Value>
<Value name="14">
<Value>Race</Value>
</Value>
<Value name="15">
<Value>EthnicGroup</Value>
</Value>
<Value name="16">
<Value>MaritalStatus</Value>
</Value>
<Value name="17">
<Value>Phone</Value>
</Value>
<Value name="18">
<Value>Email</Value>
</Value>
<Value name="19">
<Value>CreatedAt</Value>
</Value>
</Data>
<DataLocation>^Demo.PatientDemographicsD</DataLocation>
<DefaultData>PatientDemographicsDefaultData</DefaultData>
<IdLocation>^Demo.PatientDemographicsD</IdLocation>
<IndexLocation>^Demo.PatientDemographicsI</IndexLocation>
<StreamLocation>^Demo.PatientDemographicsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}