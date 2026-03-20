/// 
Class IRISAPP.prod.test.RoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="">
<constraint name="source" value="de HL7 ADT IHE PAM FR - TCP"></constraint>
<when condition="1" comment="">
<send transform="IRISAPP.transfo.HL7ADT" target="vers non IHE HL7v2 ADT - FICHIER"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="de HL7 ADT IHE PAM FR - FICHIER"></constraint>
<when condition="" comment="">
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
