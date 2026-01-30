# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Engine No.2 Timesheets** - A ColdFusion timesheet management application for tracking employee hours across projects and clients.

**Stack:** ColdFusion 2021, Microsoft SQL Server, Bootstrap 5

## Development Environment

- ColdFusion server running at `C:\ColdFusion2021\cfusion\wwwroot\timesheet`
- Datasource "e2" configured in ColdFusion Administrator pointing to SQL Server
- No build process - files are served directly by ColdFusion

## Database

The application uses datasource `request.ds` (set in Application.cfm) with these core tables:

- **employee** - id_employee, employee_name, magic (password)
- **client** - id_client, client_name, active (T/F)
- **project** - id_project, id_client, project, subproject, active (T/F)
- **timesheet** - id_timesheet, id_employee, id_project, shift_date, start_time, end_time, notes, create_time, update_time

SQL schema files are in `/sql/` directory.

## Architecture

### Template Pattern
All pages use header/footer includes:
```cfml
<cfinclude template="header.cfm">
<!-- page content -->
<cfinclude template="footer.cfm">
```

- `header.cfm` - Auth check, HTML boilerplate, Bootstrap CSS
- `footer.cfm` - Navigation menu, copyright

### Authentication
Session-based via `check_login.cfm`:
- `session.user` - Employee name
- `session.userid` - Employee ID
- `session.daily_emp_id`, `session.daily_date` - Selected timesheet context

### File Naming Conventions
- `add_*.cfm` - Create handlers
- `edit_*.cfm` - Update handlers
- `delete_*.cfm` - Delete handlers
- `submit_*.cfm` - Form submission handlers
- `*_report.cfm` / `*_report2.cfm` - Report filter UI / Report data display
- `api/*.cfm` - REST API endpoints

### Core Features
- `timesheet_daily.cfm` - Primary timesheet entry (main feature)
- `recent_timesheets.cfm` - View/edit recent entries
- `timesheet_report.cfm` - Reporting with filters
- `clients.cfm`, `projects.cfm`, `employees.cfm` - Master data management
- `chat.cfm` - AI-powered natural language timesheet entry

## REST API

All API endpoints are in `/api/` directory and require session authentication. They return JSON responses.

### Endpoints

- **GET /api/employees.cfm** - List all employees
- **GET /api/clients.cfm** - List clients (`?active=T` optional filter)
- **GET /api/projects.cfm** - List projects with client info (`?active=T&id_client=N` optional)
- **GET /api/timesheets.cfm** - Read timesheets
  - `?id_timesheet=N` - Single entry
  - `?id_employee=N&date=YYYY-MM-DD` - Daily view
  - `?id_employee=N&start_date=X&end_date=Y` - Range view
- **POST /api/timesheets.cfm** - Create/Update/Delete timesheets
  - `{"action": "create", "id_employee": N, "id_project": N, "shift_date": "YYYY-MM-DD", "start_time": "HH:MM", "end_time": "HH:MM", "notes": ""}`
  - `{"action": "update", "id_timesheet": N, ...}`
  - `{"action": "delete", "id_timesheet": N}`
- **GET /api/reports.cfm** - Timesheet summaries (`?id_client=N&start_date=X&end_date=Y` required, `?id_employee=N` optional)
- **POST /api/chat.cfm** - Natural language processing via Claude API

### Response Format
```json
{
    "success": true|false,
    "data": [...],
    "error": "message if failed",
    "errorCode": "ERROR_CODE"
}
```

## LLM Chat Interface

The chat interface (`chat.cfm`) uses Claude API to parse natural language into timesheet entries.

### Configuration
Set Claude API key in `Application.cfm`:
```cfml
<cfset application.claudeApiKey = "sk-ant-...">
<cfset application.claudeModel = "claude-sonnet-4-20250514">
```

### Flow
1. User enters natural language (e.g., "I worked on Web Dev for Engine No.2 from 9am to 5pm")
2. `api/chat.cfm` sends to Claude API with project context
3. Claude parses and returns structured data
4. User confirms entry via modal dialog
5. Entry saved via `api/timesheets.cfm`

## Code Patterns

### Database Queries
All queries use `cfqueryparam` for security:
```cfml
<cfquery name="results" datasource="#request.ds#">
  SELECT * FROM table WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>
```

### Form Handling
POST forms redirect to action pages which perform queries and `<cflocation>` redirect back.

### Active Flag
Clients and projects use `active` char(1) field with 'T'/'F' values for soft delete.

## Known Issues

- Passwords stored as plain text in "magic" field
- Rate table exists but is unused
