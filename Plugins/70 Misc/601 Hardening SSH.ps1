# Start of Settings
# Hardening: Check SSH Service
$checkForSSHHardening = $true
# End of Settings

# Get Settings again from global
$checkForSSHHardening = Get-vCheckSetting $Title "checkForSSHHardening" $checkForSSHHardening

$Reports = @()

if ($checkForSSHHardening) {
    # Loop through all hosts in $VMH variable
    foreach($esxihost in $VMH) {
        try {
            # Check if host is connected and not in maintenance mode
            if ($esxihost.ConnectionState -eq "Connected" -and $esxihost.ExtensionData.Runtime.InMaintenanceMode -eq $false) {
                # Get SSH service state for current host
                $SSH = Get-VMHostService -VMHost $esxihost | Where-Object { $_.Key -eq 'tsm-ssh' }
                $TSM = Get-VMHostService -VMHost $esxihost | Where-Object { $_.Key -eq 'tsm' }
                # Check if SSH or TSM service is in 'On' policy or currently running
                if (($SSH.Policy -eq 'on' -or $SSH.Running -eq 'True') -or ($TSM.Policy -eq 'on' -or $TSM.Running -eq 'True')) {
                    # Add current host to $Reports if it's violating the hardening guide for SSH
                    $Reports += New-Object PSObject -Property @{
                        Host = $esxihost
                        SSH_Policy = $SSH.Policy
                        SSH_Running = $SSH.Running
                        TSM_Policy = $TSM.Policy
                        TSM_Running = $TSM.Running
                    }
                }
            }
        }
        catch {
            Write-Host "Error: $($_.Exception.Message) for $esxihost" -ForegroundColor Red
        }
    }
}

$Reports | Select-Object -Property Host, SSH_Policy, SSH_Running, TSM_Policy, TSM_Running

$Title = "[Hardening] SSH Service"
$Header = "[Hardening] SSH Service"
$Comments = "This plugin lists all hosts that are violating the hardening guide for SSH and ESXi Shell"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"