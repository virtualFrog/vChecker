# Start of Settings
# Comment about setting that shows in the config wizard
# End of Settings

<#
        .DESCRIPTION Retrieves vSphere CPU Socket to Core Usage Analysis
        .NOTES  Author:  William Lam, VMware, Dario Doerflinger
        .NOTES  Last Updated: 02/06/2020
#>
    $theseClusters = Get-View -ViewType ClusterComputeResource -Property Name,Host
    $results = @()
    foreach ($cluster in $theseClusters) {
        $vmhosts = Get-View $cluster.host -Property Name, Hardware.CpuInfo, Runtime
        foreach ($vmhost in $vmhosts) {
            if ($vmhost.Runtime.ConnectionState -eq "connected" -and $vmhost.Hardware.systemInfo.Model -ne "VMware Mobility Platform") {
                $sockets = $vmhost.Hardware.CpuInfo.NumCpuPackages
                $coresPerSocket = ($vmhost.Hardware.CpuInfo.NumCpuCores / $sockets)
    
                if ($coresPerSocket -le 32) {
                    $futureLicenseCount = $sockets * 1
                }
                else {
                    $futureLicenseCount = $sockets * ([math]::ceiling($coresPerSocket / 32))
                }
    
                $tmp = [pscustomobject] @{
                    CLUSTER                        = $cluster.name;
                    VMHOST                         = $vmhost.name;
                    NUM_CPU_SOCKETS                = $sockets;
                    NUM_CPU_CORES_PER_SOCKET       = $coresPerSocket;
                    CPU_LICENSE_COUNT              = $sockets;
                    CORE_LIMITED_CPU_LICENSE_COUNT = $futureLicenseCount;
                }
                $results += $tmp
            }
        }
    }
$results 




$Title = "[Cluster] CPU Core License Overview"
$Header = "[Cluster] CPU Core License Overview"
$Comments = "Display how the licensing changes will affect your environment"
$Display = "Table"
$Author = "William Lam, Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Initial Version