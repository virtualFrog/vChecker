# Start of Settings
# Datastores to ignore
$DatastoresToIgnore = "*local*"
# End of Settings

foreach ($myCluster in $Clusters) {
    $allDatastores = $myCluster | Get-Datastore | where-object {$_.Name -notlike $DatastoresToIgnore} | Sort-Object Name
    $allHosts = $myCluster | Get-VMHost | Where-Object {$_.ConnectionState -eq "Connected"} | Sort-Object
    ForEach ($myHost in $allHosts) {
        $count++
        $report = New-Object PSObject
        #$report | Add-Member -MemberType NoteProperty -Name "ClusterName" -Value $myCluster.Name
        $report | Add-Member -MemberType NoteProperty -Name "HostName" -Value $myHost.Name
        ForEach ($myDatastore in $allDatastores) {
            $getDS = $myHost | Get-Datastore -Name $myDatastore.Name -ErrorAction SilentlyContinue
            if (!$getDS) {
                $present = " "
            }
            else {
                $present = "X"
            }
            $report | Add-Member -MemberType NoteProperty -Name $myDatastore.Name -Value $present
        }
        if ($count -eq "1") {
            #count is only at 1 during the first run
            [array]$newReport = New-Object PSObject $report
        }
        else {
            #add to the existing object
            [array]$newReport += $report
        }
    }
}
$newReport | Sort-Object ClusterName,HostName

$Title = "[Cluster] DS visibility"
$Header = "[Cluster] Check datastore visibility per cluster"
$Comments = "Checking if all hosts in a cluster can see all the same datastores"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.1
$PluginCategory = "vSphere"

# Change Log:
# Removed Clustername. Issue: Mutli Cluster Environment not displayed correctly.