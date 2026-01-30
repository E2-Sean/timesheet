<!--- API: Clients --->
<!--- GET: List clients (optionally filtered by active status) --->
<!--- Parameters: ?active=T (optional) --->

<cfinclude template="auth.cfm">
<cfcontent type="application/json">

<cfset response = {"success": false}>

<cftry>
    <cfquery name="list_clients" datasource="#request.ds#">
    select id_client, client_name, active
    from client
    <cfif IsDefined("url.active") and (url.active eq "T" or url.active eq "F")>
    where active = <cfqueryparam value="#url.active#" cfsqltype="cf_sql_char">
    </cfif>
    order by client_name
    </cfquery>

    <cfset data = []>
    <cfloop query="list_clients">
        <cfset arrayAppend(data, {
            "id_client": id_client,
            "client_name": client_name,
            "active": active
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
