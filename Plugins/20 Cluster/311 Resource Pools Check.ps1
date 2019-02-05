# Start of Settings
# End of Settings

$allResourcePools = $VM | Get-ResourcePool
$allResourcePoolsFiltered = $allResourcePools.Where({$_.Name -notmatch "Resources"}) | Select-Object -Unique
$Report = @()

foreach ($myResourcePool in $allResourcePoolsFiltered) {
    $tempReport = New-Object -TypeName PSObject
    $tempReport | Add-Member -MemberType NoteProperty -Name "Name" -Value $myResourcePool.Name
    $tempReport | Add-Member -MemberType NoteProperty -Name "VM Count" -Value $myResourcePool.ExtensionData.VM.Length
    $tempReport | Add-Member -MemberType NoteProperty -Name "CPU Shares" -Value $myResourcePool.CpuSharesLevel
    $tempReport | Add-Member -MemberType NoteProperty -Name "RAM Shares" -Value $myResourcePool.MemSharesLevel
    $tempReport | Add-Member -MemberType NoteProperty -Name "CPU Reservation (MHz)" -Value $myResourcePool.CpuReservationMHz
    $tempReport | Add-Member -MemberType NoteProperty -Name "RAM Reservation (GB)" -Value $myResourcePool.MemReservationGB
    $tempReport | Add-Member -MemberType NoteProperty -Name "CPU Limit (MHz)" -Value $myResourcePool.CpuLimitMHz
    $tempReport | Add-Member -MemberType NoteProperty -Name "RAM Limit (GB)" -Value $myResourcePool.MemLimitGB
    $Report += $tempReport
}

$Report

$Title = "[Cluster] Resource Pools"
$Header =  "[Cluster] Resource Pools Evaluation"
$Comments = "Resource Pools should never be used with the default shares settings high, normal and low"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Initial Release