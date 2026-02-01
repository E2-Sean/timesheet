
<cfif cgi.script_name contains "index.cfm">
    <!--- do nothing --->
<cfelseif not IsDefined("session.user")>
    <!--- flick to login page --->
    <cflocation url="index.cfm">
<cfelse>
    <!--- do nothing --->
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Engine No.2 Timesheets</title>
    <link rel="icon" type="image/png" href="img/e2_icon.png">
    <link rel="stylesheet" type="text/css" href="css/e2.css" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="google" content="notranslate">
    <!--- Montserrat font --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300&display=swap" rel="stylesheet">
    <!--- Bootstrap --->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/bootstrap.bundle.min.js"></script>
</head>
<body>

<!-- top navbar -->
<nav class="navbar navbar-expand-lg navbar-light bg-light border-bottom-line">
    <div class="collapse navbar-collapse flex-grow-1 text-left">
        <a class="navbar-brand" href="home.cfm"><img src="img/e2_logo.jpg" width="270" height="43" alt=""></a>
        <a class="navbar-brand" href="home.cfm">Timesheets</a>
    </div>
    <div class="collapse navbar-collapse flex-grow-1 text-right">
        <ul class="navbar-nav ms-auto flex-nowrap">
            <cfif IsDefined("session.user")>
                <a class="navbar-brand ms-auto" href="logout.cfm">Log Out</a>
            </cfif>
        </ul>
    </div>
</nav>