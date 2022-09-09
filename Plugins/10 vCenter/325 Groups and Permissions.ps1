# Start of Settings
# i.e. $BlacklistGroup = "Administrators","VMUsers"
$BlacklistGroup = ""
# i.e. BlacklistDomain = "VSPHERE.LOCAL"
$BlacklistDomain = ""
# i.e. $BlacklistRole = "Admin"
$BlacklistRole = ""
# i.e. $BlacklistObject = "Datacenters"
$BlacklistObject = ""
# End of Settings

Get-VIPermission | Select-Object Principal, Role, Propagate, IsGroup, Entity | Where-Object {$_.IsGroup -match "True"} | Select-Object @{N="Group";E={($_.Principal.split("\"))[1]}}, @{N="Domain";E={($_.Principal.split("\"))[0]}}, Role,  @{N="Propagate to Child";E={($_.Propagate)}}, @{N="Object";E={($_.Entity)}} -unique | Where-Object {$_.Group -notin $BlacklistGroup -and $_.Domain -notin $BlacklistDomain -and $_.Role -notin $BlacklistRole -and $_.Object -notin $BlacklistObject} | Sort-Object Group

$Title = "[vCenter] Groups and Permissions"
$Header = "[vCenter] Groups and Permissions"
$Display = "Table"
$Author = "Felix Longardt, Dario Doerflinger"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
$Comments = ("The plugin gives an overview of configured user groups")

# Change Log
# 1.0 - Initiale Version
# 1.1 - add unique to work with multiple vcenters inside the same sso-domain
# 1.2 - fixed plugin structure and replaced aliases