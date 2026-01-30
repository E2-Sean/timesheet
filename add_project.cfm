
<cfquery name="add_project" datasource="#request.ds#">
insert into project (id_client, project, subproject, active) values (
    <cfqueryparam value="#form.id_client#" cfsqltype="cf_sql_integer">,
    <cfqueryparam value="#form.project#" cfsqltype="cf_sql_varchar" maxlength="50">,
    <cfqueryparam value="#form.subproject#" cfsqltype="cf_sql_varchar" maxlength="50">,
    'T'
)
</cfquery>

<cflocation url="projects.cfm">