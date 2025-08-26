# Start of Settings
# Hardening: Check SNMP Service
$checkForSNMPHardening = $true
# End of Settings

# Get Settings again from global
$checkForSNMPHardening = Get-vCheckSetting $Title "checkForSNMPHardening" $checkForSNMPHardening

$Reports = @()

if ($checkForSNMPHardening) {
    # Loop through all hosts in $VMH variable
    foreach ($esxihost in $VMH) {
        try {
            # Check if host is connected and not in maintenance mode
            if ($esxihost.ConnectionState -eq "Connected" -and $esxihost.ExtensionData.Runtime.InMaintenanceMode -eq $false) {
                # Get SNMP service state for current host
                $SNMP = Get-VMHostService -VMHost $esxihost | Where-Object { $_.Key -eq 'snmpd' }
                # Check if SNMP service is in 'On' policy or currently running
                if ($SNMP.Policy -eq 'On' -or $SNMP.Running -eq 'True') {
                    # Add current host to $Reports if it's violating the hardening guide for SNMP
                    $Reports += New-Object PSObject -Property @{
                        Host  = $esxihost
                        Policy  = $SNMP.Policy
                        Running = $SNMP.Running
                    }
                }
            }
        }
        catch {
            Write-Host "Error: $($_.Exception.Message) for $esxihost" -ForegroundColor Red
        }
    }
}

$Reports | Select-Object Host, Policy, Running

$Title = "[Hardening] SNMP Service"
$Header = "[Hardening] SNMP Service"
$Comments = "This plugin lists all hosts that are violating the hardening guide for SNMP"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"