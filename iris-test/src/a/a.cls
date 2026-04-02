Class a.a Extends %RegisteredObject
{

Parameter TIMES = 10000;

/// Test 4 methods
ClassMethod run() As %Status
{
    Set sc = $$$OK
    w "Running method a...",!
    Do ..a(.a,1)
    w "Running method b...",!
    Do ..b(.b,1)
    w "Running method c...",!
    Do ..c(.c,1)       
    w "Running method d...",!
    Do ..d(.d,1)

    set results = $ListBuild("a", a, "b", b, "c", c, "d", d)
    
    for i=1:2:$ListLength(results) {
        set name = $List(results, i)
        set time = $List(results, i+1)
        set sorted(time, name) = ""
    }    
    w !,"Results (fastest to slowest):",!
    set time = ""

    for  {
        set time = $Order(sorted(time))
        quit:time=""
        set name = $Order(sorted(time, ""))
        w name, ": ", ..FormatTime(time), !
    }

    Return sc
}

ClassMethod a(ByRef execTime As %Numeric, debug As %Boolean = 0) As %Status
{
    Set sc = $$$OK
    set start=$zh
    set $PIECE(data,"*",300)=""                ; setup a string ‘data’ of 299 chars.
    w:debug "Data string length: ",$length(data),!

    set rec=""
    for i=1:1:..#TIMES set $PIECE(rec,"*",i)=data   ; keep adding data to $p(rec,”*”,i)
    write:debug "Record string length: ",$length(rec),!
    set execTime=$zh - start
    write:debug "Elapsed time: ",..displayTime(execTime),!

    Return sc
}

ClassMethod b(ByRef execTime As %Numeric, debug As %Boolean = 0) As %Status
{
    Set sc = $$$OK
    set start=$zh
    set data=""                                 ; setup a string ‘data’ of 0 chars.
    for i=1:1:299 set data=data_"*"                ; setup a string ‘data’ of 299 chars.
    write:debug "Data string length: ",$length(data),!

    set rec=""
    for i=1:1:..#TIMES set rec=rec_data   ; keep adding data to $p(rec,”*”,i)
    write:debug "Record string length: ",$length(rec),!
    set execTime=$zh - start
    write "execTime: ", execTime, !
    write:debug "Elapsed time: ",..displayTime(execTime),!

    Return sc
}

ClassMethod c(ByRef execTime As %Numeric, debug As %Boolean = 0) As %Status
{
    Set sc = $$$OK
    set start=$zh
    set $piece(rec,"*",2990001)=""   
    write:debug "Record string length: ",$length(rec),!
    set execTime=$zh - start
    write:debug "Elapsed time: ",..displayTime(execTime),!

    Return sc
}

ClassMethod d(ByRef execTime As %Numeric, debug As %Boolean = 0) As %Status
{
    Set sc = $$$OK
    set start=$zh
    set $PIECE(data,"*",300)=""                ; setup a string ‘data’ of 299 chars.
    write:debug "Data string length: ",$length(data),!
    for i=1:1:..#TIMES  {set $extract(rec,*+1,*+1)=data}  
    write:debug "Record string length: ",$length(rec),!
    set execTime=$zh - start
    write:debug "Elapsed time: ",..displayTime(execTime),!

    Return sc
}

/// Convert seconds to HH:MI:SS:milliseconds format
ClassMethod FormatTime(seconds As %Numeric) As %String
{
    set millis = 0
    if (seconds[".") ; if there are milliseconds
    {
        set millis = $PIECE(seconds,".",2)
        set seconds = $PIECE(seconds,".",1)
    }
    set hours = seconds \ 3600
    set remainder = seconds # 3600
    set minutes = remainder \ 60
    set secs = remainder # 60

    return $tr($justify(hours,2)," ","0") _ ":" _ 
           $tr($justify(minutes,2)," ","0") _ ":" _ 
           $tr($justify(secs,2)," ","0") _ "." _ 
           $tr($justify(millis,3)," ","0")
}

/// Convert seconds to HH:MM:SS:milliseconds format
ClassMethod displayTime(seconds) As %String [ Language = python ]
{
millis = 0
if '.' in str(seconds):
    parts = str(seconds).split('.')
    millis = parts[1] if len(parts) > 1 else "0"
    seconds = int(parts[0])

hours = seconds // 3600
remainder = seconds % 3600
minutes = remainder // 60
secs = remainder % 60

return f"{hours:02d}:{minutes:02d}:{secs:02d}.{millis:0>3}"
}

}
