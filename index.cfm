
<cfinclude template="header.cfm">

<div class="p-5">

<h1>Login</h1>

<form method="post" action="check_login.cfm">
    <div class="row g-3"> 
        <div class="col-2">
        <label for="username">Username</label>
        <input type="text" name="username" id="username" class="form-control" >
        </div>
    </div>
    <div class="row g-3">
        <div class="col-2">
        <label for="password">Password</label>
        <input type="password" name="password" id="password" class="form-control">
        </div>
    </div>
    <br />
    <div class="row g-3">
        <div class="col-2">
        <input type="submit" class="btn btn-primary" name="submit_btn" value="Submit">
        </div>
    </div>
</form>

</div>

<cfinclude template="footer.cfm">


