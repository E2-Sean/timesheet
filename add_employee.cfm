
<cfquery name="add_employee" datasource="#request.ds#">
insert into employee (employee_name) values (
    <cfqueryparam value="#form.employee_name#" cfsqltype="cf_sql_varchar" maxlength="10">
)
</cfquery>

<cflocation url="employees.cfm">