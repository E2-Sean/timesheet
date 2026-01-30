

<cfquery name="check_login" datasource="#request.ds#">
select * from employee
where employee_name = <cfqueryparam value="#form.username#" cfsqltype="cf_sql_varchar" maxlength="10">
and magic = <cfqueryparam value="#form.password#" cfsqltype="cf_sql_varchar" maxlength="10">
</cfquery>

<cfif check_login.recordcount eq 1>
    <cfset session.user = form.username>
    <cfset session.userid = check_login.id_employee>
    <cflocation url="home.cfm">
<cfelse>
    <cfif not IsDefined("session.errorcount")>
        <cfset session.errorcount = 1>
    <cfelse>
        <cfset session.errorcount = session.errorcount + 1>
        <!--- to do kill repeated login attempts --->
    </cfif>
    <cflocation url="index.cfm">
</cfif>
