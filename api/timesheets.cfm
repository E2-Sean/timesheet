<!--- API: Timesheets --->
<!--- GET: Read timesheet entries --->
<!---   ?id_timesheet=N - Single entry --->
<!---   ?id_employee=N&date=YYYY-MM-DD - Daily view --->
<!---   ?id_employee=N&start_date=X&end_date=Y - Range view --->
<!--- POST: Create/Update/Delete --->
<!---   {"action": "create", "id_employee": N, "id_project": N, "shift_date": "YYYY-MM-DD", "start_time": "HH:MM", "end_time": "HH:MM", "notes": ""} --->
<!---   {"action": "update", "id_timesheet": N, ...} --->
<!---   {"action": "delete", "id_timesheet": N} --->

<cfinclude template="auth.cfm">
<cfcontent type="application/json">

<cfset response = {"success": false}>

<cftry>
    <cfif cgi.request_method eq "GET">
        <!--- READ operations --->
        <cfif IsDefined("url.id_timesheet") and isNumeric(url.id_timesheet)>
            <!--- Single entry --->
            <cfquery name="get_timesheet" datasource="#request.ds#">
            select t.id_timesheet, t.id_employee, t.id_project, t.shift_date,
                   t.start_time, t.end_time, t.notes, t.create_time, t.update_time,
                   e.employee_name, p.project, p.subproject, c.client_name
            from timesheet t
            inner join employee e on t.id_employee = e.id_employee
            inner join project p on t.id_project = p.id_project
            inner join client c on p.id_client = c.id_client
            where t.id_timesheet = <cfqueryparam value="#url.id_timesheet#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif get_timesheet.recordcount eq 1>
                <cfset response = {
                    "success": true,
                    "data": {
                        "id_timesheet": get_timesheet.id_timesheet,
                        "id_employee": get_timesheet.id_employee,
                        "employee_name": get_timesheet.employee_name,
                        "id_project": get_timesheet.id_project,
                        "project": get_timesheet.project,
                        "subproject": get_timesheet.subproject,
                        "client_name": get_timesheet.client_name,
                        "shift_date": DateFormat(get_timesheet.shift_date, "yyyy-mm-dd"),
                        "start_time": TimeFormat(get_timesheet.start_time, "HH:mm"),
                        "end_time": TimeFormat(get_timesheet.end_time, "HH:mm"),
                        "notes": get_timesheet.notes,
                        "hours": DateDiff('n', get_timesheet.start_time, get_timesheet.end_time) / 60
                    }
                }>
            <cfelse>
                <cfset response = {
                    "success": false,
                    "error": "Timesheet not found",
                    "errorCode": "NOT_FOUND"
                }>
                <cfheader statuscode="404" statustext="Not Found">
            </cfif>

        <cfelseif IsDefined("url.id_employee") and IsDefined("url.date")>
            <!--- Daily view --->
            <cfquery name="list_timesheets" datasource="#request.ds#">
            select t.id_timesheet, t.id_employee, t.id_project, t.shift_date,
                   t.start_time, t.end_time, t.notes,
                   e.employee_name, p.project, p.subproject, c.client_name
            from timesheet t
            inner join employee e on t.id_employee = e.id_employee
            inner join project p on t.id_project = p.id_project
            inner join client c on p.id_client = c.id_client
            where t.id_employee = <cfqueryparam value="#url.id_employee#" cfsqltype="cf_sql_integer">
            and t.shift_date = <cfqueryparam value="#url.date#" cfsqltype="cf_sql_date">
            order by t.start_time
            </cfquery>

            <cfset data = []>
            <cfloop query="list_timesheets">
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
                    "hours": DateDiff('n', start_time, end_time) / 60
                })>
            </cfloop>

            <cfset response = {
                "success": true,
                "data": data
            }>

        <cfelseif IsDefined("url.id_employee") and IsDefined("url.start_date") and IsDefined("url.end_date")>
            <!--- Range view --->
            <cfquery name="list_timesheets" datasource="#request.ds#">
            select t.id_timesheet, t.id_employee, t.id_project, t.shift_date,
                   t.start_time, t.end_time, t.notes,
                   e.employee_name, p.project, p.subproject, c.client_name
            from timesheet t
            inner join employee e on t.id_employee = e.id_employee
            inner join project p on t.id_project = p.id_project
            inner join client c on p.id_client = c.id_client
            where t.id_employee = <cfqueryparam value="#url.id_employee#" cfsqltype="cf_sql_integer">
            and t.shift_date >= <cfqueryparam value="#url.start_date#" cfsqltype="cf_sql_date">
            and t.shift_date <= <cfqueryparam value="#url.end_date#" cfsqltype="cf_sql_date">
            order by t.shift_date, t.start_time
            </cfquery>

            <cfset data = []>
            <cfloop query="list_timesheets">
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
                    "hours": DateDiff('n', start_time, end_time) / 60
                })>
            </cfloop>

            <cfset response = {
                "success": true,
                "data": data
            }>

        <cfelse>
            <cfset response = {
                "success": false,
                "error": "Invalid parameters. Use ?id_timesheet=N or ?id_employee=N&date=YYYY-MM-DD or ?id_employee=N&start_date=X&end_date=Y",
                "errorCode": "VALIDATION_ERROR"
            }>
            <cfheader statuscode="400" statustext="Bad Request">
        </cfif>

    <cfelseif cgi.request_method eq "POST">
        <!--- WRITE operations --->
        <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
        <cfset action = requestBody.action ?: "create">

        <cfswitch expression="#action#">
            <cfcase value="create">
                <!--- Validate required fields --->
                <cfif not IsDefined("requestBody.id_employee") or not IsDefined("requestBody.id_project")
                      or not IsDefined("requestBody.shift_date") or not IsDefined("requestBody.start_time")
                      or not IsDefined("requestBody.end_time")>
                    <cfset response = {
                        "success": false,
                        "error": "Missing required fields: id_employee, id_project, shift_date, start_time, end_time",
                        "errorCode": "VALIDATION_ERROR"
                    }>
                    <cfheader statuscode="400" statustext="Bad Request">
                <cfelse>
                    <!--- Check for overlaps --->
                    <cfset shiftDate = requestBody.shift_date>
                    <cfset startDateTime = shiftDate & " " & requestBody.start_time>
                    <cfset endDateTime = shiftDate & " " & requestBody.end_time>

                    <cfquery name="overlap" datasource="#request.ds#">
                    select id_timesheet from timesheet
                    where id_employee = <cfqueryparam value="#requestBody.id_employee#" cfsqltype="cf_sql_integer">
                    and shift_date = <cfqueryparam value="#shiftDate#" cfsqltype="cf_sql_date">
                    and start_time < <cfqueryparam value="#endDateTime#" cfsqltype="cf_sql_timestamp">
                    and end_time > <cfqueryparam value="#startDateTime#" cfsqltype="cf_sql_timestamp">
                    </cfquery>

                    <cfif overlap.recordcount gt 0>
                        <cfset response = {
                            "success": false,
                            "error": "Time overlaps with existing entry",
                            "errorCode": "OVERLAP_ERROR"
                        }>
                        <cfheader statuscode="400" statustext="Bad Request">
                    <cfelse>
                        <!--- Insert --->
                        <cfquery name="insert_timesheet" datasource="#request.ds#" result="insertResult">
                        insert into timesheet (id_employee, id_project, shift_date, start_time, end_time, create_time, notes)
                        values (
                            <cfqueryparam value="#requestBody.id_employee#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#requestBody.id_project#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#shiftDate#" cfsqltype="cf_sql_date">,
                            <cfqueryparam value="#startDateTime#" cfsqltype="cf_sql_timestamp">,
                            <cfqueryparam value="#endDateTime#" cfsqltype="cf_sql_timestamp">,
                            getdate(),
                            <cfqueryparam value="#requestBody.notes ?: ''#" cfsqltype="cf_sql_varchar" maxlength="255">
                        )
                        </cfquery>

                        <cfquery name="getNewId" datasource="#request.ds#">
                        select SCOPE_IDENTITY() as new_id
                        </cfquery>

                        <cfset response = {
                            "success": true,
                            "id_timesheet": getNewId.new_id,
                            "message": "Timesheet created successfully"
                        }>
                        <cfheader statuscode="201" statustext="Created">
                    </cfif>
                </cfif>
            </cfcase>

            <cfcase value="update">
                <!--- Validate required fields --->
                <cfif not IsDefined("requestBody.id_timesheet")>
                    <cfset response = {
                        "success": false,
                        "error": "Missing required field: id_timesheet",
                        "errorCode": "VALIDATION_ERROR"
                    }>
                    <cfheader statuscode="400" statustext="Bad Request">
                <cfelse>
                    <!--- Check if exists --->
                    <cfquery name="check_exists" datasource="#request.ds#">
                    select id_timesheet from timesheet
                    where id_timesheet = <cfqueryparam value="#requestBody.id_timesheet#" cfsqltype="cf_sql_integer">
                    </cfquery>

                    <cfif check_exists.recordcount eq 0>
                        <cfset response = {
                            "success": false,
                            "error": "Timesheet not found",
                            "errorCode": "NOT_FOUND"
                        }>
                        <cfheader statuscode="404" statustext="Not Found">
                    <cfelse>
                        <!--- Check for overlaps (excluding self) --->
                        <cfif IsDefined("requestBody.shift_date") and IsDefined("requestBody.start_time") and IsDefined("requestBody.end_time") and IsDefined("requestBody.id_employee")>
                            <cfset shiftDate = requestBody.shift_date>
                            <cfset startDateTime = shiftDate & " " & requestBody.start_time>
                            <cfset endDateTime = shiftDate & " " & requestBody.end_time>

                            <cfquery name="overlap" datasource="#request.ds#">
                            select id_timesheet from timesheet
                            where id_employee = <cfqueryparam value="#requestBody.id_employee#" cfsqltype="cf_sql_integer">
                            and shift_date = <cfqueryparam value="#shiftDate#" cfsqltype="cf_sql_date">
                            and start_time < <cfqueryparam value="#endDateTime#" cfsqltype="cf_sql_timestamp">
                            and end_time > <cfqueryparam value="#startDateTime#" cfsqltype="cf_sql_timestamp">
                            and id_timesheet != <cfqueryparam value="#requestBody.id_timesheet#" cfsqltype="cf_sql_integer">
                            </cfquery>

                            <cfif overlap.recordcount gt 0>
                                <cfset response = {
                                    "success": false,
                                    "error": "Time overlaps with existing entry",
                                    "errorCode": "OVERLAP_ERROR"
                                }>
                                <cfheader statuscode="400" statustext="Bad Request">
                            </cfif>
                        </cfif>

                        <cfif response.success neq false>
                            <!--- Build dynamic update --->
                            <cfquery name="update_timesheet" datasource="#request.ds#">
                            update timesheet
                            set update_time = getdate()
                            <cfif IsDefined("requestBody.id_employee")>
                            , id_employee = <cfqueryparam value="#requestBody.id_employee#" cfsqltype="cf_sql_integer">
                            </cfif>
                            <cfif IsDefined("requestBody.id_project")>
                            , id_project = <cfqueryparam value="#requestBody.id_project#" cfsqltype="cf_sql_integer">
                            </cfif>
                            <cfif IsDefined("requestBody.shift_date")>
                            , shift_date = <cfqueryparam value="#requestBody.shift_date#" cfsqltype="cf_sql_date">
                            </cfif>
                            <cfif IsDefined("requestBody.start_time") and IsDefined("requestBody.shift_date")>
                            , start_time = <cfqueryparam value="#requestBody.shift_date# #requestBody.start_time#" cfsqltype="cf_sql_timestamp">
                            </cfif>
                            <cfif IsDefined("requestBody.end_time") and IsDefined("requestBody.shift_date")>
                            , end_time = <cfqueryparam value="#requestBody.shift_date# #requestBody.end_time#" cfsqltype="cf_sql_timestamp">
                            </cfif>
                            <cfif IsDefined("requestBody.notes")>
                            , notes = <cfqueryparam value="#requestBody.notes#" cfsqltype="cf_sql_varchar" maxlength="255">
                            </cfif>
                            where id_timesheet = <cfqueryparam value="#requestBody.id_timesheet#" cfsqltype="cf_sql_integer">
                            </cfquery>

                            <cfset response = {
                                "success": true,
                                "message": "Timesheet updated successfully"
                            }>
                        </cfif>
                    </cfif>
                </cfif>
            </cfcase>

            <cfcase value="delete">
                <cfif not IsDefined("requestBody.id_timesheet")>
                    <cfset response = {
                        "success": false,
                        "error": "Missing required field: id_timesheet",
                        "errorCode": "VALIDATION_ERROR"
                    }>
                    <cfheader statuscode="400" statustext="Bad Request">
                <cfelse>
                    <cfquery name="delete_timesheet" datasource="#request.ds#">
                    delete from timesheet
                    where id_timesheet = <cfqueryparam value="#requestBody.id_timesheet#" cfsqltype="cf_sql_integer">
                    </cfquery>

                    <cfset response = {
                        "success": true,
                        "message": "Timesheet deleted successfully"
                    }>
                </cfif>
            </cfcase>

            <cfdefaultcase>
                <cfset response = {
                    "success": false,
                    "error": "Invalid action. Use: create, update, or delete",
                    "errorCode": "VALIDATION_ERROR"
                }>
                <cfheader statuscode="400" statustext="Bad Request">
            </cfdefaultcase>
        </cfswitch>

    <cfelse>
        <cfset response = {
            "success": false,
            "error": "Method not allowed. Use GET or POST",
            "errorCode": "VALIDATION_ERROR"
        }>
        <cfheader statuscode="405" statustext="Method Not Allowed">
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
