
<!--- reproduce query --->
<cfquery name="export" datasource="#request.ds#">
select a.id_timesheet, a.id_employee, a.id_project, a.shift_date, a.start_time, a.end_time, a.create_time,
b.employee_name, c.project, c.subproject, d.client_name, e.rate_desc, e.rate
from timesheet a, employee b, project c, client d, rate e
where 1 = 1
<cfif form.id_employee neq 0>and a.id_employee = #form.id_employee#</cfif>
and c.id_client = #form.id_client#
and a.start_time >= '#form.start_date# 00:00:00'
and a.start_time <= '#form.end_date# 23:59:59'
and a.id_employee = b.id_employee
and a.id_project = c.id_project
and c.id_client = d.id_client
and a.id_rate = e.id_rate
order by a.start_time
</cfquery>

<!--- create json --->


<!--- table for reference --->

<cfset total_minutes = 0>
<cfset total_charges = 0>

<table class="table table-striped table-bordered">
    <tr class="header-row">
        <th>Employee</th>
        <th>Role</th>
        <th>Date</th>
        <th>Start</th>
        <th>End</th>
        <th>Client</th>
        <th>Project</th>
        <th>Subproject</th>
        <th>Hours</th>
        <th>Rate</th>
        <th>Subtotal</th>
        <th></th>
    </tr>
<cfoutput query="export">
    <tr>
        <td>#employee_name#</td>
        <td>#rate_desc#</td>
        <td>#DateFormat(shift_date, 'yyyy-mm-dd')#</td>
        <td>#TimeFormat(start_time,'hh:nn tt')#</td>
        <td>#TimeFormat(end_time,'hh:nn tt')#</td>
        <td>#client_name#</td>
        <td>#project#</td>
        <td>#subproject#</td>
        <cfset minutes = DateDiff('n', start_time, end_time)>
        <cfset hours = minutes / 60>
        <td>#hours#</td> 
        <td>#rate#</td>
        <cfset subtotal = hours * rate>
        <td>#subtotal#</td>
        <cfset total_charges = total_charges + subtotal>
        <cfset total_minutes = total_minutes + DateDiff('n', start_time, end_time)>
        <td><a href="timesheet_form.cfm?id=#id_timesheet#">Edit</a></td>
        <td><a href="delete_timesheet.cfm?id=#id_timesheet#">Delete</a></td>
    </tr>
</cfoutput>
    <cfset total_hours = total_minutes / 60>
    <tr>
        <td>Total</td>
        <td colspan="7"></td>
        <td><cfoutput>#total_hours#</cfoutput></td>
        <td></td>
        <td><cfoutput>#total_charges#</cfoutput></td>
    </tr>
</table>

<cfoutput>#export.recordcount#</cfoutput>
<br />
<cfset rows = 0>

<cfset json_header = '
{
  "Invoices": [
    {
      "Type": "ACCREC",
      "Contact": {
        "ContactID": "f4076f40-e387-4a2a-8e29-1543a717a6ce"
      },
      "LineItems": [
'>

<cfset json_footer = '
],
      "Date": "2022-07-30",
      "DueDate": "2022-08-30",
      "Reference": "API Development Phase 2",
      "Status": "DRAFT"
    }
  ]
}
'>

<cfset json = json_header>

<cfloop query="export">
    <cfset rows = rows + 1>
    <cfset minutes = DateDiff("n", start_time, end_time)>
    <cfset hours = minutes / 60>
    <cfset subtotal = hours * rate>
    <cfset json = json & '
        {
        "Description": "#rate_desc#",
        "Quantity": #hours#,
        "UnitAmount": #rate#,
        "AccountCode": "200",
        "TaxType": "OUTPUT",
        "LineAmount": #subtotal#
        }<cfif rows lt export.recordcount>,</cfif>
    '>
</cfloop>

<cfset json = json & json_footer>

<cfoutput>#json#</cfoutput>

<form method="post" action="create_xero_invoice2.cfm">
    <input type="hidden" name="start_date" value="<cfoutput>#form.start_date#</cfoutput>">
    <input type="hidden" name="start_date" value="<cfoutput>#form.start_date#</cfoutput>">
    <input type="hidden" name="id_employee" value="<cfoutput>#form.id_employee#</cfoutput>">
    <input type="hidden" name="id_client" value="<cfoutput>#form.id_client#"</cfoutput>">
    <input type="submit" name="submit" class="btn btn-primary" value="Create Invoice on Xero">
</form>


