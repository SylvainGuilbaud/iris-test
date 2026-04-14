Class IRISAPP.transfo.ASTM Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.EDI.ASTM.Document, msg.list.patient) ]
{

Parameter GENERATEEMPTYSEGMENTS = 0;

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.EDI.ASTM.Document' targetClass='msg.list.patient' sourceDocType='E1394:P' create='new' language='objectscript' >
<foreach property='source.{Pgrp()}' key='k1' >
<assign value='source.{Pgrp(k1).P:PracticeAssignedPatientId}' property='target.patients.(k1).PatientId' action='set' />
<assign value='source.{Pgrp(k1).P:PatientName.LastName}' property='target.patients.(k1).LastName' action='set' />
<assign value='source.{Pgrp(k1).P:PatientName.FirstName}' property='target.patients.(k1).FirstName' action='set' />
<assign value='$zdh(source.{Pgrp(k1).P:DateOfBirth},8)' property='target.patients.(k1).DateOfBirth' action='set' />
<assign value='source.{Pgrp(k1).P:PatientSex}' property='target.patients.(k1).Gender' action='set' />
</foreach>
</transform>
}

}
