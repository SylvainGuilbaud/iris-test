/// 
Class IRISAPP.prod.AlertRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="Ens.AlertRequest" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Ignorer les reconnexions DGLab indisponibles">
<constraint name="source" value="PatientsIn_2Op_HL7ADT_MLLP_DGLabOld"></constraint>
<when condition="AlertText [ &quot;ErrOutConnectExpired&quot;" comment="Supprime uniquement les alertes de reconnexion TCP de cette operation">
<delete></delete>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
