# Start of Settings
# End of Settings

Function Get-VAMIBackupSize {
    <#
    .NOTES
    ===========================================================================
     Created by:    William Lam, Dario Doerflinger
	===========================================================================
	.SYNOPSIS
		This function retrieves the backup size of the VCSA from VAMI interface (5480)
        for a VCSA node which can be an Embedded VCSA, External PSC or External VCSA.
	.DESCRIPTION
		Function to return the current backup size of the VCSA (common and core data)
	.EXAMPLE
        Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
        Get-VAMIBackupSize
#>
    $recoveryAPI = Get-CisService 'com.vmware.appliance.recovery.backup.parts'
    $backupParts = $recoveryAPI.list() | Select-Object id
    $counter = 0
    $estimateBackupSize = 0
    #$backupPartSizes = ""
    $backupReport = @()
    foreach ($backupPart in $backupParts) {
        Write-Progress -Activity "Collecting backup information" -Status ("Part: {0}" -f $backupPart.id.value) -PercentComplete ((100 * $counter) / $backupParts.Length) -Id 2  -ParentId 1
        $partId = $backupPart.id.value
        $partSize = $recoveryAPI.get($partId)
        $estimateBackupSize += $partSize
        #$backupPartSizes += $partId + " data is " + $partSize + " MB`n"

        $backupReportChunk = New-Object psobject
        $backupReportChunk | Add-Member -MemberType NoteProperty -Name "Backup Part" -Value $partId
        $backupReportChunk | Add-Member -MemberType NoteProperty -Name "Backup Part Size " -Value "$($partSize) MB"

        $backupReport += $backupReportChunk
        $counter++
    }
    Write-Progress -ID 2 -Parent 1 -Activity "Collecting backup information" -Status $lang.Complete -Completed
    $backupReportChunk = New-Object psobject
    $backupReportChunk | Add-Member -MemberType NoteProperty -Name "Backup Part" -Value "Total Size"
    $backupReportChunk | Add-Member -MemberType NoteProperty -Name "Backup Part Size " -Value "$($estimateBackupSize) MB"

    $backupReport += $backupReportChunk
    $backupReport
}

if ($VCSA) {
    Get-VAMIBackupSize 
}

$Title = "[vCenter] VCSA Backup"
$Header = "[vCenter] VCSA Backup size calculator"
$Comments = "Get an estimate of the backup size from the appliance API"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
