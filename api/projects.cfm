<!--- API: Projects --->
<!--- GET: List projects with client information --->
<!--- Parameters: ?active=T&id_client=N (optional filters) --->

<cfinclude template="auth.cfm">
<cfcontent type="application/json">

<cfset response = {"success": false}>

<cftry>
    <cfquery name="list_projects" datasource="#request.ds#">
    select p.id_project, p.id_client, p.project, p.subproject, p.active,
           c.client_name
    from project p
    inner join client c on p.id_client = c.id_client
    where 1=1
    <cfif IsDefined("url.active") and (url.active eq "T" or url.active eq "F")>
    and p.active = <cfqueryparam value="#url.active#" cfsqltype="cf_sql_char">
    </cfif>
    <cfif IsDefined("url.id_client") and isNumeric(url.id_client)>
    and p.id_client = <cfqueryparam value="#url.id_client#" cfsqltype="cf_sql_integer">
    </cfif>
    order by c.client_name, p.project
    </cfquery>

    <cfset data = []>
    <cfloop query="list_projects">
        <cfset arrayAppend(data, {
            "id_project": id_project,
            "id_client": id_client,
            "client_name": client_name,
            "project": project,
            "subproject": subproject,
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
