# Start of Settings
# End of Settings

# For maintenance please consult https://code.vmware.com/apis/366/vsphere-automation

Function Get-VAMINetwork {
    <#
    .NOTES
    ===========================================================================
     Created by:    William Lam, Dario Doerflinger
	===========================================================================
    .SYNOPSIS
        This function retrieves network information from VAMI interface (5480)
        for a VCSA node which can be an Embedded VCSA, External PSC or External VCSA.
    .DESCRIPTION
        Function to return networking information including details for each interface
    .EXAMPLE
        Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
        Get-VAMINetwork
#>
    $netResults = @()

    $Hostname = (Get-CisService -Name 'com.vmware.appliance.networking.dns.hostname').get()
    $dns = (Get-CisService -Name 'com.vmware.appliance.networking.dns.servers').get()

    #Write-Host "Hostname: " $hostname
    #Write-Host "DNS Servers: " $dns.servers

    $interfaces = (Get-CisService -Name 'com.vmware.appliance.networking.interfaces').list()
    foreach ($interface in $interfaces) {
        if ($global:DefaultVIServer.Version -eq "6.7.0") {
            #$ipv4result = (Get-CisService -Name "com.vmware.appliance.networking.interfaces.$($interface.name).ipv4").get()

            $interfaceResult = [pscustomobject] @{
                Hostname      = $Hostname;
                "DNS Servers" = [string]::join("<br/>",$dns.servers.split(" "));
                Interface     = $interface.name;
                MAC           = $interface.mac;
                Status        = $interface.status;
                Mode          = $interface.ipv4.mode;
                IP            = $interface.ipv4.address;
                Prefix        = $interface.ipv4.prefix;
                Gateway       = $interface.ipv4.default_gateway;
                Configurable  = $interface.ipv4.configurable
            }

        }
        elseif ($global:DefaultVIServer.Version -eq "6.5.0") {
            $ipv4API = (Get-CisService -Name 'com.vmware.appliance.techpreview.networking.ipv4')
            $spec = $ipv4API.Help.get.interfaces.CreateExample()
            $spec += $interface.name
            $ipv4result = $ipv4API.get($spec)

            $interfaceResult = [pscustomobject] @{
                Hostname      = $Hostname;
                "DNS Servers" = [string]::join("<br/>",$dns.servers.split(" "));
                Interface     = $interface.name;
                MAC           = $interface.mac;
                Status        = $interface.status;
                Mode          = $ipv4result.mode;
                IP            = $ipv4result.address;
                Prefix        = $ipv4result.prefix;
                Gateway       = $ipv4result.default_gateway;
                Updateable    = $ipv4result.updateable
            }
        }
        else {
            #nothing to do here
            $failure = "VCSA version $($global:DefaultVIServer.Version) has not been implemented in this plugin."
            $failure
            exit
        }



        $netResults += $interfaceResult
    }
    $netResults
}

