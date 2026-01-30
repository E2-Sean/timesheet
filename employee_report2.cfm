
<!--- <cfdump var="#form#"> --->

<cfquery name="export" datasource="#request.ds#">
select a.id_timesheet, a.id_employee, a.id_project, a.shift_date, a.start_time, a.end_time, a.create_time,
a.notes, b.employee_name, c.project, c.subproject, d.client_name
from timesheet a, employee b, project c, client d
where 1 = 1
and a.id_employee = #form.id_employee#
<cfif form.id_client neq 0>and c.id_client = #form.id_client#</cfif>
and a.start_time >= '#form.start_date# 00:00:00'
and a.start_time <= '#form.end_date# 23:59:59'
and a.id_employee = b.id_employee
and a.id_project = c.id_project
and c.id_client = d.id_client
order by a.start_time
</cfquery>

<cfinclude template="header.cfm">

<!--- <cfoutput> 
select a.id_timesheet, a.id_employee, a.id_project, a.shift_date, a.start_time, a.end_time, a.create_time,
b.employee_name, c.project, c.subproject, d.client_name
from timesheet a, employee b, project c, client d
where a.id_employee = #form.id_employee#
and c.id_client = #form.id_client#
and a.start_time >= '#form.start_date# 00:00:00'
and a.start_time <= '#form.end_date# 23:59:59'
and a.id_employee = b.id_employee
and a.id_project = c.id_project
and c.id_client = d.id_client
order by a.start_time
</cfoutput> --->

<div class="p-5">

<h1>Timesheet Export</h1>

<cfset total = 0>

<table class="table table-striped table-bordered">
    <tr class="header-row">
        <th>Employee</th>
        <th>Client</th>
        <th>Date</th>
        <th>Start</th>
        <th>End</th>
        <th>Project</th>
        <th>Subproject</th>
        <th>Notes</th>
        <th>Hours</th>
        <th></th>
        <th></th>
    </tr>
<cfoutput query="export">
    <tr>
        <td>#employee_name#</td>
        <td>#client_name#</td>
        <td>#DateFormat(shift_date, 'yyyy-mm-dd')#</td>
        <td>#TimeFormat(start_time,'hh:mm tt')#</td>
        <td>#TimeFormat(end_time,'hh:mm tt')#</td>
        <td>#project#</td>
        <td>#subproject#</td>
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

</div>

<cfinclude template="footer.cfm">