$Title = "[Hosts] Advanced Settings"
$Header =  "[Hosts] Advanced Settings that are not default: [count]"
$Comments = "Show all advanced settings that deviate from the default setting"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.4
$PluginCategory = "vSphere"

# Start of Settings 
# Set if all advanced settings should be collected or only those not on default value
$delta = $true
# Advanced Settings to ignore in this check
$excludedSettings = "/Migrate/Vmknic|/UserVars/ProductLockerLocation|/UserVars/SuppressShellWarning|/UserVars/HostClientCEIPOptIn"
# End of Settings

$excludedSettings = Get-vCheckSetting $Title "excludedSettings" $excludedSettings
$delta = Get-vCheckSetting $Title "delta" $delta

function getAllAdvancedSettingsESXi() {
    <# 
.SYNOPSIS 
    This script will output all Advanced Settings from a esxi host that differ from the default
.DESCRIPTION 
    The script will get all advanced settings that are not at default value from a given esxi host
.NOTES 
    Author     : Dario Dörflinger - virtualfrog.wordpress.com
.LINK 
    http://virtualfrog.wordpress.com
.PARAMETER hostName 
   Name of the host used for source compare (optional)
.PARAMETER delta
   Switch to decide if only values that differ from the default value should get processes
.EXAMPLE 
	C:\foo> .\Get-AdvancedSettingsNotDefault.ps1 -hostName esx01.virtualfrog.lab -delta:$true
	
	Description
	-----------
	Gets All settings that are not at default value from given host
.EXAMPLE 
    C:\foo> .\Get-AdvancedSettingsNotDefault.ps1 -delta:$true
    
    Description
    -----------
    Gets All settings from all hosts that are not at default value    
.EXAMPLE 
    C:\foo> .\Get-AdvancedSettingsNotDefault.ps1 -delta:$false
    
    Description
    -----------
    Gets All settings from all hosts....
#> 

    param (
        [Parameter(
            Mandatory = $False,
            ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$Cluster,
        [Parameter(Mandatory = $False)]
        [boolean]$delta = $false
    )

    $AdvancedSettings = @()
    $Loopcount = 0
    $hostCounter = 0

    # Retrieving advanced settings
    foreach ($hostName in $($Cluster | Get-VMHost)) {  
        $hostCounter++ 
        $esxcli = $hostName | get-esxcli -V2
        $AdvancedSettings = $esxcli.system.settings.advanced.list.Invoke(@{delta = $delta}) |Select-Object @{Name = "Hostname"; Expression = {$hostName}}, Path, DefaultIntValue, IntValue, DefaultStringValue, StringValue, Description

        # Browsing advanced settings and check for mismatch
        ForEach ($advancedSetting in $AdvancedSettings.GetEnumerator()) {
            if ( ($AdvancedSetting.Path -notmatch $excludedSettings) -And (($AdvancedSetting.IntValue -ne $AdvancedSetting.DefaultIntValue) -Or ($AdvancedSetting.StringValue -notmatch $AdvancedSetting.DefaultStringValue) ) ) {
                $Loopcount++
                $line = New-Object psobject
                $line | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $advancedSetting.Hostname
                $line | Add-Member -MemberType NoteProperty -Name "Path" -Value $advancedSetting.Path
                $line | Add-Member -MemberType NoteProperty -Name "DefaultIntValue" -Value $advancedSetting.DefaultIntValue
                $line | Add-Member -MemberType NoteProperty -Name "IntValue" -Value $advancedSetting.IntValue
                $line | Add-Member -MemberType NoteProperty -Name "DefaultStringValue" -Value $advancedSetting.DefaultStringValue
                $line | Add-Member -MemberType NoteProperty -Name "StringValue" -Value $advancedSetting.StringValue
                $line | Add-Member -MemberType NoteProperty -Name "Description" -Value $advancedSetting.Description

                if ($Loopcount -eq "1") {
                    #count is only at 1 during the first run
                    [array]$AdvancedSettingsFilteredOneHost = New-Object PSObject $line
                }
                else {
                    #add to the existing object
                    [array]$AdvancedSettingsFilteredOneHost += $line
                }
            }
        }
        if ($hostCounter -eq "1") {
            #count is only at 1 during the first run
            [array]$AdvancedSettingsFilteredAllHosts = $AdvancedSettingsFilteredOneHost
        }
        else {
            #add to the existing object
            [array]$AdvancedSettingsFilteredAllHosts += $AdvancedSettingsFilteredOneHost
        }


    }
    $AdvancedSettingsFilteredAllHosts
}



$clusterCounter = 0
foreach ($cluster in $Clusters) {
    $clusterCounter++
    $report = getAllAdvancedSettingsESXi -Cluster $cluster -delta:$delta
    if ($clusterCounter -eq "1") {
        [array]$EndResult = $report
    } else {
        [array]$EndResult += $report
    }
}
$EndResult


# Change Log
## 1.1 : Added Get-vCheckSetting and changed from host object to cluster object
## 1.2 : Changed everthing to PSObjects
## 1.3 : added vCheck-Settings
## 1.4 : Plugin tested against 6.7 Update 1