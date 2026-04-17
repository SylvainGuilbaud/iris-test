Class HPRIM.transfo.H.Upper Extends Ens.DataTransformDTL [ DependsOn = HPRIM.EDI.E1238.Document ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HPRIM.EDI.E1238.Document' targetClass='HPRIM.EDI.E1238.Document' sourceDocType='HPRIM2.2:P' targetDocType='HPRIM2.2:P' create='copy' language='objectscript' >
<assign value='..ToUpper(source.{H})' property='target.{H}' action='set' />
</transform>
}

}
