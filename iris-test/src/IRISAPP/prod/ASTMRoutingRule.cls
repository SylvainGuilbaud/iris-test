/// 
Class IRISAPP.prod.ASTMRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="ASTM">
<when condition="1" comment="">
<send transform="ASTM.transfo.E1394" target="vers ASTM E1394 - FICHIER"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
