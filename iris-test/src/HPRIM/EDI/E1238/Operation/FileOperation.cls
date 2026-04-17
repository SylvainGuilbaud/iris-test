Class HPRIM.EDI.E1238.Operation.FileOperation Extends HPRIM.EDI.E1238.Operation.Standard [ ClassType = "", ProcedureBlock, System = 4 ]
{

/// Name of file to output the document(s) to. May include timestamp specifiers. The %f specifier if present will be 
/// replaced with the name of the document's original source stream. (stripped of characters illegal in filenames).<p>
/// See the method Ens.Util.File.CreateTimestamp() for documentation of timestamping options.
Property Filename As %String(MAXLEN = 1000, MINLEN = 1) [ InitialExpression = "%f_%Q", Required ];

Property ASegmentsEnabled As %Boolean [ InitialExpression = 0 ];

Property MaxSegmentSize As %Integer(MAXVAL = 500, MINVAL = 20) [ InitialExpression = 220 ];

Property FileOK As %Boolean [ InitialExpression = 1 ];

Property OKSpec As %String(MAXLEN = 10) [ InitialExpression = "ok" ];

Parameter SETTINGS As %String = "Filename:Basic,FileOK:Basic,OKSpec:Basic,ASegmentsEnabled:Advanced,MaxSegmentSize:Advanced,ReplyCodeActions,RetryInterval,AlertRetryGracePeriod:Alerting,FailureTimeout,QueueCountAlert:Alerting,QueueWaitAlert:Alerting,SendSuperSession,ThrottleDelay,AlertOnError:Alerting,InactivityTimeout:Alerting,BusinessPartner:Info:partnerSelector,AlertGroups:Alerting:selector?multiSelect=1&context={Ens.ContextSearch/ProductionAlertGroups?productionName=@productionId}";

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

/// This method is for File and FTP Operations: per-message output with no reply. TCP and HTTP Operations
/// can receive reply messages.
Method OnMessage(pRequest As HPRIM.EDI.E1238.Document, Output pResponse As HPRIM.EDI.E1238.Document) As %Status
{
	#; Output the main Document
	set tSC=0
	set tSeparators=$S($L(..Separators)>=5:..Separators, 1:pRequest.Separators)
	set tFilename=..Adapter.CreateFilename(##class(%File).GetFilename($P(pRequest.Source,$C(13))),..Filename)
		
	if ('..ASegmentsEnabled)
	{
		Set tSC=..Adapter.PutStream(tFilename,pRequest,tSeparators)  Quit:$$$ISERR(tSC) tSC
		$$$sysTRACE("After "_$S(..Adapter.Overwrite:"storing",1:"appending")_" E1238 document "_pRequest_"/"_pRequest.%Id()_" to file "_tFilename)
	}
	else
	{
		
		set inputStream = ##class(%Stream.GlobalCharacter).%New()
		set outputStream = ##class(%Stream.GlobalCharacter).%New()
		set nbL=0
		$$$LOGINFO("separators:"_pRequest.Separators)
		$$$LOGINFO("first separator:"_$extract(pRequest.Separators,1,1))
		do pRequest.OutputToLibraryStream(.inputStream)
		do inputStream.Rewind()
		while ('inputStream.AtEnd) {
			set line = inputStream.ReadLine()
			do:($extract(line,1,2))'=("L"_$extract(pRequest.Separators,1,1)) ..getLinesWithASegments(line,.outputStream,.nbL)
		}
		set nbL=nbL+1
    	set lastLine="L|1||1|"_nbL
		Set tSC = outputStream.WriteLine(lastLine)
		
		Set tSC=..Adapter.PutStream(tFilename,outputStream)  Quit:$$$ISERR(tSC) tSC
		$$$sysTRACE("After "_$S(..Adapter.Overwrite:"storing",1:"appending")_" E1238 document "_pRequest_"/"_pRequest.%Id()_" to file "_tFilename)
	}
	if (tSC && ..FileOK)
	{
		s fileOKName = $P(tFilename,".",1)_"."_..OKSpec
		s emptyStream = ##class(%Stream.GlobalCharacter).%New()
		s tSC = ..Adapter.PutStream(fileOKName,emptyStream)  Quit:$$$ISERR(tSC) tSC
		$$$sysTRACE("After "_$S(..Adapter.Overwrite:"storing",1:"appending")_" ACK to file "_tFilename)
	}
	
	return tSC
}

Method getLinesWithASegments(ligne As %String(MAXLEN=""), ByRef stream As %GlobalCharacterStream, ByRef nbL As %Integer)
{
	
	if $length(ligne)>..MaxSegmentSize {
		set ligne1=$extract(ligne,1,..MaxSegmentSize)
		set tSC = stream.WriteLine(ligne1)
		set nbL=nbL+1
		for i=1:1:$length(ligne)\..MaxSegmentSize {
			set deb=(i*..MaxSegmentSize)+(1*i)
			set fin=deb+..MaxSegmentSize
			set ligneA="A|"_$extract(ligne,deb,fin)
			set tSC = stream.WriteLine(ligneA)
			set nbL=nbL+1
		}
		set deb=fin+1
		set fin=$length(ligne)
		set ligneA="A|"_$extract(ligne,deb,$length(ligne))
	} else {
		set tSC = stream.WriteLine(ligne)
		set nbL=nbL+1
	}
}

}
