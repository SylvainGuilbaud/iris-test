Class data.customer Extends (%Persistent, %Populate)
{

Parameter ROWLEVELSECURITY = 1;

ClassMethod %SecurityPolicy(Country As %String) As %String [ SqlProc ]
{
    return "%All,"_Country
}

/// Customer first name
Property FirstName As %String(MAXLEN = 100, POPSPEC = "FirstName()") [ Required ];

/// Customer last name
Property LastName As %String(MAXLEN = 100, POPSPEC = "LastName()") [ Required ];

/// Customer email address
Property Email As %String(MAXLEN = 255) [ Required ];

/// Customer phone number
Property Phone As %String(MAXLEN = 20);

/// Customer date of birth
Property DateOfBirth As %Date;

/// Customer street address
Property Street As %String(MAXLEN = 255);

/// Customer city
Property City As %String(MAXLEN = 100);

/// Customer state or province
Property State As %String(MAXLEN = 100);

/// Customer postal code
Property PostalCode As %String(MAXLEN = 20, POPSPEC = "USZip()");

/// Customer country
Property Country As %String(MAXLEN = 100, POPSPEC = "##class(data.customer).Country()");

/// Customer creation date
Property CreatedAt As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG, 3)} ];

Property InternalCreatedAt As datatype.HorologTS;

/// Whether the customer is active
Property IsActive As %Boolean [ InitialExpression = 1 ];

Index EmailIndex On Email [ Unique ];

Index LastNameIndex On LastName;

Index CityIndex On City;

/// Description
ClassMethod Email(ByRef nb As %Integer) As %Status
{
    set nb = 0,sc = $$$OK
   &sql(UPDATE data.customer SET Email = LOWER(firstname) || '.' || LOWER(lastname) || '@' || LOWER(City) || '.com')
   if SQLCODE = 0 {
       set nb = %ROWCOUNT

   } elseif SQLCODE = 100 {
        set errorMessage = "NO DATA UPDATED"
        set sc = $system.Status.Error(5001, errorMessage)
   }
   else {
        set errorMessage = %msg
        set sc = $system.Status.Error(5001, errorMessage)
   }
   return sc
}

/// Description
ClassMethod pop(nb As %Integer = 10, delete As %Boolean = 0) As %Integer
{
    if delete {
        do ..%KillExtent()
    }
    Set nb = ..Populate(nb)
    set sc = ..Email(.nbUpdated)
     if $$$ISERR(sc) {
        set errorMessage = $system.Status.GetErrorText(sc)
        write "Error updating emails: ", errorMessage, !
    } else {
        write "Emails updated successfully for ", nbUpdated, " customers.", !
    }
    Return nb
}

ClassMethod Country() As %String
{
 s t1=$lb("USA","Canada","UK","France","Germany","Italy","Spain","Portugal","Netherlands","Belgium","Switzerland","Austria","Sweden","Norway","Denmark","Finland","Poland","Czech Republic","Hungary","Romania","Bulgaria","Greece","Turkey","Russia","China","Japan","South Korea","India","Brazil","Argentina","Mexico","Australia","New Zealand","South Africa","Egypt","Morocco","Nigeria","Kenya","Saudi Arabia","UAE","Israel","Singapore","Malaysia","Indonesia","Thailand","Vietnam","Philippines")
 return $li(t1,$$$PRand($ll(t1))+1)
}

Storage Default
{
<Data name="customerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FirstName</Value>
</Value>
<Value name="3">
<Value>LastName</Value>
</Value>
<Value name="4">
<Value>Email</Value>
</Value>
<Value name="5">
<Value>Phone</Value>
</Value>
<Value name="6">
<Value>DateOfBirth</Value>
</Value>
<Value name="7">
<Value>Street</Value>
</Value>
<Value name="8">
<Value>City</Value>
</Value>
<Value name="9">
<Value>State</Value>
</Value>
<Value name="10">
<Value>PostalCode</Value>
</Value>
<Value name="11">
<Value>Country</Value>
</Value>
<Value name="12">
<Value>CreatedAt</Value>
</Value>
<Value name="13">
<Value>InternalCreatedAt</Value>
</Value>
<Value name="14">
<Value>IsActive</Value>
</Value>
<Value name="15">
<Value>%READERLIST</Value>
</Value>
</Data>
<DataLocation>^data.customerD</DataLocation>
<DefaultData>customerDefaultData</DefaultData>
<IdLocation>^data.customerD</IdLocation>
<IndexLocation>^data.customerI</IndexLocation>
<StreamLocation>^data.customerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
