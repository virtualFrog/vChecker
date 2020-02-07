# Start of Settings
# End of Settings

Function Get-VAMIStorageUsed {
    <#
    .NOTES
    ===========================================================================
     Created by:    Dario Doerflinger
     Organization:  BUSINESS IT AG
     Blog:          virtualfrog.wordpress.com
     Twitter:       @virtual_frog
	===========================================================================
    .SYNOPSIS
        This function retrieves the individaul OS partition storage utilization
        for a VCSA node which can be an Embedded VCSA, External PSC or External VCSA.
    .DESCRIPTION
        Function to return individual OS partition storage utilization
    .EXAMPLE
        Connect-CisServer -Server 192.168.1.100 -User administrator@vsphere.local -Password VMware1!
        Get-VAMIStorageUsed
#>
    $monitoringAPI = Get-CisService 'com.vmware.appliance.monitoring'
    $querySpec = $monitoringAPI.help.query.item.Create()

    #get current filesystems (subject to change in releases) via API
    $ids = $monitoringAPI.list() | Select-Object id | Sort-Object -Property id
    $querySpec.Names = @()
    foreach ($id in $ids) {
        #get the filesytems for used and total
        $querySpec.Names += $id | Where-Object {($_ -match "filesystem|used") -and ($_ -notmatch "storage.util")} |Select-Object -ExpandProperty id
    }

    $querySpec.interval = "DAY1"
    $querySpec.function = "MAX"
    $querySpec.start_time = ((get-date).AddDays(-1))
    $querySpec.end_time = (Get-Date)
    $queryResults = $monitoringAPI.query($querySpec) | Select-Object * -ExcludeProperty Help

    #build the dictionary object for the output dynamically
    $myFilesystems = @{}

    foreach ($queryResult in $queryResults) {
        $filesystemName = [string]($queryResult.name.toString()).split(".")[-1]

        if ($null -eq $myFilesystems[$filesystemName]) {
            #does not exist yet
            #create path (some exceptions to the default of /storage/{name})
            switch ($filesystemName) {
                "root" { $path = "/"; break }
                "boot" { $path = "/boot"; break}
                "archive" { $path = "/archive"; break}
                Default { $path = "/storage/$($filesystemName)"; break }
            }
            $myFilesystems[$filesystemName] = @{"name" = $path; "used" = 0; "total" = 0}
        }
        #get the value from the query result
        try {
            $value = [Math]::Round([int]($queryResult.data[1]).toString() / 1MB, 2)
        }
        catch {
            Write-Host "Seems to be a divsion by zero.."
            $value = "N/A"
        }
        

        #populate value to correct property
        if ($queryResult.name -match "used") {
            $myFilesystems[$filesystemName]["used"] = $value
        }
        else {
            $myFilesystems[$filesystemName]["total"] = $value
        }     
    }

    $storageResults = @()
    foreach ($key in $myFilesystems.keys | Sort-Object -Property name) {
        $usage = [Math]::Round([int](100 / $myFilesystems[$key].total * $myFilesystems[$key].used), 2)
        $statResult = [pscustomobject] @{
            "Filesystem" = $myFilesystems[$key].name;
            "Total"      = [string]$myFilesystems[$key].total + " GB";
            "Used"       = [string]$myFilesystems[$key].used + " GB";
            "Usage %"      = $usage
        }
        $storageResults += $statResult
    }
    $storageResults = $storageResults | Sort-Object -Property Filesystem
    $storageResults
}

if ($VCSA) {
    Get-VAMIStorageUsed

    #format the table according to the % of the usage (and keep it aligned left)
    $TableFormat = @{"Usage %" = @(@{ "-ge 75" = "Cell,style|color:yellow;font-weight:bold";},
                                 @{ "-ge 90" = "Cell,style|color:red;font-weight:bold"; },
                                 @{ "-ge 75" = "Row,class|left";},
                                 @{ "-ge 90" = "Row,class|left"})
    }
}


$Title = "[vCenter] VCSA Storage"
$Header = "[vCenter] VCSA Storage Usage"
$Comments = "Lists all available mountpoints and their current storage usage on the vCenter server appliance"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Change log
## 1.0 : initial release based on William Lam's API examples
## 1.1 : complete rewrite to get filesystems dynamically
## 1.2 : division by zero detection 