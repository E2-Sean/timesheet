
<!--- queries --->
<cfquery name="list_clients" datasource="#request.ds#">
select * from client
where active = 'T'
</cfquery>

<cfquery name="list_projects" datasource="#request.ds#">
select a.*, b.client_name
from project a, client b
where a.id_client = b.id_client
</cfquery>

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Projects</h1>

<form method="post" action="add_project.cfm">
    <div class="row p-2">
        <div class="col-3">
            <label for="id_client">Client</label>
            <select name="id_client" class="form-select">
                <cfoutput query="list_clients">
                <option value="#id_client#">#client_name#</option>
                </cfoutput>
            </select>
        </div>
    </div>
    <div class="row p-2">
        <div class="col-3">
            <label for="project">Project</label>
            <input type="text" class="form-control" name="project">
        </div>
    </div>
    <div class="row p-2">
        <div class="col-3">
            <label for="subproject">Subproject</label>
            <input type="text" class="form-control" name="subproject">
        </div>
    </div>
    <div class="row p-2">
        <div class="col-1">
            <input type="submit" type="submit" class="btn btn-primary" value="Add Project">
        </div>
    </div>
</form>
<br />
<br />

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