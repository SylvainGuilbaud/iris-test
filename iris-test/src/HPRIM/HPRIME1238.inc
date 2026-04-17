ROUTINE HPRIME1238 [Type=INC]
#; HPRIME1238.inc
#;
#Include EnsEDI
#Include HPRIME1238Errors

#; ASTM E1238 special TCP control character codes 
#define STX             $C(2)
#define ETX             $C(3)
#define EOT             $C(4)
#define ENQ             $C(5)
#define ACK             $C(6)
#define ETB             $C(23)

#define MapCtlChar(%c)  $Case(%c,$$$STX:"<STX>",$$$ETX:"<ETX>",$$$EOT:"<EOT>",$$$ENQ:"<ENQ>",$$$ACK:"<ACK>",$$$ETB:"<ETB>",$C(13):"<CR>",$C(10):"<LF>",:"<"_$A(%c)_">")
#define MapCtlChars(%s) ##class(HPRIM.EDI.E1238.Parser).mapCtlChars(%s)
 
#; LVD array macros
#define vaSchemaGbl       ^HPRIM.E1238.Schema
#define vaSchemaDescGbl   ^HPRIM.E1238.Description
#define vaSegmentGbl      ^HPRIM.E1238.Segment
#define vaExtentGbl       ^HPRIM.EDI.E1238.DocumentD
#; Note: SchemaGbl macros are defined in EnsEDISEF
 
#ifndef LOCALMAPS
#define vaTempInstanceGbl ^CacheTemp.HPRIM.E1238
#endif
#;
#; 22 = Name MAXLEN
#define MAXSEGNAME 22
#define vaDataSegName(%segdata)        $P($E(%segdata,6,6+22-1),$$$FLDSEP(%segdata))
#define vaDataTypeName(%segdata)       $$$SEGELEM(%segdata,1)_$S("M"=$$$SEGELEM(%segdata,1):"-"_$$$SEGELEM(%segdata,3),1:"")
#define vaDataTypeVersion(%segdata)    $$$SEGELEM(%segdata,13)
#define vaDataDocIdentifier(%segdata)  $$$SEGELEM(%segdata,3)
 
#; return an 8 bit checksum value in 2 ascii hex chars
#define CHKSUM(%s)                $$$NUM($ZHex(+($ZCRC(%s,0)#256)),2)
 
#define FLDSEP(%s)                $E(%s,1)
#define SSSEP(%s)				  $E(%s,2)
#define REPSEP(%s)                $E(%s,3)
#define COMSEP(%s)                $E(%s,4)
#define ESCSEP(%s)                $E(%s,5)
 
#; Default Separator values
#define E1238DefFS  "|"
#define E1238DefSS "^"
#define E1238DefRS "~"
#define E1238DefESC "\"
#define E1238DefCS "&"
#define E1238DefSeparators  $$$E1238DefFS_$$$E1238DefSS_$$$E1238DefRS_$$$E1238DefESC_$$$E1238DefCS
 
 
#; Get stuff directly out of segment global
#define SEGELEM(%seg,%el)         $P(%seg,$$$FLDSEP(%seg),2+%el)
#define SEGIDELEM(%id,%el)        $$$SEGELEM($G($$$vaSegmentGbl(+%id)),%el)
#define SEGIDNAME(%id)            $$$SEGIDELEM(%id,0)
 
#; Enable all validation levels
#define ValidationFull            2

#; Ascii value of Start-Block marker character
#define E1238DefStartBlockAscii 11
 
#; Ascii value of End-Data marker character
#define E1238DefEndBlockAscii 28
 
#; Ascii value of End-Block marker character
#define E1238DefEndDataCRAscii 13
 
#; Ascii value of End-Segment marker character
#define E1238DefSegTerminatorAscii 13,10
 
#; For AckMode=Byte ACK
#define SingleByteAckAcceptAscii 6
 
#; For AckMode=Byte NACK
#define SingleByteAckErrorAscii 21

#; For long string support
#define E1238MaxReadLen		$S($G($$$EnsConfig("HL7-NoLongStrings")): 32760, 1: $$$MaxLocalLength - 5)
#define E1238MaxSegLen		$S($G($$$EnsConfig("HL7-NoLongStrings")): $$$MAXSEG, 1: $$$MaxLocalLength)