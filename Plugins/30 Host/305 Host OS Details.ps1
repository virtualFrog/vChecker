$Title = "[Hosts] Version"
$Header = "[Hosts] Build details"
$Comments = "Details about all hosts per cluster"
$Display = "Table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.0
$PluginCategory = "vSphere"

# Start of Settings 
# End of Settings 

Function Get-ESXiVersion {
   <#
       .NOTES
       ===========================================================================
        Created by:    William Lam, Dario Doerflinger
        ===========================================================================
       .DESCRIPTION
           This function extracts the ESXi build from your env and maps it to
           https://kb.vmware.com/kb/2143832 to extract the version and release date
       .PARAMETER ClusterName
           Name of the vSphere Cluster to retrieve ESXi version information
       .EXAMPLE
           Get-ESXiVersion -ClusterName VSAN-Cluster
   #>
       param(
           [Parameter(Mandatory=$true)][String]$ClusterName
       )

       # Pulled from https://kb.vmware.com/kb/2143832
       $esxiBuildVersionMappings = @{
           "10764712"="ESXi 6.7 EP 05,2018-11-09"
           "10302608"="ESXi 6.7 U1,2018-10-16"
           "10176752"="ESXi 6.7 EP 04,2018-10-02"
           "9484548"="ESXi 6.7 EP 03,2018-08-14"
           "9214924"="ESXi 6.7 EP 02a,2018-07-26"
           "8941472"="ESXi 6.7 EP 02,2018-06-28"
           "8169922"="ESXi 6.7 GA,2018-04-17"
           "10884925"="ESXi 6.5 P03,2018-11-29"
           "10719125"="ESXi 6.5 EP 11,2018-11-09"
           "10390116"="ESXi 6.5 EP 10,2018-10-23"
           "10175896"="ESXi 6.5 EP 09,2018-10-02"
           "9298722"="ESXi 6.5 U2C,2018-08-14"
           "8935087"="ESXi 6.5 U2b,2018-06-28"
           "8294253"="ESXi 6.5 U2 GA,2018-05-03"
           "7967591"="ESXi 6.5 U1g,2018-03-20"
           "7388607"="ESXi 6.5 Patch 02,2017-12-19"
           "6765664"="ESXi 6.5 U1 Express Patch 4,2017-10-05"
           "5969303"="ESXi 6.5 U1,2017-07-27"
           "5310538"="ESXi 6.5.0d,2017-04-18"
           "5224529"="ESXi 6.5 Express Patch 1a,2017-03-28"
           "5146846"="ESXi 6.5 Patch 01,2017-03-09"
           "4887370"="ESXi 6.5.0a,2017-02-02"
           "4564106"="ESXi 6.5 GA,2016-11-15"
           "10719132"="ESXi 6.0 EP 19,2018-11-09"
           "10474991"="ESXi 6.0 EP 18,2018-10-23"
           "9919195"="ESXi 6.0 EP 15,2018-09-13"
           "9313334"="ESXi 6.0 EP 15,2818-08-14"
           "9239799"="ESXi 6.0 P07,2018-07-26"
           "8934903"="ESXi 6.0 U3f,2018-06-28"
           "7967664"="ESXi 6.0 U3e,2018-03-20"
           "7504637"="ESXi 6.0 U3d,2018-01-09"
           "6921384"="ESXi 6.0 Patch 6,2017-11-09"
           "6765062"="ESXi 6.0 Express Patch 11,2017-10-05"
           "5572656"="ESXi 6.0 Patch 5,2017-06-06"
           "5251623"="ESXi 6.0 Express Patch 7c,2017-03-28"
           "5224934"="ESXi 6.0 Express Patch 7a,2017-03-28"
           "5050593"="ESXi 6.0 Update 3,2017-02-24"
           "4600944"="ESXi 6.0 Patch 4,2016-11-22"
           "4510822"="ESXi 6.0 Express Patch 7,2016-10-17"
           "4192238"="ESXi 6.0 Patch 3,2016-08-04"
           "3825889"="ESXi 6.0 Express Patch 6,2016-05-12"
           "3620759"="ESXi 6.0 Update 2,2016-03-16"
           "3568940"="ESXi 6.0 Express Patch 5,2016-02-23"
           "3380124"="ESXi 6.0 Update 1b,2016-01-07"
           "3247720"="ESXi 6.0 Express Patch 4,2015-11-25"
           "3073146"="ESXi 6.0 U1a Express Patch 3,2015-10-06"
           "3029758"="ESXi 6.0 U1,2015-09-10"
           "2809209"="ESXi 6.0.0b,2015-07-07"
           "2715440"="ESXi 6.0 Express Patch 2,2015-05-14"
           "2615704"="ESXi 6.0 Express Patch 1,2015-04-09"
           "2494585"="ESXi 6.0 GA,2015-03-12"
           "5230635"="ESXi 5.5 Express Patch 11,2017-03-28"
           "4722766"="ESXi 5.5 Patch 10,2016-12-20"
           "4345813"="ESXi 5.5 Patch 9,2016-09-15"
           "4179633"="ESXi 5.5 Patch 8,2016-08-04"
           "3568722"="ESXi 5.5 Express Patch 10,2016-02-22"
           "3343343"="ESXi 5.5 Express Patch 9,2016-01-04"
           "3248547"="ESXi 5.5 Update 3b,2015-12-08"
           "3116895"="ESXi 5.5 Update 3a,2015-10-06"
           "3029944"="ESXi 5.5 Update 3,2015-09-16"
           "2718055"="ESXi 5.5 Patch 5,2015-05-08"
           "2638301"="ESXi 5.5 Express Patch 7,2015-04-07"
           "2456374"="ESXi 5.5 Express Patch 6,2015-02-05"
           "2403361"="ESXi 5.5 Patch 4,2015-01-27"
           "2302651"="ESXi 5.5 Express Patch 5,2014-12-02"
           "2143827"="ESXi 5.5 Patch 3,2014-10-15"
           "2068190"="ESXi 5.5 Update 2,2014-09-09"
           "1892794"="ESXi 5.5 Patch 2,2014-07-01"
           "1881737"="ESXi 5.5 Express Patch 4,2014-06-11"
           "1746018"="ESXi 5.5 Update 1a,2014-04-19"
           "1746974"="ESXi 5.5 Express Patch 3,2014-04-19"
           "1623387"="ESXi 5.5 Update 1,2014-03-11"
           "1474528"="ESXi 5.5 Patch 1,2013-12-22"
           "1331820"="ESXi 5.5 GA,2013-09-22"
           "3872664"="ESXi 5.1 Patch 9,2016-05-24"
           "3070626"="ESXi 5.1 Patch 8,2015-10-01"
           "2583090"="ESXi 5.1 Patch 7,2015-03-26"
           "2323236"="ESXi 5.1 Update 3,2014-12-04"
           "2191751"="ESXi 5.1 Patch 6,2014-10-30"
           "2000251"="ESXi 5.1 Patch 5,2014-07-31"
           "1900470"="ESXi 5.1 Express Patch 5,2014-06-17"
           "1743533"="ESXi 5.1 Patch 4,2014-04-29"
           "1612806"="ESXi 5.1 Express Patch 4,2014-02-27"
           "1483097"="ESXi 5.1 Update 2,2014-01-16"
           "1312873"="ESXi 5.1 Patch 3,2013-10-17"
           "1157734"="ESXi 5.1 Patch 2,2013-07-25"
           "1117900"="ESXi 5.1 Express Patch 3,2013-05-23"
           "1065491"="ESXi 5.1 Update 1,2013-04-25"
           "1021289"="ESXi 5.1 Express Patch 2,2013-03-07"
           "914609"="ESXi 5.1 Patch 1,2012-12-20"
           "838463"="ESXi 5.1.0a,2012-10-25"
           "799733"="ESXi 5.1.0 GA,2012-09-10"
           "3982828"="ESXi 5.0 Patch 13,2016-06-14"
           "3086167"="ESXi 5.0 Patch 12,2015-10-01"
           "2509828"="ESXi 5.0 Patch 11,2015-02-24"
           "2312428"="ESXi 5.0 Patch 10,2014-12-04"
           "2000308"="ESXi 5.0 Patch 9,2014-08-28"
           "1918656"="ESXi 5.0 Express Patch 6,2014-07-01"
           "1851670"="ESXi 5.0 Patch 8,2014-05-29"
           "1489271"="ESXi 5.0 Patch 7,2014-01-23"
           "1311175"="ESXi 5.0 Update 3,2013-10-17"
           "1254542"="ESXi 5.0 Patch 6,2013-08-29"
           "1117897"="ESXi 5.0 Express Patch 5,2013-05-15"
           "1024429"="ESXi 5.0 Patch 5,2013-03-28"
           "914586"="ESXi 5.0 Update 2,2012-12-20"
           "821926"="ESXi 5.0 Patch 4,2012-09-27"
           "768111"="ESXi 5.0 Patch 3,2012-07-12"
           "721882"="ESXi 5.0 Express Patch 4,2012-06-14"
           "702118"="ESXi 5.0 Express Patch 3,2012-05-03"
           "653509"="ESXi 5.0 Express Patch 2,2012-04-12"
           "623860"="ESXi 5.0 Update 1,2012-03-15"
           "515841"="ESXi 5.0 Patch 2,2011-12-15"
           "504890"="ESXi 5.0 Express Patch 1,2011-11-03"
           "474610"="ESXi 5.0 Patch 1,2011-09-13"
           "469512"="ESXi 5.0 GA,2011-08-24"
       }
   
       $cluster = Get-Cluster -Name $ClusterName -ErrorAction SilentlyContinue
       if($null -eq $cluster) {
           Write-Host -ForegroundColor Red "Error: Unable to find Cluster $ClusterName ..."
           break
       }
   
       $results = @()
       foreach ($vmhost in $cluster.ExtensionData.Host) {
           $vmhost_view = Get-View $vmhost -Property Name, Config, ConfigManager.ImageConfigManager
   
           $esxiName = $vmhost_view.name
           $esxiBuild = $vmhost_view.Config.Product.Build
           $esxiVersionNumber = $vmhost_view.Config.Product.Version
           $esxiVersion,$esxiRelDate,$esxiOrigInstallDate = "Unknown","Unknown","N/A"
   
           if($esxiBuildVersionMappings.ContainsKey($esxiBuild)) {
               ($esxiVersion,$esxiRelDate) = $esxiBuildVersionMappings[$esxiBuild].split(",")
           }
   
           # Install Date API was only added in 6.5
           if( ($esxiVersionNumber -eq "6.5.0") -or ($esxiVersionNumber -eq "6.7.0") ) {
               $imageMgr = Get-View $vmhost_view.ConfigManager.ImageConfigManager
               $esxiOrigInstallDate = $imageMgr.installDate()
           }
   
           $tmp = [pscustomobject] @{
               Name = $esxiName;
               Cluster = $ClusterName;
               Build = $esxiBuild;
               Version = $esxiVersion;
               ReleaseDate = $esxiRelDate;
               OriginalInstallDate = $esxiOrigInstallDate;
           }
           $results+=$tmp
       }
       $results | sort-object Name
   }

   foreach ($clusterInstance in $Clusters) {
    Get-ESXiVersion $clusterInstance
   }
