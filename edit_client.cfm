
<cfif IsDefined("form.id_client")>
    <!--- Update --->
    <cfquery name="update_client" datasource="#request.ds#">
    update client
    set client_name = <cfqueryparam value="#form.client_name#" cfsqltype="cf_sql_varchar" maxlength="30">,
    active = <cfqueryparam value="#form.active#" cfsqltype="cf_sql_char" maxlength="1">
    where id_client = <cfqueryparam value="#form.id_client#" cfsqltype="cf_sql_integer">
    </cfquery>
<cfelseif IsDefined("url.id_client")>
    <!--- Edit Screen--->
    <cfquery name="list_client" datasource="#request.ds#">
    select * from client
    where id_client = <cfqueryparam value="#url.id_client#" cfsqltype="cf_sql_integer">
    </cfquery>
<cfelse>
    Error. No client id.
    <cfabort>
</cfif>



<cfquery name="list_clients" datasource="#request.ds#">
select * from client
</cfquery>

<cfinclude template="header.cfm">

<div class="p-5">

<cfif IsDefined("url.id_client")>

<h1>Edit Clients</h1>

<p>Marking a client as inactive does not delete the client. However it means no more timesheets can be entered for the client or any projects associated with the client.

<form method="post" action="edit_client.cfm">

<cfoutput query="list_client">
<input type="hidden" name="id_client" value="<cfoutput>#id_client#</cfoutput>">
<label for="client_name">Client name</label>
<input type="text" id="client_name" name="client_name" value="#client_name#">
<br />
<br />
<label for="active">Active?</label>
<select id="active" name="active">
    <option value="T" <cfif active eq "T">selected</cfif>>Active</option>
    <option value="F" <cfif active eq "F">selected</cfif>>Inactive</option>
</select>
</cfoutput>

<br />
<br />
<input type="submit" value="Update Client">
</form>

</cfif>

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

<br />
<br />

<cfinclude template="footer.cfm">