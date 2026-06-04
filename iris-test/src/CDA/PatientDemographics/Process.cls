Class CDA.PatientDemographics.Process Extends Ens.BusinessProcess
{
Parameter SETTINGS = "CDAtoSDAXSLT";

Property CDAtoSDAXSLT As %String;

Method OnRequest(
    pRequest As Ens.StreamContainer,
    Output pResponse As Ens.Response
) As %Status
{
    Set sc = $$$OK

    Try {

        Set debugToken = $Piece($Horolog,",",1)_"-"_$Piece($Horolog,",",2)_"-"_$Job

        $$$TRACE("XSLT path="_..CDAtoSDAXSLT)

        Set cdaStream = pRequest.Stream

        If '$IsObject(cdaStream) {
            Set sc = $$$ERROR($$$GeneralError, "Stream CDA absent")
            Quit
        }

        Set sc = cdaStream.Rewind()
        If $$$ISERR(sc) {
            Quit
        }

        Set first = cdaStream.Read(200)
        $$$TRACE("Début du stream CDA = "_first)

        Set sc = cdaStream.Rewind()
        If $$$ISERR(sc) {
            Quit
        }

        Set cdaDebugPath = "/data/CDA-R2/work/cda-debug-"_debugToken_".xml"
        Set cdaDebugStream = ##class(%Stream.FileCharacter).%New()
        Set scDebug = cdaDebugStream.LinkToFile(cdaDebugPath)
        If $$$ISERR(scDebug) {
            $$$TRACE("Impossible d'ouvrir le fichier CDA debug = "_$System.Status.GetErrorText(scDebug))
        } Else {
            Set scDebug = cdaDebugStream.CopyFrom(cdaStream)
            If $$$ISERR(scDebug) {
                $$$TRACE("Impossible d'écrire le fichier CDA debug = "_$System.Status.GetErrorText(scDebug))
            } Else {
                $$$TRACE("Stream CDA complet écrit dans "_cdaDebugPath)
            }
        }

        Set sc = cdaStream.Rewind()
        If $$$ISERR(sc) {
            Quit
        }

        Set sda = ##class(HS.SDA3.Container).%New()

       Set sdaStream = ##class(%Stream.GlobalCharacter).%New()

        Set transformer = ##class(%XML.XSLT.Transformer).%New()

        Set sc = transformer.TransformStream(
            cdaStream,
            ..CDAtoSDAXSLT,
            sdaStream
        )
        If $$$ISERR(sc) {
            Quit
        }
        If $$$ISERR(sc) {
            Quit
        }

        Set sc = sdaStream.Rewind()
        If $$$ISERR(sc) {
            Quit
        }

        Set sdaDebugPath = "/data/CDA-R2/work/sda-debug-"_debugToken_".xml"
        Set sdaDebugStream = ##class(%Stream.FileCharacter).%New()
        Set scDebug = sdaDebugStream.LinkToFile(sdaDebugPath)
        If $$$ISERR(scDebug) {
            $$$TRACE("Impossible d'ouvrir le fichier SDA debug = "_$System.Status.GetErrorText(scDebug))
        } Else {
            Set scDebug = sdaDebugStream.CopyFrom(sdaStream)
            If $$$ISERR(scDebug) {
                $$$TRACE("Impossible d'écrire le fichier SDA debug = "_$System.Status.GetErrorText(scDebug))
            } Else {
                $$$TRACE("Stream SDA complet écrit dans "_sdaDebugPath)
            }
        }

        Set sc = sdaStream.Rewind()
        If $$$ISERR(sc) {
            Quit
        }

        Set sc = ##class(HS.SDA3.Container).XMLImportSDAFromStream(
            sdaStream,
            .sda
        )
        If $$$ISERR(sc) {
            Quit
        }
        Quit:$$$ISERR(sc)

        Set msg = ##class(Demo.Msg.PatientDemographics).%New()

        Set sc = ##class(Demo.DTL.SDAToPatientDemographics).Transform(
            sda,
            .msg
        )
        Quit:$$$ISERR(sc)

        Set msg.SourceDocumentId = pRequest.%Id()

        Set sc = ..SendRequestSync(
            "CDA.PatientDemographics.Operation",
            msg,
            .pResponse
        )
    }
    Catch ex {
        Set sc = ex.AsStatus()
    }

    Quit sc
}
Storage Default
{
<Data name="ProcessDefaultData">
<Subscript>"Process"</Subscript>
<Value name="1">
<Value>CDAtoSDAXSLT</Value>
</Value>
</Data>
<DefaultData>ProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}