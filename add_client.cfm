
<cfquery name="add_client" datasource="#request.ds#">
insert into client (client_name, active) values (
    <cfqueryparam value="#form.client_name#" cfsqltype="cf_sql_varchar" maxlength="30">,
    'T'
)
</cfquery>

<cflocation url="clients.cfm">