<!--- API: Employees --->
<!--- GET: List all employees --->

<cfinclude template="auth.cfm">
<cfcontent type="application/json">

<cfset response = {"success": false}>

<cftry>
    <cfquery name="list_employees" datasource="#request.ds#">
    select id_employee, employee_name
    from employee
    order by employee_name
    </cfquery>

    <cfset data = []>
    <cfloop query="list_employees">
        <cfset arrayAppend(data, {
            "id_employee": id_employee,
            "employee_name": employee_name
        })>
    </cfloop>

    <cfset response = {
        "success": true,
        "data": data
    }>

    <cfcatch type="any">
        <cfset response = {
            "success": false,
            "error": cfcatch.message,
            "errorCode": "SERVER_ERROR"
        }>
        <cfheader statuscode="500" statustext="Internal Server Error">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
