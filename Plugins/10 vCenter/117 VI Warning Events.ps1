$Title = "[vCenter] Warning Events"
$Comments = "The following warnings were logged in the vCenter Events tab, you may wish to investigate these"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# Set the number of days of VC Events to check for warnings
$VCEventAge = 90
# End of Settings

Get-VIEventPlus -Start ($Date).AddDays(-$VCEventAge ) -EventType Warning | Select-Object @{N="Host";E={$_.host.name}}, createdTime, @{N="User";E={($_.userName.split("\"))[1]}}, fullFormattedMessage

$Header = ("[vCenter] Warning Events (Last {0} Day(s)): [count]" -f $VCEventAge)