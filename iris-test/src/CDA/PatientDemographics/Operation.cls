Class CDA.PatientDemographics.Operation Extends Ens.BusinessOperation
{
Parameter INVOCATION = "Queue";

Method OnMessage(
    pRequest As Demo.Msg.PatientDemographics,
    Output pResponse As Ens.Response
) As %Status
{
    Set demo = ##class(Demo.PatientDemographics).%New()

    Set demo.SourceDocumentId = pRequest.SourceDocumentId
    Set demo.MRN = pRequest.MRN
    Set demo.AssigningAuthority = pRequest.AssigningAuthority
    Set demo.FamilyName = pRequest.FamilyName
    Set demo.GivenName = pRequest.GivenName
    Set demo.BirthDate = pRequest.BirthDate
    Set demo.Gender = pRequest.Gender
    Set demo.AddressLine1 = pRequest.AddressLine1
    Set demo.City = pRequest.City
    Set demo.State = pRequest.State
    Set demo.PostalCode = pRequest.PostalCode
    Set demo.Country = pRequest.Country
    Set demo.Race = pRequest.Race
    Set demo.EthnicGroup = pRequest.EthnicGroup
    Set demo.MaritalStatus = pRequest.MaritalStatus
    Set demo.Phone = pRequest.Phone
    Set demo.Email = pRequest.Email

    Quit demo.%Save()
}
}