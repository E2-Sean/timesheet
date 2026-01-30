
<br />
<footer class="text-center text-lg-start bg-light text-muted">
    <!--- Links --->
    <div class="text-center p-8">
    <a href="home.cfm" class="btn btn-secondary border border-dark">Home</a>
    <a href="chat.cfm" class="btn btn-info border border-dark">AI Assistant</a>
    <a href="timesheet_daily.cfm" class="btn btn-light border border-dark">Daily Timesheet</a>
    <a href="timesheet_report.cfm" class="btn btn-light border border-dark">Timesheet Report</a>
    <a href="employee_report.cfm" class="btn btn-light border border-dark">Employee Report</a>
    <a href="clients.cfm" class="btn btn-light border border-dark">Clients</a>
    <a href="employees.cfm" class="btn btn-light border border-dark">Employees</a>
    <a href="projects.cfm" class="btn btn-light border border-dark">Projects</a>
    <a href="recent_timesheets.cfm" class="btn btn-light border border-dark">Recent Timesheets</a>
    <a href="logout.cfm" class="btn btn-danger border border-dark">Logout</a>
    </div>
    <!-- Copyright -->
    <div class="text-center p-4">
    <cfif IsDefined("session.user")>
    Logged in as <cfoutput>#session.user#</cfoutput><br />
    </cfif>
    &copy; Engine No.2 <cfoutput>#DatePart("yyyy", Now())#</cfoutput>
    Copyright: <a class="text-reset fw-bold" href="https://engineno2.com/">Engine No2</a>
    </div>
</footer>
</body>
</html>