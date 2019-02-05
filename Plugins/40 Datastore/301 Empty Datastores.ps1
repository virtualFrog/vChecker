$Title = "[Datastore] no VMs"
$Header =  "[Datastore] Datastores without VMs"
$Comments = "List of all Datastores that do not have VMs on it"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings
# End of Settings

foreach ($cluster in $Clusters) {
    Get-Datastore -RelatedObject $cluster |Where-Object {($_ |Get-VM).Count -eq 0 -and $_ -notlike "*rest*" -and $_ -notlike "*_local" -and $_ -notlike "*snapshot*" -and $_ -notlike "*placeholder*"}|Select-Object Name, FreeSpaceGB, CapacityGB, @{N="NumVM";E={@($_ |Get-VM).Count}}, @{N="LUN";E={($_.ExtensionData.Info.Vmfs.Extent[0]).DiskName}}, @{N="Cluster";E={@($cluster.Name)}} |Sort Name
}