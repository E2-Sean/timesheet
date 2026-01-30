<!--- API: Reports --->
<!--- GET: Timesheet summaries --->
<!--- Parameters: --->
<!---   id_client (required) --->
<!---   start_date (required) --->
<!---   end_date (required) --->
<!---   id_employee (optional, 0 or omit for all) --->

<cfinclude template="auth.cfm">
<cfcontent type="application/json">

<cfset response = {"success": false}>

<cftry>
    <!--- Validate required parameters --->
    <cfif not IsDefined("url.id_client") or not IsDefined("url.start_date") or not IsDefined("url.end_date")>
        <cfset response = {
            "success": false,
            "error": "Missing required parameters: id_client, start_date, end_date",
            "errorCode": "VALIDATION_ERROR"
        }>
        <cfheader statuscode="400" statustext="Bad Request">
    <cfelse>
        <cfquery name="report" datasource="#request.ds#">
        select t.id_timesheet, t.id_employee, t.id_project, t.shift_date,
               t.start_time, t.end_time, t.notes,
               e.employee_name, p.project, p.subproject, c.client_name
        from timesheet t
        inner join employee e on t.id_employee = e.id_employee
        inner join project p on t.id_project = p.id_project
        inner join client c on p.id_client = c.id_client
        where c.id_client = <cfqueryparam value="#url.id_client#" cfsqltype="cf_sql_integer">
        and t.start_time >= <cfqueryparam value="#url.start_date# 00:00:00" cfsqltype="cf_sql_timestamp">
        and t.start_time <= <cfqueryparam value="#url.end_date# 23:59:59" cfsqltype="cf_sql_timestamp">
        <cfif IsDefined("url.id_employee") and url.id_employee neq 0 and isNumeric(url.id_employee)>
        and t.id_employee = <cfqueryparam value="#url.id_employee#" cfsqltype="cf_sql_integer">
        </cfif>
        order by t.shift_date, t.start_time
        </cfquery>

        <cfset data = []>
        <cfset totalMinutes = 0>
        <cfloop query="report">
            <cfset minutes = DateDiff('n', start_time, end_time)>
            <cfset totalMinutes = totalMinutes + minutes>
            <cfset arrayAppend(data, {
                "id_timesheet": id_timesheet,
                "id_employee": id_employee,
                "employee_name": employee_name,
                "id_project": id_project,
                "project": project,
                "subproject": subproject,
                "client_name": client_name,
                "shift_date": DateFormat(shift_date, "yyyy-mm-dd"),
                "start_time": TimeFormat(start_time, "HH:mm"),
                "end_time": TimeFormat(end_time, "HH:mm"),
                "notes": notes,
                "hours": minutes / 60
            })>
        </cfloop>

        <cfset response = {
            "success": true,
            "summary": {
                "total_hours": totalMinutes / 60,
                "entry_count": report.recordcount
            },
            "data": data
        }>
    </cfif>

    <cfcatch type="any">
        <cfset response = {
            "success": false,
            "error": cfcatch.message,
            "errorCode": "SERVER_ERROR"
        }>
        <cfheader statuscode="500" statustext="Internal Server Error">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
