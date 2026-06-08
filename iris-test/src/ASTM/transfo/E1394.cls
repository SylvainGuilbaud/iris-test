Class ASTM.transfo.E1394 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.EDI.ASTM.Document ]
{

Parameter GENERATEEMPTYSEGMENTS = 0;

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.EDI.ASTM.Document' targetClass='EnsLib.EDI.ASTM.Document' sourceDocType='E1394:P' targetDocType='E1394:P' create='new' language='objectscript' >
<assign value='source' property='target' action='set' />
<assign value='source.{Pgrp(1).C(1):CommentSource}' property='target.{Pgrp(1).Ogrp(1).O:RelevantClinicalInformation}' action='set' />
</transform>
}

}
