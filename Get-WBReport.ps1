# PowerShell Windows Server Backup Report
# Twitter: @GavinEke
#
# Requires Windows Server Backup Command Line Tools
# Tested on Windows Server 2012 R2 using PowerShell 4.0
# Example usage: .\Get-WBReport.ps1

#region Varibles
# You should change the variables in this region to suit your environment
$MailMessageTo = "test@example.com" # List of users to email your report to (separate by comma)
$MailMessageFrom = "test@example.com"
$MailMessageSMTPServer = "mail.example.com" # Enter your own SMTP server DNS name / IP address here
$MailMessagePriority = "Normal" # Low/Normal/High
$HTMLMessageSubject = $env:computername+": Backup Report - "+(Get-Date)
#endregion

# DO NOT CHANGE ANYTHING PAST THIS LINE!

# Variables
$WBJob = Get-WBJob -Previous 1
$WBSummary = Get-WBSummary
$WBJobStartTime = $WBJob.StartTime
$WBJobEndTime = $WBJob.EndTime
$WBJobSuccessLog = Get-Content $WBJob.SuccessLogPath
$WBJobFailureLog = Get-Content $WBJob.FailureLogPath

# Change Result of 0 to Success in green text and any other result as Failure in red text
If ($WBSummary.LastBackupResultHR -eq 0) 
{
$HTMLMessageBody = @"
<h1><font color=green>Backup Success</font></h1><br />
Start Time: $WBJobStartTime<br />
Start Time: $WBJobEndTime<br />
<br />
<b>Log:</b><br />
<br />
$WBJobSuccessLog
"@
}
Else
{
$HTMLMessageBody = @"
<h1><font color=red>Backup Failure</font></h1><br />
Start Time: $WBJobStartTime<br />
Start Time: $WBJobEndTime<br />
<br />
<b>Log:</b><br />
<br />
$WBJobFailureLog
"@
}

# Assemble the HTML Report
$HTMLMessage = @"
<!DOCTYPE html>
<html>
<head>
<title>$HTMLMessageSubject</title>
</head>
<body>
$HTMLMessageBody
</body>
</html>
"@

# Email the report
$MailMessageOptions = @{
    From            = "$MailMessageFrom"
    To              = "$MailMessageTo"
    Subject         = "$HTMLMessageSubject"
    BodyAsHTML      = $True
    Body            = "$HTMLMessage"
    Priority        = "$MailMessagePriority"
    SmtpServer      = "$MailMessageSMTPServer"
}
Send-MailMessage @MailMessageOptions
