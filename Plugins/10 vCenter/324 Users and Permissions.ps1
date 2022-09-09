# Start of Settings
# i.e. $BlacklistUser = "vpxd-2222922f-222d-2222-222c","vpxd-extension-2522222f-222d-4222-b222","vsphere-webclient-uzitrz8t"
$BlacklistUser = "vsphere-webclient-2571922f-2b1d-sdfsad2-bc1c-e125dba3a11d","vpxd-extension-2571asdfdf2b1d-4402-bc1c-e125dba3a11d","vpxd-2571922f-2b1dfasdf02-bc1c-e125dba3a11d","vpxd-46sdfsadfasd6f608ff-cb37-4d8a-ac3a-68754da88231","vpxd-extension-46660adsf8ff-cb37-4d8a-ac3a-6sdf8754da88231"
# i.e. BlacklistDomain = "VSPHERE.LOCAL"
$BlacklistDomain = ""
# i.e. $BlacklistRole = "Admin"
$BlacklistRole = ""
# i.e. $BlacklistObject = "Datacenters"
$BlacklistObject = ""
# End of Settings


Get-VIPermission | Select-Object Principal, Role, Propagate, IsGroup, Entity | Where-Object {$_.IsGroup -match "False"} | Select-Object @{N="User";E={($_.Principal.split("\"))[1]}}, @{N="Domain";E={($_.Principal.split("\"))[0]}}, Role,  @{N="Propagate to Child";E={($_.Propagate)}}, @{N="Object";E={($_.Entity)}} -unique | Where-Object {$_.User -notin $BlacklistUser -and $_.Domain -notin $BlacklistDomain -and $_.Role -notin $BlacklistRole -and $_.Object -notin $BlacklistObject} | Sort-Object User 


$Title = "[vCenter] users and permissions"
$Header = "[vCenter] users and permissions"
$Display = "Table"
$Author = "Felix Longardt, Dario Doerflinger"
$PluginVersion = 1.2
$PluginCategory = "vSphere"
$Comments = ("The following gives an overview of the configured users")

# Change Log
# 1.0 - initial version
# 1.1 - add unique to work with multiple vcenters inside the same sso-domain
# 1.2 - fixed plugin structure, replaced alias commands