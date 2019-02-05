$Title = "[VM] Ephemeral PG"
$Header = "[VM] VMs on Ephemeral Portgroup: [count]"
$Comments = ""
$Display = "Table"
$Author = "Tim Williams, Dario Doerflinger"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings
 
$EphemeralPG = Get-VDSwitch | Get-VDPortgroup | Where-Object {$_.PortBinding -eq "Ephemeral"}
if ($null -ne $EphemeralPG) {
    $VM | Get-NetworkAdapter | Where-Object {$_.NetworkName -contains $EphemeralPG} | Select-Object @{Name="VMName"; Expression={$_.parent}}, @{Name="Portgroup"; Expression={$_.NetworkName}}
}
