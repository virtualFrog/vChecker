$Title = "[VM] VMs Memory"
$Header = "[VM] VMs Ballooning or Swapping: [count]"
$Comments = "Ballooning and swapping may indicate a lack of memory or a limit on a VM, this may be an indication of not enough memory in a host or a limit held on a VM, <a href='http://www.virtualinsanity.com/index.php/2010/02/19/performance-troubleshooting-vmware-vsphere-memory/' target='_blank'>further information is available here</a>."
$Display = "Table"
$Author = "Alan Renouf, Frederic Martin"
$PluginVersion = 1.3
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

$FullVM |
    Where-Object {$_.runtime.PowerState -eq "PoweredOn" -and ($_.Summary.QuickStats.SwappedMemory -gt 0 -or $_.Summary.QuickStats.BalloonedMemory -gt 0)} |
    Select-Object @{N = 'Cluster'; E = {(Get-View -Id ((Get-View -Id $_.Runtime.Host -Property Parent).Parent) -Property Name).Name}},
@{N = 'VMHost'; E = {(Get-View -Id $_.Runtime.Host -Property Name).Name}},
@{N = 'VM'; E = {$_.Name}},
@{N = "SwapMB"; E = {$_.Summary.QuickStats.SwappedMemory}},
@{N = "MemBalloonMB"; E = {$_.Summary.QuickStats.BalloonedMemory}} |
    Sort-Object -Property Cluster, VMHost, VM

# Changelog
## 1.1 : Using quick stats property in order to avoid using Get-Stat cmdlet for performance matter
## 1.2 : Updated where clause to filter first
## 1.3 : Added cluster and VMHost to the output and sorted the output