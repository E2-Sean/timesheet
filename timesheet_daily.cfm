<!--- queries --->
<cfquery name="list_employees" datasource="#request.ds#">
select * from employee
</cfquery>

<cfquery name="list_projects" datasource="#request.ds#">
select a.*, b.client_name
from project a, client b
where a.id_client = b.id_client
and a.active = 'T'
and b.active = 'T'
order by b.client_name, a.project
</cfquery>

<!--- check for submitted form to set date and employee --->
<cfif IsDefined("form.set_emp_date")>
    <cfset session.daily_emp_id = form.id_employee>
    <cfset session.daily_date = form.work_date>
    <cfquery name="get_employee" dbtype="query">
    select * from list_employees
    where id_employee = <cfqueryparam value="#session.daily_emp_id#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfset session.daily_emp_name = get_employee.employee_name>
<cfelseif IsDefined("form.insert_ts")>
    <!--- do overlap and contains testing --->
    <cfquery name="overlap" datasource="#request.ds#">
    select * from timesheet
    where id_employee = <cfqueryparam value="#session.daily_emp_id#" cfsqltype="cf_sql_integer">
    and shift_date = <cfqueryparam value="#session.daily_date#" cfsqltype="cf_sql_date">
    and start_time < <cfqueryparam value="#session.daily_date# #form.end_time#" cfsqltype="cf_sql_timestamp">
    and end_time > <cfqueryparam value="#session.daily_date# #form.start_time#" cfsqltype="cf_sql_timestamp">
    </cfquery>
    <cfquery name="contained" datasource="#request.ds#">
    select * from timesheet
    where id_employee = <cfqueryparam value="#session.daily_emp_id#" cfsqltype="cf_sql_integer">
    and shift_date = <cfqueryparam value="#session.daily_date#" cfsqltype="cf_sql_date">
    and start_time < <cfqueryparam value="#session.daily_date# #form.start_time#" cfsqltype="cf_sql_timestamp">
    and end_time > <cfqueryparam value="#session.daily_date# #form.end_time#" cfsqltype="cf_sql_timestamp">
    </cfquery>
    <cfquery name="contains" datasource="#request.ds#">
    select * from timesheet
    where id_employee = <cfqueryparam value="#session.daily_emp_id#" cfsqltype="cf_sql_integer">
    and shift_date = <cfqueryparam value="#session.daily_date#" cfsqltype="cf_sql_date">
    and start_time > <cfqueryparam value="#session.daily_date# #form.start_time#" cfsqltype="cf_sql_timestamp">
    and end_time < <cfqueryparam value="#session.daily_date# #form.end_time#" cfsqltype="cf_sql_timestamp">
    </cfquery>
    <cfif overlap.recordcount eq 0 and contained.recordcount eq 0 and contains.recordcount eq 0 and form.start_time neq "" and form.end_time neq "">
        <cfquery name="insert_timesheet" datasource="#request.ds#">
        insert into timesheet (id_employee, id_project, id_rate, shift_date, start_time, end_time, create_time, notes)
        values (
            <cfqueryparam value="#session.daily_emp_id#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#form.id_project#" cfsqltype="cf_sql_integer">,
            1,
            <cfqueryparam value="#session.daily_date#" cfsqltype="cf_sql_date">,
            <cfqueryparam value="#session.daily_date# #form.start_time#" cfsqltype="cf_sql_timestamp">,
            <cfqueryparam value="#session.daily_date# #form.end_time#" cfsqltype="cf_sql_timestamp">,
            getdate(),
            <cfqueryparam value="#form.notes#" cfsqltype="cf_sql_varchar" maxlength="255">
        )
        </cfquery>
    <cfelse>
        <cfset start_tm = form.start_time>
        <cfset end_tm = form.end_time>
        <cfset id_proj = form.id_project>
        <cfif form.start_time eq "" or form.end_time eq "">
            <cfset error_message = 'Error! Start time and/or end time cannot be blank.'>
        <cfelseif overlap.recordcount neq 0 or contained.recordcount neq 0 or contains.recordcount neq 0>
            <cfset error_message = 'Error! Time overlaps with another entry.'>
        </cfif>
        <cfset line_notes = form.notes>
    </cfif>
</cfif>

<cfif IsDefined("session.daily_date") and IsDefined("session.daily_emp_id")>
    <!--- display set days timesheets if any --->
    <cfquery name="show_timesheet" datasource="#request.ds#">
    select case when a.update_time > a.create_time then a.update_time else a.create_time end as last_change,
    a.id_timesheet, a.id_employee, a.id_project, a.shift_date, a.start_time, a.end_time, a.create_time, a.notes,
    b.employee_name, c.project, c.subproject, d.client_name
    from timesheet a, employee b, project c, client d
    where 1 = 1
    and a.id_employee = <cfqueryparam value="#session.daily_emp_id#" cfsqltype="cf_sql_integer">
    and a.start_time >= <cfqueryparam value="#session.daily_date# 00:00:00" cfsqltype="cf_sql_timestamp">
    and a.start_time <= <cfqueryparam value="#session.daily_date# 23:59:59" cfsqltype="cf_sql_timestamp">
    and a.id_employee = b.id_employee
    and a.id_project = c.id_project
    and c.id_client = d.id_client
    order by a.start_time
    </cfquery>

    <cfquery name="max" dbtype="query">
    select max(end_time) as start_tm from show_timesheet
    </cfquery>

    <cfif Not IsDefined("error_message")>
        <cfset start_tm = TimeFormat(max.start_tm, "HH:nn")>
    </cfif>

