
<cfif IsDefined("form.id_project")>
    <!--- Update --->
    <cfquery name="update_project" datasource="#request.ds#">
    update project
    set id_client = <cfqueryparam value="#form.id_client#" cfsqltype="cf_sql_integer">,
    project = <cfqueryparam value="#form.project#" cfsqltype="cf_sql_varchar" maxlength="50">,
    subproject = <cfqueryparam value="#form.subproject#" cfsqltype="cf_sql_varchar" maxlength="50">,
    active = <cfqueryparam value="#form.active#" cfsqltype="cf_sql_char" maxlength="1">
    where id_project = <cfqueryparam value="#form.id_project#" cfsqltype="cf_sql_integer">
    </cfquery>
<cfelseif IsDefined("url.id_project")>
    <!--- Edit Screen --->
    <cfquery name="get_project" datasource="#request.ds#">
    select * from project
    where id_project = <cfqueryparam value="#url.id_project#" cfsqltype="cf_sql_integer">
    </cfquery>
<cfelse>
    Error. No project id.
    <cfabort>
</cfif>

<cfquery name="list_clients" datasource="#request.ds#">
select * from client
where active = 'T'
order by client_name
</cfquery>

<cfquery name="list_projects" datasource="#request.ds#">
select a.*, b.client_name
from project a, client b
where a.id_client = b.id_client
order by b.client_name, a.project
</cfquery>

<cfinclude template="header.cfm">

<div class="p-5">

<cfif IsDefined("url.id_project")>

<h1>Edit Project</h1>

<p>Marking a project as inactive does not delete the project. However it means no more timesheets can be entered for the project.</p>

<form method="post" action="edit_project.cfm">

<cfoutput query="get_project">
<input type="hidden" name="id_project" value="#id_project#">

<div class="row g-3 mb-3">
    <div class="col-4">
        <label for="id_client" class="form-label">Client</label>
        <select name="id_client" class="form-select">
            <cfloop query="list_clients">
            <option value="#list_clients.id_client#" <cfif list_clients.id_client eq get_project.id_client>selected</cfif>>#list_clients.client_name#</option>
            </cfloop>
        </select>
    </div>
</div>

<div class="row g-3 mb-3">
    <div class="col-4">
        <label for="project" class="form-label">Project</label>
        <input type="text" id="project" name="project" class="form-control" value="#project#">
    </div>
</div>

<div class="row g-3 mb-3">
    <div class="col-4">
        <label for="subproject" class="form-label">Subproject</label>
        <input type="text" id="subproject" name="subproject" class="form-control" value="#subproject#">
    </div>
</div>

<div class="row g-3 mb-3">
    <div class="col-4">
        <label for="active" class="form-label">Active?</label>
        <select id="active" name="active" class="form-select">
            <option value="T" <cfif active eq "T">selected</cfif>>Active</option>
            <option value="F" <cfif active eq "F">selected</cfif>>Inactive</option>
        </select>
    </div>
</div>

</cfoutput>

<input type="submit" class="btn btn-primary" value="Update Project">
</form>

</cfif>

<br />
<br />

<h2>All Projects</h2>

<table class="table">
    <thead>
        <tr>
            <th>Client name</th>
            <th>Project</th>
            <th>Subproject</th>
            <th>Active?</th>
            <th>Edit</th>
        </tr>
    </thead>
<cfoutput query="list_projects">
    <tr>
        <td>#client_name#</td>
        <td>#project#</td>
        <td>#subproject#</td>
        <td><cfif active eq "T">Active<cfelseif active eq "F">Inactive</cfif></td>
        <td><a href="edit_project.cfm?id_project=#id_project#">Edit</a></td>
    </tr>
</cfoutput>
</table>

</div>

<cfinclude template="footer.cfm">
