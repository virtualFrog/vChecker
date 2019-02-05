# Start of Settings
# End of Settings
 
# Everything in this script will run at the end of vCheck
If ($VIConnection) {
  $VIConnection | Disconnect-VIServer -Confirm:$false | Out-Null
}

if ($CISConnection) {
  $CISConnection | Disconnect-CISServer -Confirm:$false | Out-Null
}

Write-Output ""

$Title = "[Finish] Disconnecting from vCenter"
$Header = "[Finish] Disconnects from vCenter"
$Comments = "Disconnect plugin"
$Display = "None"
$Author = "Alan Renouf, Dario Doerflinger"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
