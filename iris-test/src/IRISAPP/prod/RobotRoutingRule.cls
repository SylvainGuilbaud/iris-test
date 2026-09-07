/// Routes pharmacy preparation orders from the source system to the robot.
Class IRISAPP.prod.RobotRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Order vers robot">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1" comment="Tout ordre HL7 recu est transmis au robot de preparation">
<send transform="" target="robot de preparation"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
