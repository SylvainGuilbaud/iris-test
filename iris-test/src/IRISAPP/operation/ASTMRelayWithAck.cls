Class IRISAPP.operation.ASTMRelayWithAck Extends Ens.BusinessOperation
{

Parameter INVOCATION = "InProc";

Property OutputPath As %String(MAXLEN = 1000) [ InitialExpression = "/data/ASTM-E1394/out/" ];

Property SendToMLLP As %Boolean [ InitialExpression = 1 ];

Property MLLPHost As %String(MAXLEN = 255) [ InitialExpression = "host.docker.internal" ];

Property MLLPPort As %Integer(MINVAL = 1, MAXVAL = 65535) [ InitialExpression = 6662 ];

Property ConnectTimeout As %Integer(MINVAL = 1) [ InitialExpression = 5 ];

Property FailOnMLLPError As %Boolean [ InitialExpression = 0 ];

Property WaitForMLLPAck As %Boolean [ InitialExpression = 1 ];

Property MLLPAckTimeout As %Integer(MINVAL = 1) [ InitialExpression = 5 ];

Property ForceEchoResponse As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "OutputPath,SendToMLLP,MLLPHost,MLLPPort,ConnectTimeout,FailOnMLLPError,WaitForMLLPAck,MLLPAckTimeout,ForceEchoResponse";

Method OnMessage(pRequest As EnsLib.EDI.ASTM.Document, Output pResponse As EnsLib.EDI.ASTM.Document) As %Status
{
	Set tSC = $$$OK
	Set pResponse = $$$NULLOREF
	Set tStartH = $HOROLOG
	Set tMsgId = $JOB
	Set tMLLPState = "skipped"
	Set tFilename = ""
	Set tAckSent = 0
	$$$LOGINFO("ASTM relay start: Session="_tMsgId_", SendToMLLP="_..SendToMLLP)
	Do ..EnsureDocType(.pRequest)

	Set tPayload = ..DocumentToString(pRequest,.tSC)
	If $$$ISERR(tSC) {
		$$$LOGERROR("ASTM relay failed at DocumentToString, Session="_tMsgId_", Status="_$$$StatusDisplayString(tSC))
		Quit tSC
	}

	Set tTransformed = ..ApplyCommentC2ToOrderO12(tPayload,.tC2)

	Set tSC = ..WriteToFile(tTransformed,.tFilename)
	If $$$ISERR(tSC) {
		$$$LOGERROR("ASTM relay failed at WriteToFile, Session="_tMsgId_", Status="_$$$StatusDisplayString(tSC))
		Quit tSC
	}

	If ..SendToMLLP {
		$$$LOGINFO("ASTM relay MLLP send: Session="_tMsgId_", Target="_..MLLPHost_":"_..MLLPPort)
		Set tMLLPSC = ..SendAsMLLP(tTransformed)
		If $$$ISERR(tMLLPSC) {
			Set tMLLPState = "failed"
			If ..FailOnMLLPError {
				$$$LOGERROR("ASTM relay failed at MLLP send (strict mode), Session="_tMsgId_", Status="_$$$StatusDisplayString(tMLLPSC))
				Quit tMLLPSC
			}
			$$$LOGWARNING("MLLP send failed, returning ASTM app ACK anyway: "_$$$StatusDisplayString(tMLLPSC))
		} Else {
			Set tMLLPState = "sent"
		}
	}

	If ..ForceEchoResponse {
		Set pResponse = pRequest
		Set tSC = $$$OK
		$$$LOGWARNING("ASTM relay diagnostic mode enabled: echoing request as application response")
	} Else {
		Set pResponse = ..BuildApplicationAck(.tSC)
	}
	Set tAckSent = $Select($IsObject(pResponse):1,1:0)
	If $$$ISERR(tSC) {
		$$$LOGERROR("ASTM relay failed at BuildApplicationAck, Session="_tMsgId_", Status="_$$$StatusDisplayString(tSC))
		Quit tSC
	}

	Set tDurationSec = ..ElapsedSeconds(tStartH,$HOROLOG)
	$$$LOGINFO("ASTM relay completed: Session="_tMsgId_", DurationSec="_tDurationSec_", File="_tFilename_", MLLP="_tMLLPState_", AckSent="_tAckSent)
	Quit tSC
}

Method ElapsedSeconds(pStart As %String, pEnd As %String) As %Integer [ CodeMode = expression ]
{
($PIECE(pEnd,",",1)-$PIECE(pStart,",",1))*86400+($PIECE(pEnd,",",2)-$PIECE(pStart,",",2))
}

Method EnsureDocType(ByRef pDoc As EnsLib.EDI.ASTM.Document)
{
	Do pDoc.PokeDocType("E1394:P")
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
			If ..WaitForMLLPAck {
				Set tResp = ""
				Read tAck#1:..MLLPAckTimeout
				If '$Test {
					$$$LOGWARNING("ASTM relay MLLP ACK timeout after "_..MLLPAckTimeout_"s (continuing)")
				} Else {
					Set tResp = tAck
					For {
						Quit:tResp[$C(28,13)
						Quit:$L(tResp)>8192
						Read tAck#1:0
						Quit:'$Test
						Set tResp = tResp_tAck
					}
					$$$LOGINFO("ASTM relay MLLP ACK received: bytes="_$L(tResp)_", preview="_$E(tResp,1,80))
				}
			}
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
		Set tAckText = "H|\^&|||IRIS|||||||P|E 1394-97|"_..NowAstmTs()_$C(13)_"L|1|N"_$C(13)
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