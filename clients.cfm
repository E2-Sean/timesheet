
<cfquery name="list_clients" datasource="#request.ds#">
select * from client
</cfquery>

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Clients</h1>

<form method="post" action="add_client.cfm">
<input type="text" name="client_name">
<input type="submit" value="Add Client">
</form>
<br />
<br />

<table class="table">
    <thead>
        <tr>
            <th>Client name</th>
            <th>Active?</th>
            <th>Edit</th>
        </tr>
    </thead>
<cfoutput query="list_clients">
    <tr>
        <td>#client_name#</td>
        <td><cfif active eq "T">Active<cfelseif active eq "F">Inactive</cfif></td>
        <td><a href="edit_client.cfm?id_client=#id_client#">Edit</a></td></tr>
    </tr>
</cfoutput>
</table>

</div>

<cfinclude template="footer.cfm">