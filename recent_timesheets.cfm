
<cfquery name="recent_timesheets" datasource="#request.ds#">
select case when a.update_time > a.create_time then a.update_time else a.create_time end as last_change,
a.id_timesheet, a.id_employee, a.id_project, a.shift_date, a.start_time, a.end_time, a.notes,
b.employee_name, c.project, c.subproject, d.client_name
from timesheet a, employee b, project c, client d
where a.id_employee = b.id_employee
and a.id_project = c.id_project
and c.id_client = d.id_client
order by last_change desc
</cfquery>

<cfinclude template="header.cfm">

<div class ="p-5">

<h1>Recent Timesheets</h1>

<table class="table table-striped table-bordered">
    <tr class="header-row">
        <th>Employee</th>
        <th>Client</th>
        <th>Project</th>
        <th>Date</th>
        <th>Start</th>
        <th>End</th>
        <th>Hours</th>
        <th>Last Change</th>
        <th>Notes</th>
        <th>Edit</th>
        <th>Delete</th>
    </tr>
    <cfoutput query="recent_timesheets">
    <tr>
        <td>#employee_name#</td>
        <td>#client_name#</td>
        <td>#project# #subproject#</td>
        <td>#DateFormat(shift_date,"eee mmm d")#</td>
        <td>#TimeFormat(start_time, "hh:mm tt")#</td>
        <td>#TimeFormat(end_time, "hh:mm tt")#</td>
        <cfset hours = DateDiff('n', start_time, end_time) / 60>
        <td>#hours#</td>
        <td>#last_change#</td>
        <td>#notes#</td>
        <td><a href="timesheet_form.cfm?id=#id_timesheet#">Edit</a></td>
        <td><a href="delete_timesheet.cfm?id=#id_timesheet#">Delete</a></td>
    </tr>
    </cfoutput>
</table>

</div>

<cfinclude template="footer.cfm">