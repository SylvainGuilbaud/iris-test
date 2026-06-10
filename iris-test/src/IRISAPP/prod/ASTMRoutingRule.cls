/// 
Class IRISAPP.prod.ASTMRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.EDI.MsgRouter.SegmentedRuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.EDI.MsgRouter.SegmentedRoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="équipement émetteur = COBAS 8000">
<when condition="Document.{H:SenderNameOrId.SenderNameOrId}=&quot;COBAS8000&quot;" comment="">
<send transform="ASTM.transfo.E1394" target="vers ASTM E1394 - FICHIER"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
