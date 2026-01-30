
<cfset temp = StructDelete(session, "daily_emp_id")>
<cfset temp = StructDelete(session, "daily_date")>
<cfset temp = StructDelete(session, "daily_emp_name")>

<cflocation url="timesheet_daily.cfm">