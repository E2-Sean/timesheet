<cfquery name="export" datasource="#request.ds#">
select a.id_timesheet, a.id_employee, a.id_project, a.shift_date, 
a.start_time, a.end_time, a.create_time, a.notes,
b.employee_name, c.project, c.subproject, d.client_name
from timesheet a, employee b, project c, client d
where 1 = 1
<cfif form.id_employee neq 0>and a.id_employee = <cfqueryparam value="#form.id_employee#" cfsqltype="cf_sql_integer"></cfif>
and c.id_client = <cfqueryparam value="#form.id_client#" cfsqltype="cf_sql_integer">
and a.start_time >= <cfqueryparam value="#form.start_date# 00:00:00" cfsqltype="cf_sql_timestamp">
and a.start_time <= <cfqueryparam value="#form.end_date# 23:59:59" cfsqltype="cf_sql_timestamp">
and a.id_employee = b.id_employee
and a.id_project = c.id_project
and c.id_client = d.id_client
order by a.start_time
</cfquery>

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Timesheet Report</h1>

<cfset total = 0>

<table class="table table-striped table-bordered">
    <tr class="header-row">
        <th>Employee</th>
        <th>Date</th>
        <th>Start</th>
        <th>End</th>
        <th>Client</th>
        <th>Project</th>
        <th>Notes</th>
        <th>Hours</th>
        <th></th>
        <th></th>
    </tr>
<cfoutput query="export">
    <tr>
        <td>#employee_name#</td>
        <td>#DateFormat(shift_date, 'yyyy-mm-dd')#</td>
        <td>#TimeFormat(start_time,'hh:nn tt')#</td>
        <td>#TimeFormat(end_time,'hh:nn tt')#</td>
        <td>#client_name#</td>
        <td>#project# #subproject#</td>
        <td>#notes#</td>
        <cfset minutes = DateDiff('n', start_time, end_time)>
        <cfset hours = minutes / 60>
        <td>#hours#</td> 
        <cfset total = total + DateDiff('n', start_time, end_time)>
        <td><a href="timesheet_form.cfm?id=#id_timesheet#">Edit</a></td>
        <td><a href="delete_timesheet.cfm?id=#id_timesheet#">Delete</a></td>
    </tr>
</cfoutput>
    <cfset total_hours = total / 60>
    <tr>
        <td>Total Hours</td>
        <td colspan="6"></td>
        <td><cfoutput>#total_hours#</cfoutput></td>
        <td colspan="2"></td>
    </tr>
</table>

<form method="post" action="create_pdf_timesheet.cfm">
    <input type="hidden" name="start_date" value="<cfoutput>#form.start_date#</cfoutput>">
    <input type="hidden" name="end_date" value="<cfoutput>#form.end_date#</cfoutput>">
    <input type="hidden" name="id_employee" value="<cfoutput>#form.id_employee#</cfoutput>">
    <input type="hidden" name="id_client" value="<cfoutput>#form.id_client#</cfoutput>">
    <input type="submit" name="submit" class="btn btn-primary" value="Create PDF Timesheet">
</form>

</div>


<cfinclude template="footer.cfm">