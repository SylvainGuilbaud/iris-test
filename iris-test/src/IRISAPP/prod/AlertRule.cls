/// 
Class IRISAPP.prod.AlertRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="">
<ruleSet name="IRISAPP.prod.AlertRule" effectiveBegin="" effectiveEnd="">
<rule name="Ignorer ErrOutConnectExpired" disabled="false">
<constraint name="msgClass" value="Ens.AlertRequest"></constraint>
<when condition="Document.AlertText[&quot;ErrOutConnectExpired&quot;" comment="">
<return></return>
</when>
</rule>
<rule name="Transmettre les autres alertes" disabled="false">
<constraint name="msgClass" value="Ens.AlertRequest"></constraint>
<when condition="1" comment="">
<send transform="" target="ALERTES"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
