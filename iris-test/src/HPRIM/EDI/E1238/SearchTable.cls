Class HPRIM.EDI.E1238.SearchTable Extends (%Persistent, Ens.VDoc.SearchTable) [ ClassType = persistent, CompileAfter = HPRIM.EDI.E1238.Document, Inheritance = right, ProcedureBlock, System = 4 ]
{

Parameter DOCCLASS = "HPRIM.EDI.E1238.Document";

Parameter EXTENTSIZE = 4000000;

/* Re-declare indices because the superclass is abstract */
Index indexValue On (PropId, PropValue, DocId) [ IdKey, Unique ];

Index indexDocId On (DocId, PropId, PropValue) [ Unique ];

XData SearchSpec [ XMLNamespace = "http://www.intersystems.com/EnsSearchTable" ]
{
<Items>
<Item DocType=""  PropName="Identifier" >Identifier</Item>
</Items>
}

Storage Default
{
<Data name="SearchTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^HPRIM.EDI.E1238.SearchTableD</DataLocation>
<DefaultData>SearchTableDefaultData</DefaultData>
<ExtentSize>4000000</ExtentSize>
<IdLocation>^HPRIM.EDI.E1238.SearchTableD</IdLocation>
<IndexLocation>^HPRIM.EDI.E1238.SearchTableI</IndexLocation>
<StreamLocation>^HPRIM.EDI.E1238.SearchTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
