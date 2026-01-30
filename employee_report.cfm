
<!--- queries --->
<cfquery name="list_employees" datasource="#request.ds#">
select * from employee
</cfquery>

<cfquery name="list_clients" datasource="#request.ds#">
select * from client
</cfquery>

<cfquery name="list_projects" datasource="#request.ds#">
select a.*, b.client_name 
from project a, client b
where a.id_client = b.id_client
</cfquery>

<cfquery name="list_" datasource="#request.ds#">
select * from employee
</cfquery>

<!--- defaults --->
<cfset first = DateFormat(Now(), "yyyy-mm") & "-01">
<cfset last = DateFormat(Now(), "yyyy-mm") & "-" & DaysInMonth(month(Now()))>

<cfparam name="start_date" default="#first#">
<cfparam name="end_date" default="#last#">

<cfinclude template="header.cfm">

<div class="p-5">

<h1>Employee Report</h1>

<form method="post" action="employee_report2.cfm">
    <div class="row p-2"> 
        <div class="col-3">
            <label for="employee">Employee</label>
            <select name="id_employee" class="form-select">
                <cfoutput query="list_employees">
                <option value="#id_employee#" <cfif id_employee eq session.userid>selected</cfif>>#employee_name#</option>
                </cfoutput>
            </select>
        </div>
        <div class="col-3">
            <label for="project">Client</label>
            <select name="id_client" class="form-select">
                <option value="0">All Clients</option>
                <cfoutput query="list_clients">
                <option value="#id_client#">#client_name#</option>
                </cfoutput>
            </select>
        </div>
    </div>
    <div class="row p-2"> 
        <div class="col-3">
            <label for="start_time">Start Date</label>
            <input type="date" name="start_date" class="form-control" value="<cfoutput>#start_date#</cfoutput>">
        </div>
        <div class="col-3">
            <label for="end_time">End Date</label>
            <input type="date" name="end_date" class="form-control" value="<cfoutput>#end_date#</cfoutput>">
         </div>
    </div>
    <div class="row p-2"> 
        <div class="col-1">
            <input type="submit" class="btn btn-primary" name="submit_btn" value="Submit">
        </div>
    </div>
</form>

</div>

<cfinclude template="footer.cfm">