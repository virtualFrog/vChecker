# Start of Settings
# End of Settings

# For maintenance please consult https://code.vmware.com/apis/366/vsphere-automation

Function Get-VAMIDisks {
    <#
    .NOTES
    ===========================================================================
     Created by:    William Lam, Dario Doerflinger
	===========================================================================
    .SYNOPSIS
        This function retrieves VMDK disk number to partition mapping VAMI interface (5480)
        for a VCSA node which can be an Embedded VCSA, External PSC or External VCSA.
    .DESCRIPTION
        Function to return VMDK disk number to OS partition mapping
    .EXAMPLE
        Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
        Get-VAMIDisks
#>
    $storageAPI = Get-CisService -Name 'com.vmware.appliance.system.storage'
    $disks = $storageAPI.list()

    foreach ($disk in $disks | Sort-Object {[int]$_.disk.toString()}) {
        $disk | Select-Object Disk, Partition
    }
}


if ($VCSA) {
    Get-VAMIDisks 
 }

$Title = "[vCenter] VCSA Disks"
$Header = "[vCenter] VCSA Disk Mapping"
$Comments = "Shows the VCSA's disk number and corresponding partition in case one needs to be resized"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
