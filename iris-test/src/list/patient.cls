Class list.patient Extends (%Persistent, %XML.Adaptor)
{
Property patients as list of data.patient;


Storage Default
{
<Data name="patientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>patients</Value>
</Value>
</Data>
<DataLocation>^list.patientD</DataLocation>
<DefaultData>patientDefaultData</DefaultData>
<IdLocation>^list.patientD</IdLocation>
<IndexLocation>^list.patientI</IndexLocation>
<StreamLocation>^list.patientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
