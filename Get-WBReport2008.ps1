#Requires –Version 2
#Requires –PSSnapin Windows.ServerBackup

<#
    PowerShell Windows Server Backup Report
    Twitter: @GavinEke
    
    Requires Windows Server Backup Command Line Tools
    This version is for Windows Server 2008/2008 R2
    Example usage: .\Get-WBReport.ps1
#>

# Public Varibles
$MailMessageTo = "test@example.com" # List of users to email your report to (separate by comma)
$MailMessageFrom = "test@example.com" # Enter the email you would like the report sent from
$MailMessageSMTPServer = "mail.example.com" # Enter your own SMTP server DNS name / IP address here
$MailMessagePriority = "Normal" # Low/Normal/High
$HTMLMessageSubject = $env:computername+": Backup Report - "+(Get-Date) # Email Subject

# DO NOT CHANGE ANYTHING PAST THIS LINE!

# Required to use PowerShell with Windows Server Backup
Add-PSSnapin Windows.ServerBackup

# Private Variables
$CurrentTime = Get-Date
$WBSummary = Get-WBSummary
$WBLastSuccess = $WBSummary.LastSuccessfulBackupTime
$WBResult = $WBSummary.LastBackupResultHR
$WBErrorMsg = $WBSummary.DetailedMessage

# Change Result of 0 to Success in green text and any other result as Failure in red text
If ($WBSummary.LastBackupResultHR -eq 0) {
    $WBJobResult = "successful"
} Else {
    $WBJobResult = "failed"
}

# Assemble the HTML Report
$HTMLMessage = @"
<!DOCTYPE html>
<html>
<head>
<title>$HTMLMessageSubject</title>
<style>
h1.successful {color:green;}
h1.failed {color:red;}
p.successful {visibility:hidden;}
p.failed {visibility:visible;}
</style>
</head>
<body>
<h1 class="$WBJobResult">Backup $WBJobResult</h1>
<p>Last Successful Backup: $WBLastSuccess</p>
<p class="$WBJobResult">Error Message:<br>
$WBErrorMsg</p>
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
