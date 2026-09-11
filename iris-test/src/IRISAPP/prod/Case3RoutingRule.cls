/// Route incoming case 3 messages to the dedicated case 3 operation.
Class IRISAPP.prod.Case3RoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="case 3">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1" comment="case 3: ACK^A28^ACK with MSH-9.3 populated must be accepted as a valid reply type">
<send transform="" target="case 3 operation"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
