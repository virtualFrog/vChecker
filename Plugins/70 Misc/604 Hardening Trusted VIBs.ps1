# Start of Settings
# Hardening check for trusted VIBs
$checkForTrustedVIBs = $true
# End of Settings

# Get Settings again from global
$checkForTrustedVIBs = Get-vCheckSetting $Title "checkForTrustedVIBs" $checkForTrustedVIBs

if ($checkForTrustedVIBs) {
    # Loop through each host in the variable $VMH
    foreach ($VMHost in $VMH) {
        # Check if host is connected and not in maintenance mode
        if ($VMHost.ConnectionState -eq "Connected" -and $VMHost.ExtensionData.Runtime.InMaintenanceMode -eq $false) {
            # Get esxcli connection
            $esxcli = Get-EsxCli -VMHost $VMHost -V2

            $esxcli.software.vib.list.Invoke() | Where-Object { 
                $_.AcceptanceLevel -notmatch "VMwareCertified|VMwareAccepted|PartnerSupported" 
            } | Select-Object @{n='Host';e={$VMHost}},Name,AcceptanceLevel,Vendor,InstallDate
        
        }
    }
}

$Title = "[Hardening] Trusted VIBs"
$Header = "[Hardening] Check for untrusted VIBs"
$Comments = "This plugin lists all hosts that are violating the hardening guide for trusted VIBs"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Initial release