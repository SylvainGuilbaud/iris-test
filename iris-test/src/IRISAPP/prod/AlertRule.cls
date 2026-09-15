/// 
Class IRISAPP.prod.AlertRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Ignorer les reconnexions DGLab indisponibles">
<constraint name="source" value="PatientsIn_2Op_HL7ADT_MLLP_DGLabOld"></constraint>
<when condition="Document.{AlertText} [ &quot;ErrOutConnectExpired&quot;" comment="Supprime uniquement les alertes de reconnexion TCP de cette operation">
<delete></delete>
<return></return>
</when>
</rule>
<rule name="Transmettre les autres alertes">
<when condition="1" comment="Transmet les alertes non supprimees vers l&apos;operation ALERTES">
<send transform="" target="ALERTES"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
