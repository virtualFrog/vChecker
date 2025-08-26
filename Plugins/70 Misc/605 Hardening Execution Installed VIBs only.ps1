# Start of Settings
# Hardening: Check Execution of installed VIBs
$checkForexecInstalledOnly = $true
# End of Settings

# Get Settings again from global
$checkForexecInstalledOnly = Get-vCheckSetting $Title "checkForexecInstalledOnly" $checkForexecInstalledOnly

$Reports = @()

if ($checkForexecInstalledOnly) {
    # Loop through all hosts in $VMH variable
    foreach($esxihost in $VMH) {
        try {
            # Check if host is connected and not in maintenance mode
            if ($esxihost.ConnectionState -eq "Connected" -and $esxihost.ExtensionData.Runtime.InMaintenanceMode -eq $false) {
                # Get the value of the Advanced Setting "VMkernel.Boot.execInstalledOnly"
                $execInstalledOnly = (Get-AdvancedSetting -Entity $esxihost -Name "VMkernel.Boot.execInstalledOnly").Value
                # Check if the setting is not set to 1
                if ($execInstalledOnly -ne 1) {
                    # Add current host to $Reports if it's violating the hardening guide for VMkernel.Boot.execInstalledOnly
                    $Reports += New-Object PSObject -Property @{
                        Host = $esxihost
                        ExecuteOnlyInstalledBinaries = $execInstalledOnly
                    }
                }
            }
        }
        catch {
            Write-Host "Error: $($_.Exception.Message) for $esxihost" -ForegroundColor Red
        }
    }
}

$Reports | Select-Object -Property Host, ExecuteOnlyInstalledBinaries

$Title = "[Hardening] Execution Policy"
$Header = "[Hardening] Execution Policy for Binaries"
$Comments = "This plugin lists all hosts that are violating the hardening guide for VMkernel.Boot.execInstalledOnly which should be set to 1/true"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
