Class HPRIM.EDI.E1238.PackedDocument Extends HPRIM.EDI.E1238.Document
{

/// Location and Revision of this file in Perforce (Auto-updating)
Parameter SrcVer = "$Id$";

/// All 5 Separators as a String,FLDSEP_REPSEP_COMSEP_ESCSEP. Increased to maxlen 5 for E1238 (sysmex mostly)
Property Separators As %String(MAXLEN = 5, MINLEN = 5) [ Transient ];

/// Set to 0 to break message into 240 char chunks, ignoring segment boundaries.<br/>
/// If set to 1 then use the normal E1238 document method to send to IO Stream - only break segments into 240 character chunks.
/// <br/>only required for sending out E1238 messages from Ensemble
/// 
Property FrameByRow As %Boolean [ InitialExpression = 0 ];

/// Max Size of E1238 frame - usually 240 characters. Sysmex SUIT system use value >4000<br/>
/// only required for sending out E1238 messages from Ensemble
Property ChunkSize As %Integer [ InitialExpression = 240 ];

Method OutputToIOStream(pIOStream As %IO.I.CharacterStream, pSeparators As %String, ByRef pDoFraming As %Integer = 0, pResponseTimeout As %Numeric = -1) As %Status
{
	// initial setup for write
	#define ABS(%n)	$S(%n>=0:%n,1:-%n)
	Set tSC=$$$OK  Set pDoFraming=$S(pDoFraming>7:2, pDoFraming<-7:-2, 1:pDoFraming)
	Set tSeparators=$S(""=$G(pSeparators):..Separators, 1:pSeparators)  Set:""=tSeparators tSeparators=$$$E1238DefSeparators
	Do:'$D($$$vaM("runtimeIndex"))&&$D($$$vaM("runtimePath")) ..buildRuntimeIndexFromPath()
	SET $ZT="Trap"

	// flag set to use default chunking
	if ..FrameByRow {
		// copied from parent classes:
		
		For i=1:1:$G($$$vaM("runtimeIndex")) {
			Set tSeg=..getSegmentByIndex(i)
			//Set tSC=tSeg.OutputToIOStream(pIOStream, tSeparators, .pDoFraming, .pResponseTimeout)
			Set data=tSeg.GetValueAt("",.pSeparators)
			if $e(data,*)'=$c(13) set data=data_$c(13)
			Set j=0 While data'="" {
				Set tDone=(tSeg.ID=""||$D(tSeg.DataArray)||'$D($$$vaSegmentGbl(tSeg.ID,j+1)))

				If 'pDoFraming { Do pIOStream.Write(data,,.tSC)  Set data="" }
				Else {
					Set tFrameNum=$$$ABS(pDoFraming)-1
					Set tChunk=$E(data,1,..ChunkSize), data=$E(data,..ChunkSize+1,*)
					Set tChunk=tFrameNum_tChunk_$S(""=data&&tDone:$$$ETX,1:$$$ETB)
					Do pIOStream.Write($$$STX_tChunk_$$$CHKSUM(tChunk)_$C(13,10),(pDoFraming<0),.tSC)
					If pDoFraming<0 {
						While 1 {
							If pResponseTimeout=-1 {
								Read tACK#1
							} Else {
								Read tACK#1:pResponseTimeout  Set tTimedOut='$Test
								If tTimedOut Set tSC=$$$ERROR($$$EnsErrTCPReadTimeoutExpired,pResponseTimeout,"A2.2 Frame ACK","binary")  Quit
							}
							Quit:$$$ACK=tACK
							Continue:$C(13,10)[tACK
							Set tSC=$$$ERROR($$$EnsErrGeneral,"Received unexpected A2.2 Frame ACK character: Ascii "_$A(tACK))
							Quit
						}
						Set pDoFraming=-1-(tFrameNum+1#8)
					} Else {
						Set pDoFraming=1+(tFrameNum+1#8)
					}
				}
				Quit:$$$ISERR(tSC)
				if ""=data&&'tDone {
					set j=j+1,data=$G($$$vaSegmentGbl(tSeg.ID,j))
					if $e(data,*)'=$c(13) set data=data_$c(13)
				}

			}
			Do:$$$ISOK(tSC)&&'pDoFraming pIOStream.Write($C(10),,.tSC)

			Do ..commitSegmentByIndex(i)
		}
		
	} else {
		// send whole message as chunks
	
		Set data = ""
		Set tIOStream=##Class(%IO.MetaCharacterStream).%New(##class(%Stream.GlobalCharacter).%New())
		Set tIOStream.LineTerminator=$c(13)
	
		; output segments to stream without framing...
		For i=1:1:$G($$$vaM("runtimeIndex")) { Set tSeg=..getSegmentByIndex(i)		
			s tsc=tSeg.OutputToIOStream(tIOStream,tSeparators, 0, .pResponseTimeout)
			Do ..commitSegmentByIndex(i)
		}
	
		do tIOStream.Rewind()
		Set i=1 While 'tIOStream.AtEnd {

			If 'pDoFraming {
				set data=tIOStream.Read()
				Do pIOStream.Write(data,,.tSC)  Set data="" 
				}
		
			Else {
				Set tFrameNum=$$$ABS(pDoFraming)-1
				Set tChunk=$tr(tIOStream.Read(..ChunkSize),$c(10),"")
				Set tChunk=tFrameNum_tChunk_$S(tIOStream.AtEnd:$$$ETX,1:$$$ETB)
				Do pIOStream.Write($$$STX_tChunk_$$$CHKSUM(tChunk)_$C(13,10),(pDoFraming<0),.tSC)
				If pDoFraming<0 {
					While 1 {
						If pResponseTimeout=-1 {
							Read tACK#1
						} Else {
							Read tACK#1:pResponseTimeout  Set tTimedOut='$Test
							If tTimedOut Set tSC=$$$ERROR($$$EnsErrTCPReadTimeoutExpired,pResponseTimeout,"A2.2 Frame ACK","binary")  Quit
						}
						Quit:$$$ACK=tACK
						Continue:$C(13,10)[tACK
						Set tSC=$$$ERROR($$$EnsErrGeneral,"Received unexpected A2.2 Frame ACK character: Ascii "_$A(tACK))
						Quit
					}
					Set pDoFraming=-1-(tFrameNum+1#8)
				} Else {
					Set pDoFraming=1+(tFrameNum+1#8)
				}
			}
			Quit:$$$ISERR(tSC)
		}
	}
	
	// clean up buffer
	If $$$ISOK(tSC) {
		If pDoFraming { Do pIOStream.Write($$$EOT,1,.tSC) }
		Else { 
			if '..FrameByRow Do pIOStream.Write($C(10),,.tSC)
			Do pIOStream.Flush(.tSC)
			}
	}
	
Exit
	Quit tSC
Trap
	Set $ZT="", tZE=$ZE, tSC=$$$SystemError
	Goto Exit
}

Storage Default
{
<Data name="PackedDocumentDefaultData">
<Subscript>"PackedDocument"</Subscript>
<Value name="1">
<Value>FrameByRow</Value>
</Value>
<Value name="2">
<Value>ChunkSize</Value>
</Value>
</Data>
<DefaultData>PackedDocumentDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
