Class CDA.PatientDemographics.BPL Extends Ens.BusinessProcessBPL
{
Parameter SETTINGS = "CDAtoSDAXSLT";
Parameter DEFAULTCDAtoSDAXSLT = "/data/CDA-R2/XSLT/CCDA-to-SDA.xsl";

Property CDAtoSDAXSLT As %String;

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process request="Ens.StreamContainer" response="Ens.Response"
         language="objectscript">

  <sequence>

    <code name="Deleguer au process CDA">
      <![CDATA[
        Set process = ##class(CDA.PatientDemographics.Process).%New()
        Set process.CDAtoSDAXSLT = ##class(CDA.PatientDemographics.BPL).#DEFAULTCDAtoSDAXSLT
        Set status = process.OnRequest(request, .response)
        If $$$ISERR(status) { $$$ThrowStatus(status) }
      ]]>
    </code>

  </sequence>
</process>
}
Storage Default
{
<Data name="BPLDefaultData">
<Subscript>"BPL"</Subscript>
<Value name="1">
<Value>CDAtoSDAXSLT</Value>
</Value>
</Data>
<DefaultData>BPLDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}