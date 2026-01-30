<cfif not IsDefined("form.id_ts") or (form.id_ts eq 0)>
    <cfquery name="insert_timesheet" datasource="#request.ds#">
    insert into timesheet (id_employee, id_project, id_rate, shift_date, start_time, end_time, create_time, notes)
    values (
        <cfqueryparam value="#id_employee#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#id_project#" cfsqltype="cf_sql_integer">,
        1,
        <cfqueryparam value="#work_date#" cfsqltype="cf_sql_date">,
        <cfqueryparam value="#work_date# #start_time#" cfsqltype="cf_sql_timestamp">,
        <cfqueryparam value="#work_date# #end_time#" cfsqltype="cf_sql_timestamp">,
        getdate(),
        <cfqueryparam value="#notes#" cfsqltype="cf_sql_varchar" maxlength="255">
    )
    </cfquery>
<cfelse>
    <cfquery name="update_timesheet" datasource="#request.ds#">
    update timesheet
    set id_employee = <cfqueryparam value="#id_employee#" cfsqltype="cf_sql_integer">,
    id_project = <cfqueryparam value="#id_project#" cfsqltype="cf_sql_integer">,
    shift_date = <cfqueryparam value="#work_date#" cfsqltype="cf_sql_date">,
    start_time = <cfqueryparam value="#work_date# #start_time#" cfsqltype="cf_sql_timestamp">,
    end_time = <cfqueryparam value="#work_date# #end_time#" cfsqltype="cf_sql_timestamp">,
    update_time = getdate(),
    notes = <cfqueryparam value="#notes#" cfsqltype="cf_sql_varchar" maxlength="255">
    where id_timesheet = <cfqueryparam value="#form.id_ts#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>

<cflocation url="#form.referer#">

