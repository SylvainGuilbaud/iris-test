Class Tutorial.Test Extends %RegisteredObject
{

/// Description
ClassMethod run() As %Status
{
    Set sc = $$$OK
    Set ^UnitTestRoot="/src/Tutorial"
    Do ##class(Tutorial.ProductionTest).Run()
    Return sc
}

ClassMethod debug() As %Status
{
    Set sc = $$$OK
    Set ^UnitTestRoot="/src/Tutorial"
    Do ##class(Tutorial.ProductionTest).Debug()
    Return sc
}

}
