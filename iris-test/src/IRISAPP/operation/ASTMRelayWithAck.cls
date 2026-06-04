Class IRISAPP.operation.ASTMRelayWithAck Extends Ens.BusinessOperation
{

Property OutputPath As %String(MAXLEN = 1000) [ InitialExpression = "/data/ASTM-E1394/out/" ];

Property SendToMLLP As %Boolean [ InitialExpression = 1 ];

Property MLLPHost As %String(MAXLEN = 255) [ InitialExpression = "host.docker.internal" ];

Property MLLPPort As %Integer(MINVAL = 1, MAXVAL = 65535) [ InitialExpression = 6661 ];

Property ConnectTimeout As %Integer(MINVAL = 1) [ InitialExpression = 5 ];

Property FailOnMLLPError As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "OutputPath,SendToMLLP,MLLPHost,MLLPPort,ConnectTimeout,FailOnMLLPError";

Method OnMessage(pRequest As EnsLib.EDI.ASTM.Document, Output pResponse As EnsLib.EDI.ASTM.Document) As %Status
{
	Set tSC = $$$OK
	Set pResponse = $$$NULLOREF

	Set tPayload = ..DocumentToString(pRequest,.tSC)
	Quit:$$$ISERR(tSC) tSC

	Set tTransformed = ..ApplyCommentC2ToOrderO12(tPayload,.tC2)

	Set tSC = ..WriteToFile(tTransformed,.tFilename)
	Quit:$$$ISERR(tSC) tSC

	If ..SendToMLLP {
		Set tMLLPSC = ..SendAsMLLP(tTransformed)
		If $$$ISERR(tMLLPSC) {
			If ..FailOnMLLPError {
				Quit tMLLPSC
			}
			$$$LOGWARNING("MLLP send failed, returning ASTM app ACK anyway: "_$$$StatusDisplayString(tMLLPSC))
		}
	}

	Set pResponse = ..BuildApplicationAck(.tSC)
	Quit tSC
}

Method DocumentToString(pRequest As EnsLib.EDI.ASTM.Document, Output pSC As %Status) As %String
{
	Set pSC = $$$OK
	Set tText = ""
	Try {
		Set tStream = ##class(%Stream.GlobalCharacter).%New()
		Do pRequest.OutputToLibraryStream(.tStream)
		Do tStream.Rewind()
		While ('tStream.AtEnd) {
			Set tLine = tStream.ReadLine()
			Set tText = tText_tLine_$C(13)
		}
	} Catch ex {
		Set pSC = ex.AsStatus()
	}
	Quit tText
}

Method ApplyCommentC2ToOrderO12(pInput As %String, Output pC2 As %String = "") As %String
{
	Set tCR = $C(13)
	Set tNorm = $Replace($Replace(pInput,$C(13,10),tCR),$C(10),tCR)
	Set tOut = ""
	Set pC2 = ""

	For i=1:1:$L(tNorm,tCR) {
		Set tLine = $P(tNorm,tCR,i)
		Continue:tLine=""

		Set tType = $P(tLine,"|",1)
		If tType="C" {
			Set pC2 = $P(tLine,"|",3)
		} ElseIf (tType="O")&&(pC2'="") {
			Set $P(tLine,"|",13) = pC2
		}

		Set tOut = tOut_tLine_tCR
	}

	Quit tOut
}

Method NormalizeOutputPath(pPath As %String) As %String
{
	If pPath="" Quit "./"
	If $E(pPath,*)'="/" Quit pPath_"/"
	Quit pPath
}

Method BuildFilename() As %String
{
	Set tTS = $ZDATETIME($H,3,1,3)
	Set tTS = $TR(tTS," /:","----")
	Set tTS = $TR(tTS,",","")
	Quit ..NormalizeOutputPath(..OutputPath)_"ASTM_E1394_"_tTS_".ast"
}

Method WriteToFile(pPayload As %String, Output pFilename As %String) As %Status
{
	Set tSC = $$$OK
	Set pFilename = ..BuildFilename()
	Try {
		Set tOut = ##class(%Stream.FileCharacter).%New()
		Set tOut.Filename = pFilename
		Do tOut.Write(pPayload)
		Set tSC = tOut.%Save()
	} Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method SendAsMLLP(pPayload As %String) As %Status
{
	Set tSC = $$$OK
	Set tDevice = "|TCP|"_..MLLPHost_":"_..MLLPPort
	Set tPrevDevice = $IO
	Try {
		Open tDevice:..ConnectTimeout
		If '$Test {
			Set tSC = $$$ERROR($$$EnsErrGeneral,"Unable to connect to MLLP target "_..MLLPHost_":"_..MLLPPort)
		} Else {
			Use tDevice Write $C(11)_pPayload_$C(28,13)
			Use tPrevDevice
			Close tDevice
		}
	} Catch ex {
		If $IO=tDevice { Use tPrevDevice }
		Try {
			Close:tDevice'="" tDevice
		} Catch {}
		Set tSC = ex.AsStatus()
	}
	If $IO'=tPrevDevice { Use tPrevDevice }
	Quit tSC
}

Method BuildApplicationAck(Output pSC As %Status) As EnsLib.EDI.ASTM.Document
{
	Set pSC = $$$OK
	Set tAck = $$$NULLOREF
	Try {
		Set tAckText = "H|\\^&|||IRIS|||||||P|E 1394-97|"_..NowAstmTs()_$C(13)_"L|1|N"_$C(13)
		Set tAck = ##class(EnsLib.EDI.ASTM.Document).ImportFromString(tAckText)
	} Catch ex {
		Set pSC = ex.AsStatus()
	}
	Quit tAck
}

Method NowAstmTs() As %String
{
	Set t = $ZDATETIME($H,3,1,3)
	Set t = $TR(t," -:/,","")
	Quit t
}

}