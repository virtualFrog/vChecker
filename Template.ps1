# Start of Settings
# Comment about setting that shows in the config wizard
$thisIsASetting = "Hello World"
# End of Settings

# Get Settings again from global
$thisIsASetting = Get-vCheckSetting $Title "thisIsASetting" $thisIsASetting

# generate your report content here. Simple placeholder hashtable for the sake of example
@{"Plugin"="Awesome"}

$Title = "Plugin Template"
$Header =  "Plugin Template"
$Comments = "Comment about this awesome plugin"
$Display = "List"
$Author = "Plugin Author"
$PluginVersion = 1.0
$PluginCategory = "vSphere"


# Change Log
## 1.0 : Hello world