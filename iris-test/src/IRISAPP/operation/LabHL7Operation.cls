/// Operation HL7 sortante vers le LAB illustrant le cas d'usage
/// StayConnected + ReplyCodeActions.
///
/// Objectif : GAM -> IRIS -> LAB. Le LAB renvoie un ACK applicatif qui peut
/// etre negatif (MSA-1 = AR/CR). On veut :
///  - ne PAS boucler indefiniment sur un rejet (AR/CR traites sans retry) ;
///  - restituer l'ACK original a GAM (donc rejet force en action C) ;
///  - tolerer ACK^A28 et ACK^A28^ACK (:T?=C) ;
///  - garder une visibilite sur les rejets sans casser le retour synchrone.
///
/// Le parametrage se fait dans la production via le setting ReplyCodeActions :
/// ":?R=C,:?E=F,:~=F,:?A=C,:*=F,:I?=W,:T?=C".
/// NB : un code litteral ":AR" ne matche PAS un MSA-1 standard "AR" ; les codes
/// standard AR/CR sont uniquement captures par ":?R". Pour restituer l'ACK
/// negatif a GAM il faut donc ":?R=C" (et non ":AR=C").
/// Cette sous-classe redefinit OnReplyDocument() (cf.
/// EnsLib.HL7.Operation.ReplyStandard) pour journaliser/alerter sur les ACK
/// negatifs tout en preservant l'ACK original transmis a GAM.
Class IRISAPP.operation.LabHL7Operation Extends EnsLib.HL7.Operation.TCPOperation
{

/// Appelee pour chaque document de reponse (ACK) recu du LAB, apres
/// evaluation de ReplyCodeActions. On ne modifie pas l'ACK : on se contente
/// de tracer les rejets fonctionnels (MSA-1 = AR ou CR) pour qu'ils restent
/// observables sans generer d'erreur technique.
/// L'ACK recu n'ayant pas de DocType assigne, l'acces se fait par index de
/// segment (schema-independant) : "i:0" = nom du segment, "i:1" = champ 1.
Method OnReplyDocument(ByRef pReplyDocument As EnsLib.HL7.Message, pRequest As EnsLib.HL7.Message)
{
	Quit:'$IsObject(pReplyDocument)
	Set tType = pReplyDocument.GetValueAt("1:9")
	Set (tMSA1, tControlId, tReason) = ""
	For i = 1:1:pReplyDocument.SegCount {
		If pReplyDocument.GetValueAt(i_":0") = "MSA" {
			Set tMSA1 = pReplyDocument.GetValueAt(i_":1")
			Set tControlId = pReplyDocument.GetValueAt(i_":2")
			Set tReason = pReplyDocument.GetValueAt(i_":3")
			Quit
		}
	}
	If (tMSA1 = "AR") || (tMSA1 = "CR") {
		$$$LOGWARNING("ACK negatif recu du LAB (MSA-1="_tMSA1_") - traite en Completed OK, sans retry. Type="_tType_", ControlId="_tControlId_", Motif="_tReason)
	}
	Quit
}

}
