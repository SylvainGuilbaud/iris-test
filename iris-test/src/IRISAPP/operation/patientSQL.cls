Class IRISAPP.operation.patientSQL Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// Insert into NewCustomer table
Method maj(pRequest As msg.patient, Output pResponse As msg.response.sql) As %Status
{
	set sc = $$$OK
	Try {

		set pResponse = ##class(msg.response.sql).%New()

		set query = "SELECT 1 FROM data.patient " _
					"WHERE PatientId = ? "
		$$$TRACE(query_" "_ pRequest.PatientId)
				
		$$$ThrowOnError(..Adapter.ExecuteQuery(.select,query,pRequest.PatientId))
		
		do select.Next() 
		set exist = select.GetData(1)
        $$$TRACE("Patient "_ pRequest.PatientId_" exists: "_ exist)
		if exist {
            $$$TRACE("Updating patient "_ pRequest.PatientId)
			set update = ""
			set update = update _ "update data.patient "
			set update = update _ "set"
			set update = update _ " LastName = ?"
			set update = update _ ", FirstName = ?"
			set update = update _ ", DateOfBirth = ?"
			set update = update _ ", Gender = ?"
			set update = update _ ", LastUpdateDate = sysdate"
			set update = update _ " where PatientId = ?"
			set sc = ..Adapter.ExecuteUpdate(.nrows
											,update
											, pRequest.LastName
											, pRequest.FirstName
											, $zd(pRequest.DateOfBirth,3)
											, pRequest.Gender
											, pRequest.PatientId
											)
			set pResponse.status = sc
			if sc {
				set pResponse.updated = pResponse.updated + 1
				$$$LOGINFO(nrows _ " row successfully updated")
			} else {
				#; set error=##class(common.msg.errors).%New()
				#; set error.status=sc
				#; do  pResponse.errors.SetAt(error,pResponse.errors.Count()+1)
				$$$LOGERROR("ERROR WHILE UPDATING : "_ pResponse.status.text)
			}

		} else {
            $$$TRACE("Inserting patient "_ pRequest.PatientId)
			set insert = ""
			set insert = insert _ "insert into data.patient "
			set insert = insert _ "("
			set insert = insert _ "  PatientId"
			set insert = insert _ ", LastName"
			set insert = insert _ ", FirstName"
			set insert = insert _ ", DateOfBirth"
			set insert = insert _ ", Gender"
			set insert = insert _ ")"
			set insert = insert _ " values "
			set insert = insert _ "("
			set insert = insert _ "?,?,?,?,?"
			set insert = insert _ ")"
			$$$TRACE("Insert request "_ insert)
			set sc = ..Adapter.ExecuteUpdate(.nrows
											,insert
											, pRequest.PatientId
											, pRequest.LastName
											, pRequest.FirstName
											, $zd(pRequest.DateOfBirth,3)
											, pRequest.Gender
											)
			set pResponse.status = sc
			if sc {
				set pResponse.inserted = pResponse.inserted + 1
				$$$LOGINFO(nrows _ " row successfully inserted")
			} else {
				#; set error=##class(common.msg.errors).%New()
				#; set error.status=sc
				#; do  pResponse.errors.SetAt(error,pResponse.errors.Count()+1)
				$$$LOGERROR("ERROR WHILE INSERTING : "_ pResponse.status.text)
			}
		}
	
	}
	Catch ex {
		Set sc=ex.AsStatus()
	}
    
	return sc
}

Method batch(pRequest As msg.list.patient, Output pResponse As msg.response.sql) As %Status
{
	set sc = $$$OK
	Try {

		set pResponse = ##class(msg.response.sql).%New()

		for i = 1 : 1 : pRequest.patients.Count() {
			set msg = pRequest.patients.GetAt(i)
			do ..maj(msg)
		}
		
	}
	Catch ex {
		Set sc=ex.AsStatus()
	}
    
	return sc
}

Method count(pRequest As Ens.StringContainer, Output pResponse As Ens.StringContainer) As %Status
{
	set sc = $$$OK
	Try {

		set pResponse = ##class(Ens.StringContainer).%New()
		if pRequest.StringValue '= "" {
			set query = "SELECT concat(count(*), ' rows') FROM " _ pRequest.StringValue
			$$$ThrowOnError(..Adapter.ExecuteQuery(.select,query))
		} else {
			set query = "SELECT  concat(sysdate(),' (version ',version(),')') "
			$$$ThrowOnError(..Adapter.ExecuteQuery(.select,query))
		}
		
		$$$TRACE(query)
				
		$$$ThrowOnError(..Adapter.ExecuteQuery(.select,query))
		
		do select.Next() 
		set result = select.GetData(1)
		set pResponse.StringValue =  result _ $char(13,10)
		set pResponse.StringValue = pResponse.StringValue _" (query:" _ query _ ")"
	
	}
	Catch ex {
		Set sc=ex.AsStatus()
	}
    
	return sc
}

XData MessageMap
{
<MapItems>
   <MapItem MessageType="Ens.StringContainer">
    <Method>count</Method>
  </MapItem>
  <MapItem MessageType="msg.patient">
    <Method>maj</Method>
  </MapItem>
  <MapItem MessageType="msg.list.patient">
    <Method>batch</Method>
  </MapItem>
</MapItems>
}

}
