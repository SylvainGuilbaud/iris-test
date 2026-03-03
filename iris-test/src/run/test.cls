Class run.test
{

/// Description
ClassMethod datatype() As %Status
{
    Set sc = $$$OK

    do $system.OBJ.Compile("datatype.HorologTS","ck")
    do $system.OBJ.Compile("data.customer","ck")    

    do ##class(data.customer).%KillExtent()
    zw ^data.customerD
    zw ^data.customerI
    zw ^data.customerS

    set customer = ##class(data.customer).%New()
    set customer.FirstName = "Alice"
    set customer.LastName = "Smith"
    set customer.Email = "alice.smith@example.com"
    set customer.CreatedAt = $zdt($horolog,3)
    set customer.InternalCreatedAt = $zdt($horolog,3)
    do customer.%Save()
    zw ^data.customerD

    set customer = ##class(data.customer).%OpenId(1)
    write "Customer: ", customer.FirstName, " ", customer.LastName,!
    write "CreatedAt: ", customer.CreatedAt,!
    write "InternalCreatedAt: ", customer.InternalCreatedAt,!

    write !
    &SQL(INSERT INTO data.customer (FirstName, LastName, Email, CreatedAt, InternalCreatedAt) VALUES ('John', 'Doe', 'john.doe@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP))
    zw ^data.customerD
    set customer = ##class(data.customer).%OpenId(2)
    write "Customer: ", customer.FirstName, " ", customer.LastName,!
    write "CreatedAt: ", customer.CreatedAt,!
    write "InternalCreatedAt: ", customer.InternalCreatedAt,!

    &SQL(SELECT CreatedAt, InternalCreatedAt INTO :createdAt, :internalCreatedAt FROM data.customer WHERE ID = 1)
    write "Customer 1 - CreatedAt: ", createdAt,!
    write "Customer 1 - InternalCreatedAt: ", internalCreatedAt,!

    

    Return sc
}

}