if ($VCSA) {
    Get-VAMINetwork 
 
    Add-ReportResource -cid "red" -Type "base64" -ResourceData "png|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"
    Add-ReportResource -cid "green" -Type "base64" -ResourceData "png|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"
    Add-ReportResource -cid "gray" -Type "base64" -ResourceData "png|iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADknpUWHRSYXcgcHJvZmlsZSB0eXBlIGV4aWYAAHja7ZZdkvMoDEXfWcUsAQkEYjmYn6pvB7P8uWDibiftdCfTL1M1pmJhGSTQEXJM+/tPN3/hoiTeeIkaUggWl08+cUZH7X7tkqyf9/Vgb52T3hwvGCoH6fbH0Nb4DL18TIh+6bez3sSy7OgyRIfhebnhefTXOF2GHO96Ws8mrXnZf9rO+nFZZpfx+2cfEYwqsOfYcHPkLO46vDiswCWXp8z4KY/e3h93cfp17MzRvQve0buLnc1L786hMDasAeEuRktPcqd3hxu+p3bzfHqh2+HiIXa9V+297bvLPiBSwaxN3bYyexi4IZRuTgtoET9BP86W0BRbLCBWQXNDK4YSMaLdyVOlTJ3alIUKlui5cYRkLuymTl3kxGXC8KNR5wg81TgFqwJqDmo+1kLTb5r+Cik8V8JIJhgjzHho5ivlO+0w1PtIXSKrR6ywLh45jWUMcuOOUQBCfcVUZnxnM5/yxn4C60BQZpgVG8x2201sQh+55SZnh3FivbH70aBYlwGECL4Fi0Eue7KBnFAgG5kjEeKo4JOxcnaeNxAgEa5kOtg4FwAHpwG+MSfSHMvCuxqlBSDEBReBBgcIsLwX5E/0ihzK4lCPRCRIFJUkObjgg4QQYhg1KkcXfZQYYowaU8zq1Kto0KiqSXPi5FDCJIUUTdKUUs5wmmE6Y3bGiJw33tzmN9nCFjfd0pYL0qf4IiWUWLSkkitXV3H8a6jRVK2p5kYNqdR8kxZabNpSyx251l33XXrosWtPPR/UFtUzNboj95waLWqDmJ/j4gc1qGO8maBRTmQwAzH2BOJxEEBC82BmlbznQW4ws4lxKIRBjWTAqTSIgaBvxNLpYPdB7ik3I/4lbnxFzgx0v0HODHSL3CO3L6jVPL8obgIap3DE1LqOwtZs08xYAuoxj96DpM0LIQTWDjE+QI/SXL3YZZum8KmaFrO9lmZ1/JyRtNw6+u3UszSXA+JclSD35r7sg+S17N234az+augr0nz1wuWL6D+JuqHn0f6xNFeYQp0h8j/dn7G/EaD/mKGgdcWtX5yckzSfFHx00uvw9rNG3fvln2p+KwXMh4Ja3Na2ovKL1vCB9Lc5VEt9Py3Nv17LkuYXTsf/hr6Ve8Ewb1SMn1fIK/mscppvP1hvVsiXP2i3uPxiPbrc+Hfy/Ekx7wM/79ucNtzxbwNLM/8AfllUihXGr5QAAAAGYktHRAD/AP8A/6C9p5MAAAAJcEhZcwAALiMAAC4jAXilP3YAAAAHdElNRQfjARIKCzqzG/CHAAABRElEQVQ4y53TsWpUURSF4W/vO6CmSsQyQriNLzCFlcSYwrdQg4XaC6YRNUQMVrZqMSA+gKWgI2KRB7CztbBREAYkw+A5Nnd0ConOXeWC9e+z9+LE9vZmg0RB1pItruIizuEnPuEtnkaWL6gI1KZtNwYoajS15h5e4gLWcRIrONt5N9TIiPphDunCmlrjFS47Xqdwr5Zcjyw3URNRa97/j/CirteSdxDznW9bXru15JnENTQ9ACvYGXTX/q3VtbU6aJr4W2I6nZbJZJIL1uagqwo8Ojj4PhwOV4+ZmuPxuD7c358POD3vH8xmsxNLrhFxaWvrEOf10+vEWH+9SzzHtEf4B0YZWT7jcQ/A3cjyLVEjywO8WCL8LLI80f3C6CA72MPRP569G1luzY2mbTfyTyf1vRojTDr4Eb7iI0a4ElneLBJ/ATbiYwT6chrTAAAAAElFTkSuQmCC"
    #Add-ReportResource -cid "yellow" -Type "base64" -ResourceData "png|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"
    #Add-ReportResource -cid "orange" -Type "base64" -ResourceData "png|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"
    
    $TableFormat =	@{"Status" = @(@{ "-eq `"down`"" = "Cell,cid|red|16x16"; }, @{"-eq `"up`"" = "Cell,cid|green|16x16"; })}
    $TableFormat +=	@{"Configurable" = @(@{ "-eq `$true" = "Cell,cid|green|16x16"; }, @{"-eq `$false" = "Cell,cid|gray|16x16"; })}
    $TableFormat +=	@{"Updateable" = @(@{ "-eq `$true" = "Cell,cid|green|16x16"; }, @{"-eq `$false" = "Cell,cid|gray|16x16"; })}
}

$Title = "[vCenter] VCSA Network"
$Header = "[vCenter] VCSA Network settings"
$Comments = "Shows the VCSA's Network settings. Green = Up; Red = Down"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"
