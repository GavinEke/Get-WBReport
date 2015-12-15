# PowerShell Windows Server Backup Remote Report
# Twitter: @GavinEke
#
# Example usage: .\Get-WBReportRemotely.ps1 .\list.txt

#region Varibles
# You should change the variables in this region to suit your environment
$MailMessageTo = "example@example.com" # List of users to email your report to (separate by comma)
$MailMessageFrom = "example@example.com" # Enter the email you would like the report sent from
$MailMessageSMTPServer = "smtp.example.com" # Enter your own SMTP server DNS name / IP address here
$MailMessagePriority = "Normal" # Low/Normal/High
$HTMLMessageSubject = "Backup Report - "+(Get-Date) # Email Subject
#endregion

##############################################
#   DO NOT CHANGE ANYTHING PAST THIS LINE!   #
##############################################

# Test to make sure there is only 1 argument
if(!($($args.Count) -eq 1)){
	Write-Host -Object " "
	Write-Host -Object "The Script requires 1 argument only, please check example usage and try again"
	Write-Host -Object " "
	Write-Host -Object "Press any key to exit ..."
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Exit
}

# Test if list exists and print error and exit if it does not
if(!(Test-Path -Path $args[0])){
	Write-Host -Object " "
	Write-Host -Object "Error - The following path was not found: $args"
	Write-Host -Object " "
	Write-Host -Object "Press any key to exit ..."
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Exit
}

# Variables
$computers = Get-Content -Path $args[0] # Takes first param as computer list

# Faux Get-WBSummary to resolve command not found - http://i.imgur.com/7XBAmNV.png
Function Get-WBSummary {}

ForEach ($computer in $computers) {
	# Clear Old Variable Value
	$WBLastSuccess = ""
	
	# Test PSRemoting Connection
	Test-WSMan -ComputerName $computer
	If ($?) {
		# Create PSRemoting Connection
		$PSSesh = New-PSSession -ComputerName $computer
			
		# Get OS Version Number
		$OSVer = (Get-CimInstance -Class Win32_OperatingSystem).version
		
		# Run Remote PowerShell Commands - 2008 requires snapin
		If ($OSVer -le 6.1) {
			Invoke-Command -Session $PSSesh -ScriptBlock {Add-PSSnapin -Name Windows.ServerBackup}
		}
		$WBResult = Invoke-Command -Session $PSSesh -ScriptBlock {(Get-WBSummary).LastBackupResultHR}
		$WBLastSuccess = Invoke-Command -Session $PSSesh -ScriptBlock {(Get-WBSummary).LastSuccessfulBackupTime}
		
		# Change Result of 0 to Success in green text and any other result as Failure in red text
		If ($WBResult -eq 0) {
			$WBResult = "<font color=green>Success</font>"
		}
		Else {
			$WBResult = "<font color=red>Failure</font>"
		}
		
		# Place Results In HTML Table
		$HTMLTablePart = "<tr><td>$computer</td><td>$WBResult</td><td>$WBLastSuccess</td></tr>"
		$HTMLTableFull += $HTMLTablePart
		
		# Remove PSRemoting Connection
		Get-PSSession | Remove-PSSession
	}
	Else {
		$HTMLTablePart = "<tr><td>$computer</td><td>WinRM Connection Failed</td><td> </td></tr>"
		$HTMLTableFull += $HTMLTablePart
	}
}

# Assemble the HTML Report
$HTMLMessage = @"
<!DOCTYPE html>
<html>
<head>
<title>$HTMLMessageSubject</title>
</head>
<body>
<table>
<tr><td><b>Computer Name</b></td><td><b>Last Result &nbsp&nbsp&nbsp</b></td><td><b>Last Successful Backup</b></td></tr>
$HTMLTableFull
</table>
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
