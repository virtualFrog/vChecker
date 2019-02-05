# Start of Settings
# End of Settings

$BigReport = ""
$report = ""
$Loopcount = 0
ForEach ($myCluster in $Clusters) {
    $clusterHosts = $myCluster | Get-VMHost | Where-Object {$_.ConnectionState -eq "Connected"}| Sort-Object Name
    ForEach ($vmhost in $clusterHosts) {
        $Loopcount++

        $vms = $vmhost | Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"}
        $vmMemSum = $vms.memoryGB | Measure-Object -sum
        $vmCpuSum = $vms.NumCpu | Measure-Object -sum
        $ratio = [math]::round($vmCpuSum.sum / $vmhost.NumCpu, 2)
        $hostMemory = [math]::round($vmhost.MemoryTotalGB, 2)
        $vmMemory = [math]::round($vmMemSum.sum, 2)

        $report = New-Object psobject
        $report | Add-Member -MemberType NoteProperty -Name "Cluster" -Value $myCluster.Name
        $report | Add-Member -MemberType NoteProperty -Name "VMhost" -Value $vmhost.Name
        $report | Add-Member -MemberType NoteProperty -Name "VM Count" -Value $vms.Length
        $report | Add-Member -MemberType NoteProperty -Name "Host Memory" -Value $hostMemory
        $report | Add-Member -MemberType NoteProperty -Name "VM Memory" -Value $vmMemory
        $report | Add-Member -MemberType NoteProperty -Name "Host CPU" -Value $vmhost.NumCpu
        $report | Add-Member -MemberType NoteProperty -Name "VM CPU" -Value $vmCpuSum.sum
        $report | Add-Member -MemberType NoteProperty -Name "vCPU per pCPU" -Value $ratio

        if ($Loopcount -eq "1") {
            #count is only at 1 during the first run
            $BigReport = New-Object PSObject $report
        }
        else {
            #add to the existing object
            [array]$BigReport += $report
        }
    }
}
$BigReport | Sort-Object Cluster, VMhost


$Title = "[Cluster] Host Usage"
$Header = "[Cluster] Per Host Resource Usage"
$Comments = "Calculates the used resources and CPU overcommitment ratio per each host"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.1
$PluginCategory = "vSphere"