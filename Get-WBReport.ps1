# PowerShell Windows Server Backup Report
# Twitter: @GavinEke
#
# Requires Windows Server Backup Command Line Tools
# Tested on Windows Server 2008/2008 R2 using PowerShell 2.0
# Example usage: .\Get-WBReport.ps1

#region Varibles
# You should change the variables in this region to suit your environment
$users = "test@example.com" # List of users to email your report to (separate by comma)
$fromemail = "test@example.com"
$server = "mail.example.com" #enter your own SMTP server DNS name / IP address here
#endregion

# DO NOT CHANGE ANYTHING PAST THIS LINE!

# Required to use PowerShell with Windows Server Backup
add-pssnapin windows.serverbackup

# Variables
$CurrentTime = Get-Date
$computer = Get-Content env:computername
$WBSummary = Get-WBSummary
$WBLastSuccess = $WBSummary.LastSuccessfulBackupTime
$WBResult = $WBSummary.LastBackupResultHR
$WBErrorMsg = $WBSummary.DetailedMessage

# Change Result of 0 to Success in green text and any other result as Failure in red text
if ($WBResult -eq 0) {$WBResult = "<b><font color=green>Success</font></b>"}
else {$WBResult = "<b><font color=red>Failure</font></b>"}

# Assemble the HTML Report
$HTMLMessage = @"
<!DOCTYPE html>
<html>

<head>
<title>Windows Backup Report</title>
<style>
	body {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	}
	
	#report{
		width: 600px;
	}
	
	h3{
		clear: both;
		font-size: 115%;
		margin-left: 20px;
		margin-top: 30px;
	}
	
	p{ 
		margin-left: 20px;
		font-size: 12px;
	}
</style>
</head>

<body>
<div id="report">
<p><h3>$computer Windows Backup Report</p></h3>
<p>Todays date: $CurrentTime</p>
<p>Last Successful Backup: $WBLastSuccess</p>
<p>Backup Result: $WBResult</p>
<p>Error Message (if applicable): $WBErrorMsg</p>
</div>
</body>

</html>
"@

# Email the report
Send-MailMessage -from $fromemail -to $users -subject "$computer Windows Backup Report" -BodyAsHTML -body $HTMLMessage -priority Normal -smtpServer $server