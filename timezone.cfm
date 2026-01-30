
<!--- timezone math --->

<cfset info = GetTimeZoneInfo()>

<cfdump var="#info#">

<cfoutput>#Now()#</cfoutput>

<cfset today = DateAdd(now, h, +15)>

<cfoutput>#today#</cfoutput>
