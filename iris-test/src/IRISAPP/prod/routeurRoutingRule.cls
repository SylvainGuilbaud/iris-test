/// 
Class IRISAPP.prod.routeurRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="ASTM">
<constraint name="source" value="de LIS ASTM"></constraint>
<when condition="1" comment="">
<send transform="" target="vers LIS ASTM"></send>
<send transform="IRISAPP.transfo.ASTM" target="vers BASE PATIENT"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
