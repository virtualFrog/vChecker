$Title = "[Network] Network Link and CRC errors"
$Comments = "Network Errors can cause all sorts of issues"
$Display = "Table"
$Author = "Dario Dörflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# Set max receive crc errors to tolerate.
$MaxReceiveCRCErrors = 1
# Set max transmit carrier errors to tolerate.
$MaxTransitCarrierErrors = 1
# Set max Receive errors to tolerate.
$MaxRxErrors = 1
# Set max Transmit errors to tolerate.
$MaxTxErrors = 1
# Set max Receive Missed errors to tolerate
$MaxRxMissedErrors = 1
# Set max Receive Over errors to tolerate
$MaxRxOverErrors = 1
# Set max Receive FIFO errors to tolerate
$MaxRxFIFOErros = 1
# End of Settings

# Update settings where there is an override
$MaxLinkFails = Get-vCheckSetting $Title "MaxLinkFails" $MaxLinkFails
$MaxCRCerrors = Get-vCheckSetting $Title "MaxCRCerrors" $MaxCRCerrors

$vsanNics = "vmnic2|vmnic5" 
$listWithErrors = @() 

foreach ($esxhost in ($HostsViews | Where-Object {$_.Runtime.ConnectionState -match "Connected|Maintenance"})) { 
        
    $esxcli = Get-Esxcli -V2 -VMHost $esxhost 
    Get-VMHostNetworkAdapter -VMHost $esxhost -Physical | Where-Object {$_.name -match $vsanNics } | Foreach-Object { 
        $nicstats = $esxcli.network.nic.stats.get.Invoke(@{nicname = $_.name }) 
        $properties = [ordered]@{ 
            'ESXHost'           = $esxhost.name; 
            'NIC'               = $_.name; 
            'Rx CRC Errors'     = $nicstats.ReceiveCRCerrors; 
            'Tx Carrier Errors' = $nicstats.Transmitcarriererrors; 
            'Rx Errors'         = $nicstats.Totalreceiveerrors; 
            'Tx Errors'         = $nicstats.Totaltransmiterrors; 
            'Rx Missed Errors'  = $nicstats.Receivemissederrors; 
            'Rx Over Errors'    = $nicstats.Receiveovererrors; 
            'Rx Fifo Errors'    = $nicstats.ReceiveFIFOerrors; 
                        
        } 
        if (($nicstats.ReceiveCRCerrors -gt $MaxReceiveCRCErrors) -or ($nicstats.Transmitcarriererrors -gt $MaxTransitCarrierErrors) -or ($nicstats.Totalreceiveerrors -gt $MaxRxErrors) -or ($nicstats.Totaltransmiterrors -gt $MaxTxErrors) -or ($nicstats.Receivemissederrors -gt $MaxRxMissedErrors) -or ($nicstats.Receiveovererrors -gt $MaxRxOverErrors) -or ($nicstats.ReceiveFIFOerrors -gt $MaxRxFIFOErros) ) { 
            $loopobject = New-Object PsObject -Property $properties 
            $listWithErrors += $loopobject 
        } 
                
    } 
} 
$listWithErrors
$Header = ("[Hosts] with more than {0} RX CRC or {1} Tx Carrier or {2} RX or {3} TX or {4} RxMissed or {5} Rx Over or {6} Rx FIFO errors: [count]" -f $MaxReceiveCRCErrors, $MaxTransitCarrierErrors, $MaxRxErrors, $MaxTxErrors, $MaxRxMissedErrors, $MaxRxOverErrors, $MaxRxFIFOErros)

<#
Incorporate more logic to to find the vSAN Enabled Uplinks used

$esxName = "MyEsx"

$esx = Get-VMHost -Name $esxName 
$dvsw = Get-VirtualSwitch -Distributed -VMHost $esx 
$vmk = Get-VMHostNetworkAdapter -DistributedSwitch $dvsw -VMKernel  |
  where {$_.VMHost.Name -eq $esx.Name}

$pgTab = @{}
Get-VirtualPortGroup -VMHost $esx -Distributed | %{
  $pgTab.Add($_.Name,$_)
}
Get-VMHostNetworkAdapter -DistributedSwitch $dvsw -VMKernel | 
where {$_.VMHost.Name -like $esxName} | 
Select @{N="VMHost";E={$_.VMHost.Name}},Name,PortgroupName,IP,SubnetMask, 
@{N="vNIC";E={
  $pg = $pgTab[$_.PortgroupName]
  $member = $pg.VirtualSwitch.ExtensionData.Config.Host |
    where {$_.Config.Host -eq $esx.ExtensionData.MoRef}
  [string]::Join(',',($member.Config.Backing.PnicSpec | Select -ExpandProperty PnicDevice))
}}

#>