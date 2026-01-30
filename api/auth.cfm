<!--- API Authentication Helper --->
<!--- Include this at the top of all API endpoints to require session authentication --->

<cfif not IsDefined("session.user") or not IsDefined("session.userid")>
    <cfset response = {
        "success": false,
        "error": "Authentication required",
        "errorCode": "AUTH_REQUIRED"
    }>
    <cfheader statuscode="401" statustext="Unauthorized">
    <cfcontent type="application/json">
    <cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>
