
<cfapplication name = "e2_timesheets"
    sessionTimeout = #CreateTimeSpan(0, 0, 30, 0)#
    sessionManagement = "Yes">
<cfset request.ds="e2">

<!--- Claude API Configuration --->
<!--- Set your API key here or via environment variable --->
<cfset application.claudeApiKey = "">
<cfset application.claudeModel = "claude-sonnet-4-20250514">