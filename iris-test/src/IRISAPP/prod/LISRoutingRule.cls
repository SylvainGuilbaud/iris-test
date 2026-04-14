/// 
Class IRISAPP.prod.LISRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="ASTM E1394">
<constraint name="source" value="de LIS ASTM E1394"></constraint>
<when condition="1" comment="">
<send transform="" target="vers LIS ASTM E1394"></send>
<send transform="IRISAPP.transfo.ASTME1394" target="vers BASE PATIENT"></send>
</when>
</rule>
<rule name="ASTM E1238" disabled="false">
<constraint name="source" value="de LIS ASTM E1238"></constraint>
<when condition="1" comment="">
<send transform="" target="vers LIS ASTM E1238"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
