
<cfapplication name = "e2_timesheets"
    sessionTimeout = #CreateTimeSpan(0, 0, 30, 0)#
    sessionManagement = "Yes">
<cfset request.ds="e2">

<!--- Load local config (API keys, etc) if it exists --->
<cfif fileExists(expandPath("env.cfm"))>
    <cfinclude template="env.cfm">
</cfif>

<!--- Claude API Configuration --->
<cfset application.claudeModel = "claude-sonnet-4-20250514">

