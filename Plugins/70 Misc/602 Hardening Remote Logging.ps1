# Start of Settings
# Hardening check for remote logging
$SyslogServer = "syslog.example.com"
# End of Settings

# Get Settings again from global
$SyslogServer = Get-vCheckSetting $Title "SyslogServer" $SyslogServer

# Create an empty array to store the report information
$Reports = @()

# Loop through each host in the variable $VMH
foreach ($VMHost in $VMH) {
    # Check if host is connected and not in maintenance mode
    if ($VMHost.ConnectionState -eq "Connected" -and $VMHost.ExtensionData.Runtime.InMaintenanceMode -eq $false) {
        # Get syslog server configuration
        $SyslogConfig = (Get-VMHostSysLogServer -VMHost $VMHost).Host

        # Check if syslog server matches setting
        if ($SyslogConfig -notlike "*$SyslogServer*") {
            # Syslog server is configured as expected
            $Reports += New-Object PSObject -Property @{
                Host = $VMHost.Name
                Sysloghost = "Syslog server is not configured as expected. Configured : $SyslogConfig"
            }
        }
    }
}

$Reports


$Title = "[Hardening] Remote Logging"
$Header = "[Hardening] Remote Logging configured on Hosts"
$Comments = "This plugin lists all hosts that are violating the hardening guide for Remote Logging by not having $SyslogServer configured"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Initial release