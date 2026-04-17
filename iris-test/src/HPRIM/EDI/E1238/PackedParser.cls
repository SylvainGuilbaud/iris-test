/// Parser for all segments in single frame
Class HPRIM.EDI.E1238.PackedParser Extends HPRIM.EDI.E1238.Parser
{

/// Location and Revision of this file in Perforce (Auto-updating)
Parameter SrcVer = "$Id$";

// 13/9/12 added extra ENQ read for Horriba if conflict (similar to SIS)

/// Parse a complete E1238 document from the stream
Method ParseIOStream(pIOStream As %IO.I.CharacterStream, Output pDocument As HPRIM.EDI.E1238.Document, ByRef pFrameNum As %Integer = 1) As %Status
{

	Set (tSC,tSC1)=$$$OK, (pDocument,tDoc)=$$$NULLOREF, ..%Stream=pIOStream, tLine=""
	Set tStartTimeout=..StartTimeout
	Set tSubIndex=0, tSegDone=1, tSTX=..%ServiceInterface.%GetParameter("EOTOPTIONAL") ; force on expected TCP framing for this special kind of parse
	Set:'tSTX pFrameNum=1 ; reset Frame counter unless in EOTOPTIONAL mode
	
	#; Process any preceding stuff in the stream
	Set tSC=..%ServiceInterface.OnPreDocument(pIOStream,.tLine)
	if $$$ISERR(tSC)||(""=tLine&&pIOStream.AtEnd) quit tSC

	#; Read any data lines to end, just to make sure there is an actual document beginning there
	Set tFS=""
	Set (tSegName,tFirstSeg)=""
	While 'pIOStream.AtEnd && (tFirstSeg'="H") {
		Set tSC=..ReadSegment(pIOStream,tStartTimeout,.pFrameNum,.tLine,.tEOT,.tSTX)  Quit:$$$ISERR(tSC)||tEOT
		Set tStartTimeout=..ReadTimeout ; already started so go to read mode
		if $l(tLine) {
			Set tFS=$E($ZStrip($E(tLine,1,1+$$$MAXSEGNAME),"*AN")) ; separator is first non-alphanumeric char
			Set (tSegName,tFirstSeg)=$S(""=tFS:"", 1:$P(tLine,tFS))
			if tFirstSeg'="H" {
				$$$catTRACE("parse","Before H segment, discarded  '"_$$$MapCtlChars(tLine)_"'")
			}
		}
	}
	set tSegmentIds=""

	if $$$ISOK(tSC) && (tFirstSeg="H") {
	
		Set ..%SegmentCount=0
		
		// pg 17/2/11
		Set tSeparators=$E(tFS_$P(tLine,tFS,2),1,5)
        Set:$L(tSeparators)<5 tSeparators=tSeparators_$E($$$E1238DefSeparators,$L(tSeparators)+1,5)

		set tSegmentIds=""
		#; Store the data for all segments
		while $$$ISOK(tSC) && 'tEOT {  ; while
			set tSegmentIds=tSegmentIds_..StoreSegment(tLine,tSeparators)
			$$$catTRACE("parse","Got Segment "_..%SegmentCount_" '"_$$$MapCtlChars(tLine)_"'")
			Set tSC=..ReadSegment(pIOStream,tStartTimeout,.pFrameNum,.tLine,.tEOT,.tSTX)
		} 
		
		; loop through segments, processing documents
		set tLastSeg="",tSegStart=1
		for i=1:1:..%SegmentCount {
			set tSegInd=$lg(tSegmentIds,i)
			Set tDocPos=pIOStream.Name_$C(13,10)_", segment "_tSegInd_", @Line "_..%LineCount
			set tLine=$e($$$vaSegmentGbl(tSegInd),$l(tSeparators)+1,*)
			Set tSegName=$P($E(tLine,1,$$$MAXSEGNAME),tFS)

			//PG 17/2/11
			If tSegName'?1.3U {
				$$$LOGWARNING("Badly formed segment name '"_tSegName_"' at "_tDocPos_" ("_$$$MapCtlChars(tLine)_")")
				Quit
			}
			if tSegName="L" {
				Set tDoc=##class(HPRIM.EDI.E1238.Document).%New($LB($li(tSegmentIds,tSegStart,i),tSeparators,tDocPos))
				If '$IsObject(tDoc) Set tSC=%objlasterror Quit
				Set ..%CurrentDocument=tDoc

				#; Count the documents we encounter, nested
				Set tTypeName=tDoc.Name  Set:""=tTypeName tTypeName="?"
		
				#; Notify the Service of the new document beginning
				Set tSC1=..%ServiceInterface.OnDocumentStart(tDoc,tDocPos,tSC)  Quit:$$$ISERR(tSC1) // Fatal Error
	  			
				Set tSC1=..%ServiceInterface.OnDocumentEnd(tDoc,tDocPos,tSC1)  Quit:$$$ISERR(tSC1) // Fatal Error
				set tSegStart=i+1
	
			}
		} ; done doc
		if $$$ISERR(tSC) q tSC

		
		#; Process any trailing stuff in the stream
		Set tSC1=..%ServiceInterface.OnPostDocument(pIOStream,"")		
		
	} ; end if $l(tLine)
	Set:$$$ISERR(tSC1)&&(tSC'=tSC1) tSC=$$$ADDSC(tSC,tSC1)
	If $IsObject(tDoc) {
		Set ..%CurrentDocument=$$$NULLOREF
		Set pDocument=tDoc
	}
	Quit tSC
}

