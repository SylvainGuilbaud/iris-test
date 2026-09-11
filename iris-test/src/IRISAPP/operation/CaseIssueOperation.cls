/// Shared operation for the three issue demonstrations.
/// It models the three specific HL7 behaviors described in:
/// - case 1: client disconnects are not fatal;
/// - case 2: downstream AR should be relayed unchanged;
/// - case 3: ACK^A28^ACK with MSH-9.3 must be accepted.
Class IRISAPP.operation.CaseIssueOperation Extends Ens.BusinessOperation
{

Property CaseName As %String(MAXLEN = 50) [ InitialExpression = "case" ];

Method OnMessage(pRequest As EnsLib.HL7.Message, Output pResponse As EnsLib.HL7.Message) As %Status
{
	Set tSC = $$$OK
	Set tRaw = pRequest.OutputToString()
	Set tControlId = ""
	For i = 1:1:$Length(tRaw,$C(13)) {
		Set tLine = $Piece(tRaw,$C(13),i)
		If $Piece(tLine,"|",1) = "MSH" Set tControlId = $Piece(tLine,"|",10)
	}
	Set tAckType = "ACK^A08^ACK"
	Set tAckCode = "AA"
	Set tText = ..CaseName_" flow processed"
	If ..CaseName = "case 1" {
		Set tText = "Client disconnect handled as informational; service should stay available for next message"
		$$$LOGWARNING("case 1: client disconnection scenario - do not treat normal disconnect as a fatal HL7 service error")
	} ElseIf ..CaseName = "case 2" {
		Set tAckType = "ACK^A28^ACK"
		Set tAckCode = "AR"
		Set tText = "Rejection relayed unchanged from downstream lab"
		$$$LOGWARNING("case 2: downstream AR must be relayed unchanged; do not synthesize CE")
	} ElseIf ..CaseName = "case 3" {
		Set tAckType = "ACK^A28^ACK"
		Set tAckCode = "AA"
		Set tText = "Valid ACK^A28^ACK reply accepted when MSH-9.3 is present"
		$$$LOGINFO("case 3: ACK^A28^ACK is valid for an A28 request and should pass reply-type validation")
	} Else {
		$$$LOGINFO("Processed "_..CaseName_" message, controlId="_tControlId)
	}
	Set tAck = "MSH|^~\\&|IRIS|CASE|SOURCE|TEST|"_$ZDATETIME($H,3,1,3) _"||"_tAckType_"|"_tControlId_"|P|2.5"_$C(13)_"MSA|"_tAckCode_"|"_tControlId_"|"_tText
	Set pResponse = ##class(EnsLib.HL7.Message).ImportFromString(tAck,.tSC)
	If $$$ISERR(tSC) Quit tSC
	Set pResponse.DocType = "2.5:ACK"
	$$$LOGINFO("Processed "_..CaseName_" message, controlId="_tControlId_" ackType="_tAckType_" msa1="_tAckCode)
	Quit tSC
}

}
