# Get-WBReport
Windows Server Backup PowerShell Email Report

Get-WBReport.ps1 is a PowerShell script which emails you a report of the last Windows Server Backup job. It is recommended you set this script to run on a schedule. It is possible to make the script email only if the backup job failed with small modifications however I have opted not to do this as it is possible for backups to fail and you not be notified.

If you require the initial version which was designed for Windows Server 2008 please use the script in the link below.
https://github.com/GavinEke/Get-WBReport/blob/a785c542dcc922ab0888209e7c1baa8b096d5407/Get-WBReport.ps1
