<!--- API: Chat --->
<!--- POST: Process natural language timesheet requests using Claude API --->

<cfinclude template="auth.cfm">
<cfcontent type="application/json">

<cfset response = {"success": false}>

<cftry>
    <!--- Check API key is configured --->
    <cfif not IsDefined("application.claudeApiKey") or application.claudeApiKey eq "">
        <cfset response = {
            "success": false,
            "error": "Claude API key not configured. Please set application.claudeApiKey in Application.cfm",
            "errorCode": "CONFIG_ERROR"
        }>
        <cfheader statuscode="500" statustext="Internal Server Error">
    <cfelse>
        <!--- Parse request --->
        <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
        <cfset userMessage = requestBody.message>

        <!--- Get current date info for context --->
        <cfset currentDate = DateFormat(Now(), "yyyy-mm-dd")>
        <cfset currentDayName = DayOfWeekAsString(DayOfWeek(Now()))>
        <cfset yesterdayDate = DateFormat(DateAdd("d", -1, Now()), "yyyy-mm-dd")>

        <!--- Get projects list for context --->
        <cfquery name="projects" datasource="#request.ds#">
        select p.id_project, p.project, p.subproject, c.client_name
        from project p
        inner join client c on p.id_client = c.id_client
        where p.active = 'T' and c.active = 'T'
        order by c.client_name, p.project
        </cfquery>

        <cfset projectList = "">
        <cfloop query="projects">
            <cfset projectList = projectList & "- " & client_name & " / " & project>
            <cfif subproject neq "">
                <cfset projectList = projectList & " / " & subproject>
            </cfif>
            <cfset projectList = projectList & " (ID: " & id_project & ")" & chr(10)>
        </cfloop>

        <!--- Build system prompt --->
        <cfset systemPrompt = "You are a timesheet assistant for Engine No.2. Your job is to help users log their work hours.

Current date: #currentDate# (#currentDayName#)
Yesterday: #yesterdayDate#
Current user: #session.user# (ID: #session.userid#)

Available projects:
#projectList#

When a user describes their work, extract:
1. Project name - match to one of the available projects above
2. Client name (if mentioned, helps disambiguate)
3. Date (default to today if not specified)
4. Start time
5. End time
6. Notes (any additional context)

Time parsing rules:
- '9 am' or '9am' = '09:00'
- '12:30 pm' = '12:30'
- '2pm' = '14:00'
- '5' or '5pm' = '17:00'
- 'noon' = '12:00'

Date parsing rules:
- 'today' = #currentDate#
- 'yesterday' = #yesterdayDate#
- 'Monday', 'Tuesday', etc. = most recent occurrence of that day

IMPORTANT RESPONSE FORMAT:
If you can identify a valid project and time range, respond with a JSON object in this exact format:
{
  ""parsed"": true,
  ""id_project"": [project ID number],
  ""client_name"": ""[client name]"",
  ""project"": ""[project name]"",
  ""subproject"": ""[subproject or empty string]"",
  ""shift_date"": ""YYYY-MM-DD"",
  ""start_time"": ""HH:MM"",
  ""end_time"": ""HH:MM"",
  ""hours"": [decimal hours],
  ""notes"": ""[any notes or empty string]"",
  ""message"": ""[confirmation message to show user]""
}

If you cannot parse the request or need clarification, respond with plain text asking for more information.

If the project name doesn't match any available project, list the closest matches and ask for clarification.">

        <!--- Build messages array --->
        <cfset messages = []>
        <cfset arrayAppend(messages, {
            "role": "user",
            "content": userMessage
        })>

        <!--- Call Claude API --->
        <cfhttp url="https://api.anthropic.com/v1/messages" method="post" result="claudeResponse" timeout="30">
            <cfhttpparam type="header" name="x-api-key" value="#application.claudeApiKey#">
            <cfhttpparam type="header" name="anthropic-version" value="2023-06-01">
            <cfhttpparam type="header" name="content-type" value="application/json">
            <cfhttpparam type="body" value="#serializeJSON({
                'model': application.claudeModel,
                'max_tokens': 1024,
                'system': systemPrompt,
                'messages': messages
            })#">
        </cfhttp>

        <cfif claudeResponse.statusCode contains "200">
            <cfset claudeData = deserializeJSON(claudeResponse.fileContent)>

            <!--- Extract response text --->
            <cfset responseText = "">
            <cfloop array="#claudeData.content#" index="block">
                <cfif block.type eq "text">
                    <cfset responseText = block.text>
                </cfif>
            </cfloop>

            <!--- Check if response is JSON (parsed entry) --->
            <cfif left(trim(responseText), 1) eq "{">
                <cftry>
                    <cfset parsedEntry = deserializeJSON(responseText)>

                    <cfif IsDefined("parsedEntry.parsed") and parsedEntry.parsed eq true>
                        <!--- Valid parsed entry - return for confirmation --->
                        <cfset response = {
                            "success": true,
                            "response": parsedEntry.message,
                            "pendingEntry": {
                                "id_project": parsedEntry.id_project,
                                "client_name": parsedEntry.client_name,
                                "project": parsedEntry.project,
                                "subproject": parsedEntry.subproject ?: "",
                                "shift_date": parsedEntry.shift_date,
                                "start_time": parsedEntry.start_time,
                                "end_time": parsedEntry.end_time,
                                "hours": parsedEntry.hours,
                                "notes": parsedEntry.notes ?: ""
                            }
                        }>
                    <cfelse>
                        <!--- Not a valid parsed entry --->
                        <cfset response = {
                            "success": true,
                            "response": responseText
                        }>
                    </cfif>

                    <cfcatch type="any">
                        <!--- JSON parse failed, treat as plain text --->
                        <cfset response = {
                            "success": true,
                            "response": responseText
                        }>
                    </cfcatch>
                </cftry>
            <cfelse>
                <!--- Plain text response --->
                <cfset response = {
                    "success": true,
                    "response": responseText
                }>
            </cfif>
        <cfelse>
            <!--- Claude API error --->
            <cfset response = {
                "success": false,
                "error": "Claude API error: " & claudeResponse.statusCode,
                "errorCode": "API_ERROR"
            }>
            <cfheader statuscode="502" statustext="Bad Gateway">
        </cfif>
    </cfif>

    <cfcatch type="any">
        <cfset response = {
            "success": false,
            "error": cfcatch.message,
            "errorCode": "SERVER_ERROR"
        }>
        <cfheader statuscode="500" statustext="Internal Server Error">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
