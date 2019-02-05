# Start of Settings
# End of Settings

Function Get-VAMIPWPolicy {
    <#
    .NOTES
    ===========================================================================
     Created by:    Dario Doerflinger
	===========================================================================
	.SYNOPSIS
		This function retrieves VAMI local users password policies using VAMI interface (5480)
        for a VCSA node which can be an Embedded VCSA, External PSC or External VCSA.
	.DESCRIPTION
		Function to retrieve VAMI local users password policy
	.EXAMPLE
        Connect-CisServer -Server 192.168.1.100 -User administrator@vsphere.local -Password VMware1!
        Get-VAMIPWPolicy
#>
    if ($global:DefaultVIServer.Version -eq "6.7.0") {
        $policyAPI = Get-CisService -Name 'com.vmware.appliance.local_accounts.policy'
        $policy = $policyAPI.get()

        $policyInfo = New-Object psobject
        $policyInfo | Add-Member -MemberType NoteProperty -Name "Valid for" -Value ([string]$policy.max_days + " days")
        $policyInfo | Add-Member -MemberType NoteProperty -Name "Minimum Days active" -Value ([string]$policy.min_days + " days")
        $policyInfo | Add-Member -MemberType NoteProperty -Name "Number of Days warning" -Value ([string]$policy.warn_days + " days")

        $policyInfo
    }
    else {
        # Nope
        $failure = "This plugin is not compatible with version $($global:DefaultVIServer.Version) at this time"
        $failure
    }
}


if ($VCSA) {
    Get-VAMIPWPolicy 
}

$Title = "[vCenter] VCSA PW Policy"
$Header = "[vCenter] VCSA Password Policy for local Users"
$Comments = "This is the default password policy. Take care that the root account does not expire!"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
