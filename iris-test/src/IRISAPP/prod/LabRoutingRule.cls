/// Regle de routage du flux GAM -> LAB.
/// Relaye tout message HL7 (ADT) recu de GAM vers l'operation LAB et
/// retourne l'ACK au service appelant (donc a GAM).
Class IRISAPP.prod.LabRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="IRISAPP.prod.test">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="ADT vers LAB">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1" comment="Tout message ADT recu de GAM est relaye vers le LAB">
<send transform="" target="vers Lab HL7 - TCP"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
