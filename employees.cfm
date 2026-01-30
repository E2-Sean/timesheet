
<cfquery name="list_employees" datasource="#request.ds#">
select * from employee
</cfquery>

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Employees</h1>

<form method="post" action="add_employee.cfm">
<input type="text" name="employee_name">
<input type="submit" value="Add Employee">
</form>
<br />
<br />

<cfoutput query="list_employees">
#employee_name#<br />
</cfoutput>

</div>

<cfinclude template="footer.cfm">