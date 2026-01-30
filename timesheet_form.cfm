
<!--- referer --->
<cfif cgi.http_referer contains "timesheet_daily.cfm">
    <cfset referer = "timesheet_daily.cfm">
<cfelse>
    <cfset referer = "recent_timesheets.cfm">
</cfif>

<!--- queries --->
<cfquery name="list_employees" datasource="#request.ds#">
select * from employee
</cfquery>

<cfquery name="list_projects" datasource="#request.ds#">
select a.*, b.client_name 
from project a, client b
where a.id_client = b.id_client
</cfquery>

<!--- defaults --->
<cfparam name="today" default="#DateFormat(now(), 'yyyy-mm-dd')#">
<cfparam name="id_emp" default="0">
<cfparam name="id_proj" default="0">
<cfparam name="work_date" default="#today#">
<cfparam name="start_tm" default="">
<cfparam name="end_tm" default="">
<cfparam name="id_ts" default="0">
<cfparam name="notes" default="">

<!--- edit --->
<cfif IsDefined("url.id")>
    <cfquery name="get_timesheet" datasource="#request.ds#">
    select * from timesheet
    where id_timesheet = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif get_timesheet.recordcount eq 1>
        <cfset id_emp = get_timesheet.id_employee>
        <cfset id_proj = get_timesheet.id_project>
        <cfset work_date = DateFormat(get_timesheet.shift_date, "yyyy-mm-dd")>
        <cfset start_tm = TimeFormat(get_timesheet.start_time, "HH:nn")>
        <cfset end_tm = TimeFormat(get_timesheet.end_time, "HH:nn")>
        <cfset id_ts = #url.id#>
        <cfset notes = get_timesheet.notes>
    </cfif>
</cfif>

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Timesheet Form</h1>

<form method="post" action="submit_timesheet.cfm">
    <div class="row g-3"> 
        <div class="col-6">
        <label for="id_employee">Employee</label>
        <select name="id_employee" class="form-select" id="emp_select">
            <cfoutput query="list_employees">
            <option value="#id_employee#" <cfif id_employee eq id_emp>selected<cfelseif id_employee eq session.userid>selected</cfif>>#employee_name#</option>
            </cfoutput>
        </select>
        </div>
        <div class="col-6">
        <label for="id_project">Project</label>
        <select name="id_project" class="form-select">
            <cfoutput query="list_projects">
            <option value="#id_project#"<cfif id_project eq id_proj>selected</cfif>>#client_name# #project# #subproject#</option>
            </cfoutput>
        </select>
        </div>
    </div>
    <div class="row g-3">
        <div class="col-4">
            <label for="work_date">Date</label>
            <input type="date" name="work_date" class="form-control" value="<cfoutput>#work_date#</cfoutput>">
        </div>
        
        <div class="col-4">
            <label for="start_time">Start Time</label>
            <input type="time" name="start_time" class="form-control" value="<cfoutput>#start_tm#</cfoutput>">
        </div>

        <div class="col-4">
            <label for="end_time">End Time</label>
            <input type="time" name="end_time" class="form-control" value="<cfoutput>#end_tm#</cfoutput>">
        </div>
    </div>
    <div class="row g-3">
        <div class="col-12">
            <label for="notes">Notes</label>
            <input type="text" name="notes" class="form-control" value="<cfoutput>#notes#</cfoutput>">
        </div>
    </div>
    <br />
    <div class="row g-3">
        <div class="col-12">
        <input type="hidden" name="id_ts" value="<cfoutput>#id_ts#</cfoutput>">
        <input type="hidden" name="referer" value="<cfoutput>#referer#</cfoutput>">
        <input type="submit" class="btn btn-primary" name="submit_btn" value="Submit">
        </div>
    </div>
</form>
</div>
    
<cfinclude template="footer.cfm">