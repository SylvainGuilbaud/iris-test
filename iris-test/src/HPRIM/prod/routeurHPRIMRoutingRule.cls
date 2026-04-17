/// 
Class HPRIM.prod.routeurHPRIMRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="HPRIM.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="HPRIM TCP" disabled="false">
<constraint name="source" value="HPRIMTCPService"></constraint>
<when condition="1" comment="">
<send transform="HPRIM.transfo.test" target=",vers HPRIM FTP"></send>
<return></return>
</when>
</rule>
<send transform="HPRIM.transfo.test" target="HPRIM out,vers HPRIM FTP,vers HPRIM TCP"></send>
</ruleSet>
</ruleDefinition>
}

}
