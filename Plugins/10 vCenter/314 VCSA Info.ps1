# Start of Settings
# End of Settings

Function Get-VAMISummary {
    <#
    .NOTES
    ===========================================================================
     Created by:    William Lam, Dario Doerflinger
	===========================================================================
    .SYNOPSIS
        This function retrieves some basic information from VAMI interface (5480)
        for a VCSA node which can be an Embedded VCSA, External PSC or External VCSA.
    .DESCRIPTION
        Function to return basic VAMI summary info
    .EXAMPLE
        Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
        Get-VAMISummary
#>
    $systemVersionAPI = Get-CisService -Name 'com.vmware.appliance.system.version'
    $results = $systemVersionAPI.get() | Select-Object product, type, version, build, install_time

    $systemUptimeAPI = Get-CisService -Name 'com.vmware.appliance.system.uptime'
    $ts = [timespan]::fromseconds($systemUptimeAPI.get().toString())
    $uptime = $ts.ToString("hh\:mm\:ss\,fff")

    $summaryResult = [pscustomobject] @{
        Product     = $results.product;
        Type        = $results.type;
        Version     = $results.version;
        Build       = $results.build;
        InstallTime = $results.install_time;
        Uptime      = $uptime
    }
    $summaryResult
}


if ($VCSA) {
    Get-VAMISummary 
}

$Title = "[vCenter] VCSA Info"
$Header = "[vCenter] VCSA Information"
$Comments = "General Information from the VAMI Interface"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
