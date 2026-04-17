Include HPRIME1238

/// This is the ASTM Intemmrchange parser
Class HPRIM.EDI.E1238.Parser Extends %RegisteredObject [ ClassType = "", ProcedureBlock, System = 4 ]
{

// Public Properties

/// Number of seconds to wait for the start of a document to be available on the input stream
Property StartTimeout As %Numeric(MINVAL = -1) [ InitialExpression = 5 ];

/// Number of seconds to wait for each read of document data inside a started document to be available on the input stream
Property ReadTimeout As %Numeric(MINVAL = -1) [ InitialExpression = 5 ];

Property Done As %Boolean [ Calculated, ReadOnly ];

// Private State Properties

Property %Stream As %IO.I.CharacterStream;

/// Count of Segments tallied during parse of a TransactionSet
Property %SegmentCount As %Integer;

Property %LineCount As %Integer;

Property %CharCount As %Integer;

/// The config provider
Property %ServiceInterface As EnsLib.EDI.ServiceInterface;

/// The current Document
Property %CurrentDocument As EnsLib.EDI.Document;

/// The segment position within the current parent Document
Property %CurrentParentSegIndex As %String;

/// List of enclosing parent objects ordered from outermost to immediate
///  As EnsLib.EDI.Document 
Property %CurrentParents [ InitialExpression = 0, MultiDimensional ];

/// List of enclosing parent objects ordered from immediate to outermost
Property %ParentIds As %String;

/// List of counts of nested documents, ordered from outer to innermost
Property %NumChildren As %Integer [ MultiDimensional ];

/// See your HL7 Config Items for a description of accepted values.
Property Framing As %String;

/// Don't consider a blank line to indicate the end of a document
Property IgnoreBlankLines As %Boolean;

/// pre-parse of Framing setting
Property %inFraming As %String;

/// Framing to use on output if input framing is "Flexible"
Property %outFraming As %String;

/// Lookahead line left over from previous document parse
Property %LookaheadLine As %String;

/// Lookahead buffer for line terminator of unframed MSH
Property %LookaheadLineTerminator As %String;

/// Lookahead buffer for line terminator of unframed MSH
Property %LookaheadLineIsNew As %Boolean;

/// EndBlock character(s) to look for as message end marker
Property %EndBlock As %String;

/// Default Character Encoding to use when reading or writing E1238 messages. <p/>
/// If MSH field 18 (Character Set) is empty, this encoding will be used. Choices you can use for this setting include:<p/>
/// <ul>
/// <li>Native - use the default character encoding of the installed locale of the Ensemble server</li>
/// <li>latin1 - the ISO Latin1 8-bit encoding; this is the default</li>
/// <li>ISO-8859-1 - the ISO Latin1 8-bit encoding</li>
/// <li>UTF-8 - the Unicode 8-bit encoding</li>
/// <li>Unicode - the Unicode 16-bit encoding  (Little-Endian)</li>
/// <li>UnicodeBig - the Unicode 16-bit encoding (Big-Endian)</li>
/// <li>Any other NLS definitions installed on this Ensemble server</li>
/// <li>@&lt;ttable&gt; - &lt;ttable&gt; means a raw InterSystems character translation table name. A prefix of '@' means to use the named table.</li>
/// </ul>
/// Putting ! before the encoding name will force the use of the named encoding and will ignore any value found in MSH:18. <p/>
Property DefCharEncoding As %String;

/// Set this if you want to make an interface that is set to Framing='Flexible' continue with the Framing style it detects in the first message it receives.
/// This can increase performance, reduce latency due to timeouts and ensure consistent behavior after initialization.
/// However, it will also reduce the ability of the interface to interpret changing input formats in successive messages from the same source or from different sources on sequential connections.
Property RememberFlex As %Boolean [ InitialExpression = 0 ];

Method DoneGet() As %Boolean [ CodeMode = expression ]
{
('$IsObject(..%Stream)||..%Stream.AtEnd)
}

Method ReadSegment(pIOStream As %IO.I.CharacterStream, pTimeout As %Numeric, ByRef pFrameNum As %Integer, Output pLine As %String, Output pEOT As %Boolean, ByRef pSTX As %Boolean = 0) As %Status
{
	Set pLine="", pEOT=0
	While 'pIOStream.AtEnd {
		#; Read 1 char
		Set tTimeout=pTimeout, tFresh=pIOStream.Read(1,.tTimeout,.tSC)  Quit:$$$ISERR(tSC)
		If (pTimeout&&(tTimeout=pTimeout)) { Set tSC=$$$ERROR($$$EnsErrTCPReadTimeoutExpired,pTimeout,"ASTM <STX>","binary")  Quit }
		If $$$EOT=tFresh {
			Set pLine=pLine_tFresh, pEOT=1
			If $$$EOT'=pLine { $$$LOGWARNING("Got extra line with EOT at "_pIOStream.Name_" @Line "_..%LineCount_" : '"_$$$MapCtlChars(pLine)_"'") }
			Else { $$$catTRACE("parse","Got EOT at "_pIOStream.Name_" @Line "_..%LineCount) }
			Quit
		} ElseIf $$$STX'=tFresh && pSTX {
			If ..%ServiceInterface.%GetParameter("EOTOPTIONAL") {
				If "01234567"[tFresh {
					Set tFresh=$$$STX_tFresh ; in case we already got it in place of ENQ
				} ElseIf $$$ENQ=tFresh {
					Write $$$ACK,*-3
					Set pFrameNum=1
					$$$LOGWARNING("Unexpected ASTM ENQ when expecting STX character at "_pIOStream.Name_" @Line "_..%LineCount_" : '"_$$$MapCtlChars(pLine)_"'; ACK'ing and continuing to wait for segment data")
					Continue
				} Else {
					Set tSC=$$$ERROR($$$EnsErrGeneral,"Unexpected ASTM character in place of STX: Ascii "_$$$MapCtlChar(tFresh))
					Quit
				}
			} Else {
				Set tSC=$$$ERROR($$$EnsErrGeneral,"Unexpected ASTM character in place of frame STX: Ascii "_$$$MapCtlChar(tFresh))
				Quit
			}
		}
		Continue:$C(13,10)[tFresh

		#; Read rest of line
		Kill tZB  Set tTimeout=pTimeout, tFresh=tFresh_pIOStream.ReadLine(32767,.tTimeout,.tSC,.tZB)  Quit:$$$ISERR(tSC)
		If (pTimeout&&(tTimeout=pTimeout)) { Set tSC=$$$ERROR($$$EnsErrTCPTerminatedReadTimeoutExpired,pTimeout,"ASTM <LF>",$$$MapCtlChars(pLine_tFresh))  Quit }
		Set:""'=tFresh||(""'=tZB) ..%LineCount=..%LineCount+1, ..%CharCount=..%CharCount+$L(tFresh)+$L(tZB)

		If $$$STX=$E(tFresh) {
			Set pSTX=1
			Set:tZB=$C(13,10) tFresh=tFresh_$C(13), tZB=$C(10)
			$$$catTRACE("parse","Got STX frame line #"_..%LineCount_" '"_$$$MapCtlChars(tFresh)_"'")
			If (""'=tZB) { Write $$$ACK,*-3 }
			Else { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received incomplete ASTM segment '"_$$$MapCtlChars(tFresh)_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
			If pFrameNum'=$E(tFresh,2) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received bad ASTM sequence number; expected "_pFrameNum_", got '"_$$$MapCtlChars($E(tFresh,2))_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
			Set pFrameNum=(pFrameNum+1)#8
			Set tEOD=$L(tFresh)-3, tLine=$E(tFresh,3,tEOD-1)
			If $E(tFresh,tEOD+1,tEOD+2)'=$$$CHKSUM($E(tFresh,2,tEOD)) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received bad ASTM checksum "_$E(tFresh,tEOD+1,tEOD+2)_"; expected "_$$$CHKSUM($E(tFresh,2,tEOD))_", got '"_$$$MapCtlChars(tFresh)_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
			Set pLine=pLine_tLine
			If $$$ETX=$E(tFresh,tEOD) Set:$C(13)=$E(pLine,*) $E(pLine,$L(pLine))=""  Quit
			If $$$ETB'=$E(tFresh,tEOD) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Received bad ASTM frame character; expected ETX(3) or ETB(23), got "_$$$MapCtlChar($E(tFresh,tEOD))_" in '"_$$$MapCtlChars(tFresh)_"' at "_pDocPos)  Quit }
			If $Case($E(tFresh,tEOD+3,*),$C(13):0,"":0,:1) { Set tSC=$$$ERROR($$$EnsErrGeneral,"Found extra junk at end of ASTM frame in '"_$$$MapCtlChars(tFresh)_"' at "_pIOStream.Name_" @Line "_..%LineCount)  Quit }
		} Else {
			Set pLine=..stripWhitespace(tFresh)
			$$$catTRACE("parse","Got raw line #"_..%LineCount_" '"_pLine_"'")
			Quit
		}
	}
	Set:""=pLine&&pIOStream.AtEnd pEOT=1
	Quit tSC
}

/// Parse a complete ASTM document from the stream
Method ParseIOStream(pIOStream As %IO.I.CharacterStream, Output pDocument As HPRIM.EDI.E1238.Document, ByRef pFrameNum As %Integer = 1) As %Status
{
	$$$ASSERT($IsObject(pIOStream))
	Set (tSC,tSC1)=$$$OK, (pDocument,tDoc)=$$$NULLOREF, ..%Stream=pIOStream, tLine=""
	Set tStartTimeout=..StartTimeout
	Set tSubIndex=0, tSegDone=1, tSTX=..%ServiceInterface.%GetParameter("EOTOPTIONAL") ; force on expected TCP framing for this special kind of parse
	Set:'tSTX pFrameNum=1 ; reset Frame counter unless in EOTOPTIONAL mode
	Do { ; While 0
		#; Process any preceding stuff in the stream
		Set tSC=..%ServiceInterface.OnPreDocument(pIOStream,.tLine)  Quit:$$$ISERR(tSC)||(""=tLine&&pIOStream.AtEnd)

		#; Read any blank lines to end, just to make sure there is an actual document beginning there
		While ""=tLine && 'pIOStream.AtEnd {
			Set tSC=..ReadSegment(pIOStream,tStartTimeout,.pFrameNum,.tLine,.tEOT,.tSTX)  Quit:$$$ISERR(tSC)||tEOT
			Set tStartTimeout=..ReadTimeout ; already started so go to read mode
		}
		Quit:""=tLine
		$$$catTRACE("parse","Got first Segment line '"_$$$MapCtlChars(tLine)_"'")
		Set ..%SegmentCount=0
		Set tFS=$E($ZStrip($E(tLine,1,1+$$$MAXSEGNAME),"*AN")) ; separator is first non-alphanumeric char
		Set (tSegName,tFirstSeg)=$S(""=tFS:"", 1:$P(tLine,tFS))
		Set tSeparators=tFS_$P(tLine,tFS,2)
        Set:$L(tSeparators)<5 tSeparators=tSeparators_$E($$$E1238DefSeparators,$L(tSeparators)+1,5)

		#; Store the data for the first segment
		Set tIndex=$I($$$vaSegmentGbl), $$$vaSegmentGbl(tIndex)=tSeparators_tLine, tLine="", ..%SegmentCount=..%SegmentCount+1
		
		#; Instantiate a document to hold the segment and any to follow
		Set tDocPos=pIOStream.Name_$S(..%LineCount<=2:"", 1:$C(13,10)_", @Line "_..%LineCount)
		Set tDoc=##class(HPRIM.EDI.E1238.Document).%New($LB($LB(tIndex),tSeparators,tDocPos))  If '$IsObject(tDoc) Set tSC=%objlasterror Quit
		Set ..%CurrentDocument=tDoc, tSegNum=2 ; tSegNum is current segment of current document

		Set tTypeName=tDoc.Name  Set:""=tTypeName tTypeName="?"
		
		#; Notify the Service of the new document beginning
		Set tSC1=..%ServiceInterface.OnDocumentStart(tDoc,tDocPos,tSC)  Quit:$$$ISERR(tSC1) // Fatal Error
	  
		#; Parse the rest of the segments in the current document
		#;$$$catTRACE("parse","tDoc="_tDoc)
		Set (tEOF,iRef,iRefSegId)=0
		Set i = 0
		While $$$ISOK(tSC)&&(""'=tLine||'(pIOStream.AtEnd||tEOF)) { ; loop over segs in the doc
			If ""=tLine {
				#; Read a segment line buffer
				Set tSC=..ReadSegment(pIOStream,..ReadTimeout,.pFrameNum,.tLine,.tEOT,.tSTX)  Quit:$$$ISERR(tSC)||tEOT
			}
			$$$catTRACE("parse","Got next Segment line '"_$$$MapCtlChars(tLine)_"'")
			Set tPrevSeg=tSegName, tSegName=$P($E(tLine,1,$$$MAXSEGNAME),tFS)
			Set tDocPos=pIOStream.Name_$C(13,10)_", segment "_tSegNum_", @Line "_..%LineCount
			// BSU - modified
			If (tSegName'?1U)&&(tSegName'?3U) {
				$$$LOGWARNING("Badly formed segment name '"_tSegName_"' in message "_tDoc.%Id()_" at "_tDocPos_" ("_$$$MapCtlChars(tLine)_")")
				Quit
			}	
			#; save the segment and add it to the message
			Set tIndex=$I($$$vaSegmentGbl)
			Set $$$vaSegmentGbl(tIndex)=tSeparators_tLine, tLine="", tSegNum=tSegNum+1, ..%SegmentCount=..%SegmentCount+1
			Set $$$vaMobj(tDoc,"runtimeIndex")=$$$vaMobj(tDoc,"runtimeIndex")+1, $$$vaMobja(tDoc,"runtimeIndex",$$$vaMobj(tDoc,"runtimeIndex"))=tIndex

			#; Quit if not interactive and at document end segment
			Quit:('tSTX||..%ServiceInterface.%GetParameter("EOTOPTIONAL"))&&(tSegName="L")&&(tFirstSeg="H")
			s i = i+1
		} ; done doc
		Quit:$$$ISERR(tSC)

		Set tDocPos=pIOStream.Name_$C(13,10)_", @Line "_..%LineCount
		Set tSC1=..%ServiceInterface.OnDocumentEnd(tDoc,tDocPos,tSC1)  Quit:$$$ISERR(tSC1) // Fatal Error
		
		#; Process any trailing stuff in the stream
		Set tSC1=..%ServiceInterface.OnPostDocument(pIOStream,"")
	} While 0
	Set:$$$ISERR(tSC1)&&(tSC'=tSC1) tSC=$$$ADDSC(tSC,tSC1)
	If $IsObject(tDoc) {
		Set ..%CurrentDocument=$$$NULLOREF
		Set pDocument=tDoc
	}
	Quit tSC
}

/// Method used by countedTCPAdapter to correctly read ASTM segments
Method ParseFramedIOStream(pIOStream As %IO.I.CharacterStream, ByRef pDocument As HPRIM.EDI.E1238.Document, pInbound As %Boolean = 0, ByRef pIOLogEntry As Ens.Util.IOLog = {$$$NULLOREF}) As %Status
{
	$$$ASSERT($IsObject(pIOStream))
	Set (tSC,tSC1)=$$$OK, (pDocument,tDoc)=$$$NULLOREF, ..%Stream=pIOStream, tLine=""
	Set tStartTimeout=..StartTimeout
	Set tSubIndex=0, tSegDone=1, tSTX=..%ServiceInterface.%GetParameter("EOTOPTIONAL") ; force on expected TCP framing for this special kind of parse
	Set:'tSTX pFrameNum=1 ; reset Frame counter unless in EOTOPTIONAL mode
	Do { ; While 0
		#; Process any preceding stuff in the stream
		Set tSC=..%ServiceInterface.OnPreDocument(pIOStream,.tLine)  Quit:$$$ISERR(tSC)||(""=tLine&&pIOStream.AtEnd)

		#; Read any blank lines to end, just to make sure there is an actual document beginning there
		While ""=tLine && 'pIOStream.AtEnd {
			Set tSC=..ReadSegment(pIOStream,tStartTimeout,.pFrameNum,.tLine,.tEOT,.tSTX)  Quit:$$$ISERR(tSC)||tEOT
			Set tStartTimeout=..ReadTimeout ; already started so go to read mode
		}
		Quit:""=tLine
		$$$catTRACE("parse","Got first Segment line '"_$$$MapCtlChars(tLine)_"'")
		Set ..%SegmentCount=0
		Set tFS=$E($ZStrip($E(tLine,1,1+$$$MAXSEGNAME),"*AN")) ; separator is first non-alphanumeric char
		Set (tSegName,tFirstSeg)=$S(""=tFS:"", 1:$P(tLine,tFS))
		Set tSeparators=tFS_$P(tLine,tFS,2)
        Set:$L(tSeparators)<5 tSeparators=tSeparators_$E($$$E1238DefSeparators,$L(tSeparators)+1,5)

		#; Store the data for the first segment
		Set tIndex=$I($$$vaSegmentGbl), $$$vaSegmentGbl(tIndex)=tSeparators_tLine, tLine="", ..%SegmentCount=..%SegmentCount+1
		
		#; Instantiate a document to hold the segment and any to follow
		Set tDocPos=pIOStream.Name_$S(..%LineCount<=2:"", 1:$C(13,10)_", @Line "_..%LineCount)
		Set tDoc=##class(HPRIM.EDI.E1238.Document).%New($LB($LB(tIndex),tSeparators,tDocPos))  If '$IsObject(tDoc) Set tSC=%objlasterror Quit
		Set ..%CurrentDocument=tDoc, tSegNum=2 ; tSegNum is current segment of current document

		Set tTypeName=tDoc.Name  Set:""=tTypeName tTypeName="?"
		
		#; Notify the Service of the new document beginning
		Set tSC1=..%ServiceInterface.OnDocumentStart(tDoc,tDocPos,tSC)  Quit:$$$ISERR(tSC1) // Fatal Error
	  
		#; Parse the rest of the segments in the current document
		#;$$$catTRACE("parse","tDoc="_tDoc)
		Set (tEOF,iRef,iRefSegId)=0
		Set i = 0
		While $$$ISOK(tSC)&&(""'=tLine||'(pIOStream.AtEnd||tEOF)) { ; loop over segs in the doc
			If ""=tLine {
				#; Read a segment line buffer
				Set tSC=..ReadSegment(pIOStream,..ReadTimeout,.pFrameNum,.tLine,.tEOT,.tSTX)  Quit:$$$ISERR(tSC)||tEOT
			}
			$$$catTRACE("parse","Got next Segment line '"_$$$MapCtlChars(tLine)_"'")
			Set tPrevSeg=tSegName, tSegName=$P($E(tLine,1,$$$MAXSEGNAME),tFS)
			Set tDocPos=pIOStream.Name_$C(13,10)_", segment "_tSegNum_", @Line "_..%LineCount
			// BSU - modified
			If (tSegName'?1U)&&(tSegName'?3U) {
				$$$LOGWARNING("Badly formed segment name '"_tSegName_"' in message "_tDoc.%Id()_" at "_tDocPos_" ("_$$$MapCtlChars(tLine)_")")
				Quit
			}	
			#; save the segment and add it to the message
			Set tIndex=$I($$$vaSegmentGbl)
			Set $$$vaSegmentGbl(tIndex)=tSeparators_tLine, tLine="", tSegNum=tSegNum+1, ..%SegmentCount=..%SegmentCount+1
			Set $$$vaMobj(tDoc,"runtimeIndex")=$$$vaMobj(tDoc,"runtimeIndex")+1, $$$vaMobja(tDoc,"runtimeIndex",$$$vaMobj(tDoc,"runtimeIndex"))=tIndex

			#; Quit if not interactive and at document end segment
			Quit:('tSTX||..%ServiceInterface.%GetParameter("EOTOPTIONAL"))&&(tSegName="L")&&(tFirstSeg="H")
			s i = i+1
		} ; done doc
		Quit:$$$ISERR(tSC)

		Set tDocPos=pIOStream.Name_$C(13,10)_", @Line "_..%LineCount
		Set tSC1=..%ServiceInterface.OnDocumentEnd(tDoc,tDocPos,tSC1)  Quit:$$$ISERR(tSC1) // Fatal Error
		
		#; Process any trailing stuff in the stream
		Set tSC1=..%ServiceInterface.OnPostDocument(pIOStream,"")
	} While 0
	Set:$$$ISERR(tSC1)&&(tSC'=tSC1) tSC=$$$ADDSC(tSC,tSC1)
	If $IsObject(tDoc) {
		Set ..%CurrentDocument=$$$NULLOREF
		Set pDocument=tDoc
	}
	Quit tSC
}

ClassMethod applyFraming(pFraming As %String, pFlexDefault As %String = "xxf") As %String
{
	Set tFramLC=$ZCVT(pFraming,"L")
	Quit $Case($E(tFramLC,1,5),
		"none":"x",
		"flexi":pFlexDefault,
		"mllp":$C($$$E1238DefStartBlockAscii)_"x"_$C($$$E1238DefEndBlockAscii,$$$E1238DefEndDataCRAscii),
		"llp":$C($$$E1238DefStartBlockAscii)_"D21"_$C($$$E1238DefEndDataCRAscii)_"x"_$C($$$E1238DefEndBlockAscii,$$$E1238DefEndDataCRAscii)_"LxxLLP",
		"msgen":"xx<->", "mllpm":$C($$$E1238DefStartBlockAscii)_"x"_$C($$$E1238DefEndBlockAscii,$$$E1238DefEndDataCRAscii)_"xx<->",
		"ascii":$Case(tFramLC,"asciicr":"x"_$C(13),"asciilf":"x"_$C(10),"asciicrlf":"x"_$C(10),:$$framchars($E(tFramLC,6,*))),
		:$S("mllp"=$E(tFramLC,1,4):$$framchars($E(tFramLC,5,*))_$C($$$E1238DefEndDataCRAscii),
			1:$$framchars(tFramLC)))
framchars(str)
	#; Transform a string of the form nn/mm into $C(nn)_"x"_$C(mm) as before- and after- framing chars
	#; If it is just nn, make it "x"_nn because a lone framing char comes after.
	Set tPiece=$P(str,"/")
	Set tStr="" For i=1:1:$L(tPiece,",") { Set tItem=$P(tPiece,",",i)  Continue:""=tItem
		Set tStr=tStr_$C(+tItem)
	}
	Set tPiece=$P(str,"/",2)
	If ""=tPiece&&("/"'=$E(str,*)) {
		If (tStr=$C(0)) && (0'=$E(str)) { Set tStr=pFlexDefault }
		Else { Set tStr="x"_tStr }
	}
	Else {
		Set tStr=tStr_"x"
		For i=1:1:$L(tPiece,",") { Set tItem=$P(tPiece,",",i)  Continue:""=tItem
			Set tStr=tStr_$C(+tItem)
		}
		Set:"x"=$E(tStr,*) $E(tStr,$L(tStr))=""
	}
	Quit tStr
}

Method %OnNew(initvalue As %CacheString) As %Status [ Private, ProcedureBlock = 1 ]
{
	Set ..%ServiceInterface=initvalue
	Do ..Reset()
	Quit $$$OK
}

/// Strip off leading whitespace from the line
Method stripWhitespace(pLine As %String) As %String
{
	For i=1:1 { Quit:i>$L(pLine)||($C(13,10,9,32)'[$E(pLine,i)) }
	Quit $E(pLine,i,*)
}

ClassMethod mapCtlChars(s As %String) As %String
{
	Set so=""
	For i=1:1 { Set c=$E(s,i)  Quit:""=c  Set so=so_$Case(c,$C(2):"<STX>",$C(3):"<ETX>",$C(4):"<EOT>",$C(5):"<ENQ>",$C(6):"<ACK>",$C(23):"<ETB>",$C(13):"<CR>",$C(10):"<LF>",:c) }
	Quit so
}

/*Method Reset()
{
	Do ..ResetPosition()
	Set ..%Stream =$$$NULLOREF
}*/
Method Reset()
{
	Set (..%LookaheadLine,..%LookaheadLineTerminator,..%LookaheadLineIsNew)=""
	Do ..ResetPosition()
	Set ..%Stream =$$$NULLOREF
	Set (..%inFraming,..%outFraming) = "uninitialized"
	Set ..%EndBlock=""
}

Method ResetPosition()
{
	Set (..%SegmentCount,..%LineCount,..%CharCount)=0
	Set ..%CurrentDocument=$$$NULLOREF
}

}
