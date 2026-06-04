Class Demo.DTL.SDAToPatientDemographics Extends Ens.DataTransformDTL
{

Parameter IGNOREMISSINGSOURCE = 1;
Parameter REPORTERRORS = 1;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass="HS.SDA3.Container"
           targetClass="Demo.Msg.PatientDemographics"
           create="new"
           language="objectscript">

  <assign property="target.SourceDocumentId"
          value="source.ExternalId"
          action="set"/>

  <assign property="target.FamilyName"
          value="source.Patient.Name.FamilyName"
          action="set"/>

  <assign property="target.GivenName"
          value="source.Patient.Name.GivenName"
          action="set"/>

  <assign property="target.BirthDate"
          value="source.Patient.BirthTime"
          action="set"/>

  <assign property="target.Gender"
          value="source.Patient.Gender"
          action="set"/>

  <if condition="source.Patient.PatientNumbers.Count() &gt; 0">
    <true>
      <assign property="target.MRN"
              value="source.Patient.PatientNumbers.GetAt(1).Number"
              action="set"/>

      <assign property="target.AssigningAuthority"
              value="source.Patient.PatientNumbers.GetAt(1).Organization"
              action="set"/>
    </true>
  </if>

  <if condition="source.Patient.Addresses.Count() &gt; 0">
    <true>
      <assign property="target.AddressLine1"
              value="source.Patient.Addresses.GetAt(1).Street"
              action="set"/>

      <assign property="target.City"
              value="source.Patient.Addresses.GetAt(1).City"
              action="set"/>

      <assign property="target.State"
              value="source.Patient.Addresses.GetAt(1).State"
              action="set"/>

      <assign property="target.PostalCode"
              value="source.Patient.Addresses.GetAt(1).Zip"
              action="set"/>

      <assign property="target.Country"
              value="source.Patient.Addresses.GetAt(1).Country"
              action="set"/>
    </true>
  </if>

  <if condition="$IsObject(source.Patient.ContactInfo)">
    <true>
      <if condition="source.Patient.ContactInfo.PhoneNumbers.Count() &gt; 0">
        <true>
          <assign property="target.Phone"
                  value="source.Patient.ContactInfo.PhoneNumbers.GetAt(1).Number"
                  action="set"/>
        </true>
      </if>

      <if condition="source.Patient.ContactInfo.EmailAddresses.Count() &gt; 0">
        <true>
          <assign property="target.Email"
                  value="source.Patient.ContactInfo.EmailAddresses.GetAt(1).Address"
                  action="set"/>
        </true>
      </if>
    </true>
  </if>

  <assign property="target.Race"
          value="source.Patient.Race"
          action="set"/>

  <assign property="target.EthnicGroup"
          value="source.Patient.EthnicGroup"
          action="set"/>

  <assign property="target.MaritalStatus"
          value="source.Patient.MaritalStatus"
          action="set"/>

</transform>
}
}