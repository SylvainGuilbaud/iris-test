Class common.admin Extends %RegisteredObject
{
/// Description
ClassMethod clean() As %Status
{
    Set sc = $$$OK

    // Check if production is running
    If ##class(Ens.Director).IsProductionRunning() {
        set sc =  ##class(Ens.Director).StopProduction(0,1)
        If $$$ISERR(sc) {
            write "Failed to stop production, Status="_$System.OBJ.DisplayError(sc),!
            Quit sc
        } else {
            write !,"Production stopped",!
        }
    } Else {
        write !,"Production is not running",!
    }
   
    set sc = ##class(Ens.Director).CleanProduction(1)
    If $$$ISERR(sc) {
        write "Failed to clean production, Status="_$System.OBJ.DisplayError(sc),!
        Quit sc
    } else {
        write "Production cleaned",!
    }

    set sc = ##class(EnsPortal.SuspendedMsg).backgroundMethodForDiscard()
    write "Discarding suspended messages",sc,!
    
    set purged = ""
    set sc = ##class(Ens.Purge).PurgeAll(.purged,0,0,1)
    If $$$ISERR(sc) {
        write "Failed to purge messages, Status="_$System.OBJ.DisplayError(sc),!
        Quit sc
    } else {
        write "Messages purged: ",!
        zwrite purged
    }
   
    set sc = ##class(Ens.Director).StartProduction()
    If $$$ISERR(sc) {
        write "Failed to start production, Status="_$System.OBJ.DisplayError(sc),!
        Quit sc
    } else {
        write "Production started",!
    }

    Return sc
}
}