</cfif>

<!--- defaults --->
<cfparam name="today" default="#DateFormat(now(), 'yyyy-mm-dd')#">
<cfparam name="id_emp" default="0">
<cfparam name="id_proj" default="0">
<cfparam name="work_date" default="#today#">
<cfparam name="start_tm" default="">
<cfparam name="end_tm" default="">
<cfparam name="id_ts" default="0">
<cfparam name="line_notes" default="">

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Daily Timesheet</h1>

<cfif Not IsDefined("session.daily_emp_id") or Not IsDefined("session.daily_date")>

<form method="post" action="timesheet_daily.cfm">
    <div class="row g-3">
        <div class="col-2">
            <label for="id_employee">Employee</label>
            <select name="id_employee" class="form-select" id="emp_select">
                <cfoutput query="list_employees">
                <option value="#id_employee#" <cfif id_employee eq session.userid>selected</cfif>>#employee_name#</option>
                </cfoutput>
            </select>
        </div>
        <div class="col-2">
            <label for="work_date">Date</label>
            <input type="date" name="work_date" class="form-control" value="<cfoutput>#work_date#</cfoutput>">
        </div>
        <div class="col-2">
            <label for="submit">&nbsp;</label>
            <input type="hidden" name="id_ts" value="<cfoutput>#id_ts#</cfoutput>">
            <input type="submit" class="form-control btn btn-primary" name="set_emp_date" value="Set Employee &amp; Date">
        </div>
    </div>
</form>

<cfelse>

<div class="row g-3">
    <div class="col-9">
        <h2>Timesheet for <cfoutput>#session.daily_emp_name# on #DateFormat(session.daily_date,"eee d mmm yyyy")#</cfoutput></h2>
    </div>
    <div class="col-3">
        <form method="post" action="delete_timesheet_session.cfm">
            <input type="submit" class="form-control btn btn-primary" name="insert_ts" value="Change Employee and/or Date">
        </form>
    </div>
</div>


<cfif IsDefined("error_message")>
    <div class="alert alert-danger alert-dismissible fade show">
        <cfoutput>#error_message#</cfoutput>
    </div>
</cfif>



<form method="post" action="timesheet_daily.cfm">
    <div class="row g-3">
        <div class="col-3">
        <label for="id_project">Project</label>
        <select name="id_project" class="form-select">
            <cfoutput query="list_projects">
            <option value="#id_project#"<cfif id_project eq id_proj>selected</cfif>>#client_name# #project# #subproject#</option>
            </cfoutput>
        </select>
        </div>

        <div class="col-2">
            <label for="start_time">Start Time</label>
            <input type="time" name="start_time" class="form-control" value="<cfoutput>#start_tm#</cfoutput>">
        </div>

        <div class="col-2">
            <label for="end_time">End Time</label>
            <input type="time" name="end_time" class="form-control" value="<cfoutput>#end_tm#</cfoutput>">
        </div>

        <div class="col-4">
            <label for="notes">Notes</label>
            <input type="text" name="notes" class="form-control" value="<cfoutput>#line_notes#</cfoutput>">
        </div>

        <div class="col-1">
            <label for="submit">&nbsp;</label>
            <input type="hidden" name="id_ts" value="<cfoutput>#id_ts#</cfoutput>">
            <input type="submit" class="form-control btn btn-primary" name="insert_ts" value="Add">
        </div>
    </div>
</form>

</div>

<cfif IsDefined("session.daily_date") and IsDefined("session.daily_emp_id")>


<div class ="p-5">
    <table class="table table-striped table-bordered">
        <tr class="header-row">
            <th>Client</th>
            <th>Project</th>
            <th>Date</th>
            <th>Start</th>
            <th>End</th>
            <th>Hours</th>
            <th>Notes</th>
            <th>Edit</th>
            <th>Delete</th>
        </tr>
        <cfoutput query="show_timesheet">
        <tr>
            <td>#client_name#</td>
            <td>#project# #subproject#</td>
            <td>#DateFormat(shift_date,"eee d mmm")#</td>
            <td>#TimeFormat(start_time, "hh:mm tt")#</td>
            <td>#TimeFormat(end_time, "hh:mm tt")#</td>
            <cfset hours = DateDiff('n', start_time, end_time) / 60>
            <td>#hours#</td>
            <td>#notes#</td>
            <td><a href="timesheet_form.cfm?id=#id_timesheet#">Edit</a></td>
            <td><a href="delete_timesheet.cfm?id=#id_timesheet#">Delete</a></td>
        </tr>
        </cfoutput>
        <cfif show_timesheet.recordcount eq 0>
        <tr>
            <td colspan="9">No Timesheets for <cfoutput>#session.daily_emp_name# on #session.daily_date#</cfoutput>.</td>
        </tr>
        </cfif>
    </table>
</div>

</cfif>

</cfif>

<cfinclude template="footer.cfm">