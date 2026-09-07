/// Simulateur LAB : service HL7 TCP qui renvoie systematiquement un ACK
/// negatif (rejet) afin de reproduire, de bout en bout et sans systeme externe,
/// le cas d'usage StayConnected + ReplyCodeActions.
///
/// Il ecoute les messages emis par l'operation "vers Lab HL7 - TCP" et
/// construit une reponse :
///  - MSA-1 = AR (Application Reject) ;
///  - MSH-9 = ACK^A28^ACK (forme a 3 composants) pour exercer la tolerance
///    :T?=C de l'operation appelante.
///
/// Ce composant est purement demonstratif : en production il est remplace par
/// le vrai LAB.
Class IRISAPP.service.LabSimulator Extends EnsLib.HL7.Service.TCPService
{

/// Force l'ACK renvoye a l'appelant en rejet applicatif (AR) avec un type de
/// reponse a 3 composants (ACK^A28^ACK).
Method OnConstructReply(Output pReplyDoc As EnsLib.EDI.Document, pOriginalDoc As EnsLib.EDI.Document, ByRef pReplyCode As %String, ByRef pSC As %Status, pEarlyAck As %Boolean = 0) As %Status
{
	Set tSC = ##super(.pReplyDoc, pOriginalDoc, .pReplyCode, .pSC, pEarlyAck)
	If $IsObject($Get(pReplyDoc)) {
		Do pReplyDoc.SetValueAt("AR", "MSA:1")
		Do pReplyDoc.SetValueAt("Rejection (simulateur LAB)", "MSA:3")
		Do pReplyDoc.SetValueAt("ACK", "MSH:9.3")
	}
	Set pReplyCode = "AR"
	Quit tSC
}

}

