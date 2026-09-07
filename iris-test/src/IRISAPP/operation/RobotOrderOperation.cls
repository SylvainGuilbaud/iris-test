/// Simulates a pharmacy preparation robot and returns an explicit application ACK.
Class IRISAPP.operation.RobotOrderOperation Extends Ens.BusinessOperation
{

Method OnMessage(pRequest As EnsLib.HL7.Message, Output pResponse As EnsLib.HL7.Message) As %Status
{
	Set tSC = $$$OK
	Set tRaw = pRequest.OutputToString()
	Set tControlId = ""
	Set tDose = ""
	For i = 1:1:$Length(tRaw,$C(13)) {
		Set tLine = $Piece(tRaw,$C(13),i)
		If $Piece(tLine,"|",1) = "MSH" Set tControlId = $Piece(tLine,"|",10)
		If $Piece(tLine,"|",1) = "RXE" Set tDose = $Piece(tLine,"|",3)
	}
	Set tMSA1 = $Select(tDose="":"AE",1:"AA")
	Set tText = $Select(tDose="":"Missing dose",1:"Preparation order accepted")
	Set tAck = "MSH|^~\&|ROBOT|PHARMACY|IRIS|DEMO|"_$ZDATETIME($H,3,1,3)_"||ACK^O01^ACK|"_tControlId_"|P|2.5"_$C(13)_"MSA|"_tMSA1_"|"_tControlId_"|"_tText
	Set pResponse = ##class(EnsLib.HL7.Message).ImportFromString(tAck,.tSC)
	If $$$ISERR(tSC) Quit tSC
	If tMSA1 = "AE" {
		$$$LOGWARNING("Robot rejected preparation order")
	} Else {
		$$$LOGINFO("Robot accepted preparation order")
	}
	Quit tSC
}

}
