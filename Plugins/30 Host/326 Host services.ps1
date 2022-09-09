#Start of Settings
# End of Settings

Get-VMHost | Get-VMHostService | Where-Object {($_.Required -match "True" -and $_.Running -notmatch "True") -or ($_.Required -match "False" -and $_.Running -match "True" -and $_.Key -notmatch "vpxa|DCUI|TSM-SSH|lbtd|ntpd|sfcbd-watchdog|TSM|snmpd|vmware-fdm")} | Select-Object VMHost,Key,Label,Policy,Running,Required 

$Title = "[Hosts] Service Status"
$Header = "[Hosts] Service Status"
$Comments = "Check if the host services are running as expected"
$Display = "Table"
$Author = "Felix Longardt, Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# history
# 1.0 - initial version