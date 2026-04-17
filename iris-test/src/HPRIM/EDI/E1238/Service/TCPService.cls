Class HPRIM.EDI.E1238.Service.TCPService Extends HPRIM.EDI.E1238.Service.Standard [ ClassType = "", ProcedureBlock, System = 4 ]
{

Parameter ADAPTER = "HPRIM.EDI.E1238.Adapter.TCPAdapter";

Method OnInit() As %Status
{
	Set tSC=##super()  Quit:$$$ISERR(tSC) tSC
	Set ..%Parser.StartTimeout=..Adapter.ReadTimeout, ..%Parser.ReadTimeout=..Adapter.ReadTimeout
	Quit $$$OK
}

Method OnProcessInput(pInput As %RegisteredObject, Output pDocReceived As HPRIM.EDI.E1238.Document) As %Status
{
	Do ..%Parser.ResetPosition()
	Set tFrameNum=..Adapter.%FrameNum
	Set tSC=..%Parser.ParseIOStream(..Adapter.Socket,.pDocReceived,.tFrameNum)
	Set ..Adapter.%FrameNum=tFrameNum
	Quit tSC
}

Method standardOnProcessInput(pDocIn As HPRIM.EDI.E1238.Document, Output pDocOut As HPRIM.EDI.E1238.Document) As %Status
{
	Quit:'$IsObject(..Adapter.%SyncReplyHeader) ##super(.pDocIn,.pDocOut)

	#; If a sync response is pending, use this received input object to satisfy it.
	Set tSC=$$$OK, pDocOut=$$$NULLOREF
	$$$ASSERT($$$IsdefObject(pDocIn) && pDocIn.%IsA("HPRIM.EDI.E1238.Document"))
	$$$sysTRACE("Got Document "_pDocIn_" / "_pDocIn.%Id())
	#; get accepted doc, resolve DocType
	Set tSCVal=..resolveAndIndex(pDocIn)
	Set tResponse=$$$NULLOREF
	If $$$ISOK(tSC)&&$$$ISOK(tSCVal) {
		Set pDocIn.IsMutable=0
		Set tSC = ..Adapter.%SyncReplyHeader.NewResponseMessage(.tResponseHeader,pDocIn)
		If $$$ISERR(tSC) {
			Set tSC = ..Adapter.%SyncReplyHeader.NewErrorResponse(.tResponseHeader,tSC)
		} Else {
			Set ..Adapter.%SyncReplyHeader=$$$NULLOREF
			$$$SyncCommitSet(tSyncCommit)
			Set tSC = ##class(Ens.Queue).EnQueue(tResponseHeader)
			$$$SyncCommitClear(tSyncCommit)
		}
		Quit tSC
	} Else { ; not forwarding due to error or no target
		If $Case(..ReplyMode,"Never":0,:1) {
			If $$$ISOK(tSC)&&$$$ISOK(tSCVal) {
				$$$SyncCommitSet(tSyncCommit)
				Set pDocIn.IsMutable=0, tSC=pDocIn.%Save() ; save the document because we're going to reply to it.
				$$$SyncCommitClear(tSyncCommit)
				If $$$ISERR(tSC) {
					$$$LOGERROR("Failed to save document "_pDocIn_" / "_pDocIn.%Id()_" : "_$$$StatusDisplayString(tSC))
				}
			}
			$$$sysTRACE("Returning reply but not forwarding document "_pDocIn_"/"_pDocIn.%Id()_$S($$$ISERR(tSC):" status "_$$$StatusDisplayString(tSC),1:""))
			Set tSC=$$$ADDSC(tSC,tSCVal)
			Set pDocOut=..reportReply(pDocIn,,.tSC)
		} Else {
			$$$sysTRACE("Not returning reply for document "_pDocIn_"/"_pDocIn.%Id()_"; ReplyMode="_..ReplyMode_$S($$$ISERR(tSC):" status "_$$$StatusDisplayString(tSC),1:""))
		}
	}
	If $IsObject(tResponse) {
		Set pDocOut=..reportReply(pDocIn,tResponse,.tSC)
	}
	Quit tSC
}

Method SendReply(pReplyDocument As EnsLib.EDI.Document, pOriginalDoc As EnsLib.EDI.Document = {$$$NULLOREF}) As %Status
{
	// Enqueue it to our own adapter to send when channel is available
	Set tSC = ##class(Ens.MessageHeader).NewRequestMessage(.tRequestHeader,pReplyDocument,..%SessionId) Quit:$$$ISERR(tSC) tSC
	Set tRequestHeader.SourceConfigName = ..%ConfigName
	Set tRequestHeader.TargetConfigName = ..%ConfigName
	Set tRequestHeader.SourceBusinessType = $$$eHostTypeService
	Set tRequestHeader.TargetBusinessType = $$$eHostTypeService
	Set tRequestHeader.TargetQueueName = ..Adapter.OutQueueName
	Set tRequestHeader.Description = "ASTM ""reply"" to "_pOriginalDoc.%Id()
	Quit ##class(Ens.Queue).EnQueue(tRequestHeader)
}

}
