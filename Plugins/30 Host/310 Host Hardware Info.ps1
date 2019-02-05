# Start of Settings
# End of Settings

# Get Settings again from global
# $thisIsASetting = Get-vCheckSetting $Title "thisIsASetting" $thisIsASetting

$Report = @() 
$TotalVMHostsCount = $VMH.Length - 1
$vmHosts = $VMH | Select-Object Name, ConnectionState, Version, MaxEVCMode, @{N = "BiosVersion"; E = {$_.ExtensionData.Hardware.BiosInfo.BiosVersion}}, @{N = "BiosReleaseDate"; E = {$_.ExtensionData.Hardware.BiosInfo.ReleaseDate}}, @{N = "Cluster"; E = { $_.Parent}}
$i = 0
foreach ($vmHost in $vmHosts) {          
            
    Write-Progress -Activity "vCollecting hosts" -Status ("Host: {0}" -f $vmHost.Name) -PercentComplete ((100*$i)/$TotalVMHostsCount) -Id 2  -ParentId 1
     


    
    $ConnectionState = $vmHost.ConnectionState
    if ($ConnectionState -eq 'NotResponding') {
        $ESXiInfo = New-Object PSObject  
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Cluster"                 -Value $vmHost.Cluster 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Name"                    -Value $vmHost.name
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Version"                 -Value $vmHost.Version   
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Hardware Vendor"         -Value "N/A" 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Hardware Model"          -Value "N/A" 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Serial Number"           -Value "N/A"
        $ESXiInfo | add-member -MemberType NoteProperty -Name "BIOS Version"            -Value $vmHost.BiosVersion 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "BIOS Release Date"       -Value $vmHost.BiosReleaseDate
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Max EVC Mode"            -Value $vmHost.MaxEVCMode 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "CPU Model"               -Value "N/A" 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Connection State"        -Value $vmHost.ConnectionState
    }
    else {

        $VMHardwareInfo = get-vmhosthardware -vmhost $vmHost.name |Select-Object Manufacturer, Model, SerialNumber, CpuModel, CpuCoreCountTotal
        $ESXiInfo = New-Object PSObject  
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Cluster"                 -Value $vmHost.Cluster 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Name"                    -Value $vmHost.name
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Version"                 -Value $vmHost.Version
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Hardware Vendor"         -Value $VMHardwareInfo.Manufacturer 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Hardware Model"          -Value $VMHardwareInfo.Model 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Serial Number"           -Value $VMHardwareInfo.SerialNumber
        $ESXiInfo | add-member -MemberType NoteProperty -Name "BIOS Version"            -Value $vmHost.BiosVersion 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "BIOS Release Date"       -Value $vmHost.BiosReleaseDate
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Max EVC Mode"            -Value $vmHost.MaxEVCMode 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "CPU Model"               -Value $VMHardwareInfo.CpuModel 
        $ESXiInfo | add-member -MemberType NoteProperty -Name "Connection State"        -Value $vmHost.ConnectionState
    }
    $Report += $ESXiInfo
    $i++
} # END foreach 

$Report

$Title = "[Hosts] Hardware"
$Header = "[Hosts] Collect Hardware Details"
$Comments = "Based on VMware Code Sample, this will collect hardware information about all hosts"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.2
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Initial Release
## 1.1 : fixed division by zero
## 1.2 : removed unneeded object properties