/// Route incoming case 2 messages to the dedicated case 2 operation.
Class IRISAPP.prod.Case2RoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="case 2">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1" comment="case 2: downstream AR must be relayed unchanged even when the message is logged as a failure">
<send transform="" target="case 2 operation"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
