# Start of Settings
# Hardening check for secure boot
$checkForSecureBoot = $true
# End of Settings

# Get Settings again from global
$checkForSecureBoot = Get-vCheckSetting $Title "checkForSecureBoot" $checkForSecureBoot

# Create an empty array to store the report information
$Reports = @()

if ($checkForSecureBoot) {
    # Loop through each host in the variable $VMH
    foreach ($VMHost in $VMH) {
        # Check if host is connected and not in maintenance mode
        if ($VMHost.ConnectionState -eq "Connected" -and $VMHost.ExtensionData.Runtime.InMaintenanceMode -eq $false) {
            # Get esxcli connection
            $esxcli = Get-EsxCli -VMHost $VMHost -V2

            #get the secure boot configuration
            $secureBoot = $esxcli.system.settings.encryption.get.Invoke()

            # Check if settings are hardened
            if ($secureBoot.Mode -eq "NONE" -or $secureBoot.RequireExecutablesOnlyFromInstalledVIBs -eq $false -or $secureBoot.RequireSecureBoot -eq $false) {
                # this server is not hardened
                $Reports += New-Object PSObject -Property @{
                    Host               = $VMHost.Name
                    SecureBootMode     = $secureBoot.Mode
                    SecureVIBMode      = $secureBoot.RequireExecutablesOnlyFromInstalledVIBs
                    SecureBootRequired = $secureBoot.RequireSecureBoot
                }
            }
        }
    }

    $Reports | Select-Object -Property Host, SecureBootMode, SecureVIBMode, SecureBootRequired
}

$Title = "[Hardening] Secure Boot"
$Header = "[Hardening] Secure Boot configured on Hosts"
$Comments = "This plugin lists all hosts that are violating the hardening guide for secure Boot"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Initial release