Class data.patient Extends %RegisteredObject
{

Property PatientId As %String(MAXLEN = 50);

Property MedicalRecordNumber As %String(MAXLEN = 50);

Property FirstName As %String(MAXLEN = 100);

Property LastName As %String(MAXLEN = 100);

Property DateOfBirth As %Date;

Property Gender As %String(MAXLEN = 20);

Property Phone As %String(MAXLEN = 30);

Property Email As %String(MAXLEN = 255);

Property AddressLine1 As %String(MAXLEN = 255);

Property AddressLine2 As %String(MAXLEN = 255);

Property City As %String(MAXLEN = 100);

Property State As %String(MAXLEN = 100);

Property PostalCode As %String(MAXLEN = 20);

Property Country As %String(MAXLEN = 100);

Property Age As %Integer [ Calculated, SqlComputed ];
Method AgeGet() As %Integer [ SqlComputeCode { set {*}= ##class(data.patient).CalculateAge({DateOfBirth}) }, SqlComputed ]
{
    quit ..CalculateAge(..DateOfBirth)
}

ClassMethod CalculateAge(dob As %Date) As %Integer
{
    if dob = "" quit ""
    set today = +$h
    set age = $extract(today, 1, 3) - $extract(dob, 1, 3)
    if $extract(today, 5, 8) < $extract(dob, 5, 8) set age = age - 1
    quit age
}

}
