
<!--- referer --->
<cfif cgi.http_referer contains "timesheet_daily.cfm">
    <cfset referer = "timesheet_daily.cfm">
<cfelse>
    <cfset referer = "recent_timesheets.cfm">
</cfif>

<cfquery name="delete_timesheet" datasource="#request.ds#">
delete from timesheet
where id_timesheet = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
</cfquery>

<cflocation url="#referer#">