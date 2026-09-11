/// Route incoming case 1 messages to the dedicated case 1 operation.
Class IRISAPP.prod.Case1RoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="case 1">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1" comment="case 1: normal client disconnection should not be treated as a fatal service error">
<send transform="" target="case 1 operation"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
