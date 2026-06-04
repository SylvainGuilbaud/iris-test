Class Demo.Msg.PatientDemographics Extends Ens.Request
{
Property SourceDocumentId As %String;
Property MRN As %String;
Property AssigningAuthority As %String;
Property FamilyName As %String;
Property GivenName As %String;
Property BirthDate As %Date;
Property Gender As %String;
Property AddressLine1 As %String;
Property City As %String;
Property State As %String;
Property PostalCode As %String;
Property Country As %String;
Property Race As %String;
Property EthnicGroup As %String;
Property MaritalStatus As %String;
Property Phone As %String;
Property Email As %String;
Storage Default
{
<Data name="PatientDemographicsDefaultData">
<Subscript>"PatientDemographics"</Subscript>
<Value name="1">
<Value>SourceDocumentId</Value>
</Value>
<Value name="2">
<Value>MRN</Value>
</Value>
<Value name="3">
<Value>AssigningAuthority</Value>
</Value>
<Value name="4">
<Value>FamilyName</Value>
</Value>
<Value name="5">
<Value>GivenName</Value>
</Value>
<Value name="6">
<Value>BirthDate</Value>
</Value>
<Value name="7">
<Value>Gender</Value>
</Value>
<Value name="8">
<Value>AddressLine1</Value>
</Value>
<Value name="9">
<Value>City</Value>
</Value>
<Value name="10">
<Value>State</Value>
</Value>
<Value name="11">
<Value>PostalCode</Value>
</Value>
<Value name="12">
<Value>Country</Value>
</Value>
<Value name="13">
<Value>Race</Value>
</Value>
<Value name="14">
<Value>EthnicGroup</Value>
</Value>
<Value name="15">
<Value>MaritalStatus</Value>
</Value>
<Value name="16">
<Value>Phone</Value>
</Value>
<Value name="17">
<Value>Email</Value>
</Value>
</Data>
<DefaultData>PatientDemographicsDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