/// Save segment text in global
Method StoreSegment(seg As %String, tSeparators As %String) As %List [ Private ]
{
	set tXSeg=$l(seg,$c(13)),tList=""
	for i=1:1:tXSeg {
		#; save the segment and add it to the message
		Set xseg=$p(seg,$c(13),i)
		if $l(xseg) {
			Set tIndex=$I($$$vaSegmentGbl)
			Set $$$vaSegmentGbl(tIndex)=tSeparators_xseg, ..%SegmentCount=..%SegmentCount+1
			set tList=tList_$lb(tIndex)
		}
	}
	quit tList
}

Method ReadSegment(pIOStream As %IO.I.CharacterStream, pTimeout As %Numeric, ByRef pFrameNum As %Integer, Output pLine As %String, Output pEOT As %Boolean, Output pSTX As %Boolean = 0) As %Status
{
	Set pLine="", pEOT=0,tSC=$$$OK
	While 'pIOStream.AtEnd {
		#; Read 1 char
		Set tTimeout=pTimeout, tFresh=pIOStream.Read(1,.tTimeout,.tSC)  Quit:$$$ISERR(tSC)
		
		// add another read if we get ENQ first 13/09/12 pg
		if tFresh=$$$ENQ s tFresh=pIOStream.Read(1,.tTimeout,.tSC)  Quit:$$$ISERR(tSC)

		If (pTimeout&&(tTimeout=pTimeout)) { Set tSC=$$$ERROR($$$EnsErrTCPReadTimeoutExpired,pTimeout,"A2.2 <STX>","binary")  Quit }
		If $$$EOT=tFresh {
			Set pLine=pLine_tFresh, pEOT=1
			If $$$EOT'=pLine { $$$LOGWARNING("Got extra line with EOT at "_pIOStream.Name_" @Line "_..%LineCount_" : '"_$$$MapCtlChars(pLine)_"'") }
			Else { $$$catTRACE("parse","Got EOT at "_pIOStream.Name_" @Line "_..%LineCount) }
			Quit
		} ElseIf $$$STX'=tFresh && pSTX {
			If "01234567"[tFresh && ..%ServiceInterface.%GetParameter("EOTOPTIONAL") {
				Set tFresh=$$$STX_tFresh ; in case we already got it in place of ENQ
			} Else {
				Set tSC=$$$ERROR($$$EnsErrGeneral,"Unexpected A2.2 frame STX character: Ascii "_$$$MapCtlChar(tFresh))
				Quit
			}
		}
		Continue:$C(13,10)[tFresh

		#; Read rest of line
		Kill tZB  Set tTimeout=pTimeout, tFresh=tFresh_$tr(pIOStream.ReadLine(32767,.tTimeout,.tSC,.tZB),$c(0))  Quit:$$$ISERR(tSC)
		If (pTimeout&&(tTimeout=pTimeout)) { Set tSC=$$$ERROR($$$EnsErrTCPTerminatedReadTimeoutExpired,pTimeout,"A2.2 <LF>",$$$MapCtlChars(pLine_tFresh))  Quit }
		Set:""'=tFresh||(""'=tZB) ..%LineCount=..%LineCount+1, ..%CharCount=..%CharCount+$L(tFresh)+$L(tZB)

		If $$$STX=$E(tFresh) {
			Set pSTX=1
			$$$catTRACE("parse","Got STX frame line #"_..%LineCount_" '"_$$$MapCtlChars(tFresh)_"'")
			If (""'=tZB) { Write $$$ACK,*-3 }
			Else { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received incomplete A2.2 segment '"_$$$MapCtlChars(tFresh)_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
			If pFrameNum'=$E(tFresh,2) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received bad A2.2 sequence number; expected "_pFrameNum_", got '"_$$$MapCtlChars($E(tFresh,2))_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
			Set pFrameNum=(pFrameNum+1)#8
			Set tEOD=$L(tFresh)-3, tLine=$E(tFresh,3,tEOD-1)
			
			// ADDED IGNORE CHECKSUM PARAMETER FROM HOST SERVICE PG 30/4/12
			If $E(tFresh,tEOD+1,tEOD+2)'=$$$CHKSUM($E(tFresh,2,tEOD)) && '..%ServiceInterface.%GetParameter("IGNORECHECKSUM") { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received bad A2.2 checksum "_$E(tFresh,tEOD+1,tEOD+2)_"; expected "_$$$CHKSUM($E(tFresh,2,tEOD))_", got '"_$$$MapCtlChars(tFresh)_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
			//
			
			Set pLine=pLine_tLine
			If $$$ETX=$E(tFresh,tEOD) Set:$C(13)=$E(pLine,*) $E(pLine,$L(pLine))=""  Quit
			If $$$ETB'=$E(tFresh,tEOD) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received bad A2.2 frame character; expected ETX(3) or ETB(23), got "_$$$MapCtlChar($E(tFresh,tEOD))_" in '"_$$$MapCtlChars(tFresh))  Quit }
			If $Case($E(tFresh,tEOD+3,*),$C(13):0,"":0,:1) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Found extra junk at end of A2.2 frame in '"_$$$MapCtlChars(tFresh)_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
		} Else {
			Set pLine=..stripWhitespace(tFresh)
			$$$catTRACE("parse","Got raw line #"_..%LineCount_" '"_pLine_"'")
			Quit
		}
	}
	Set:""=pLine&&pIOStream.AtEnd pEOT=1
	Quit tSC
}

}
