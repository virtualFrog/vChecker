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
            "20328353"="ESXi 7.0 Update 3g,2022-09-01"
            "20036589"="ESXi 7.0 Update 3f,2022-07-12"
            "19898904"="ESXi 7.0 Update 3e,2022-06-14"
            "19482537"="ESXi 7.0 Update 3d,2022-03-29"
            "19193900"="ESXi 7.0 Update 3c,2022-01-27"
            "18905247"="ESXi 7.0 Update 3b,2021-11-12"
            "18825058"="ESXi 7.0 Update 3a,2021-10-28"
            "18644231"="ESXi 7.0 Update 3,2021-10-05"
            "19290878"="ESXi 7.0 Update 2e,2022-02-15"
            "18538813"="ESXi 7.0 Update 2d,2021-09-14"
            "18426014"="ESXi 7.0 Update 2c,2021-08-24"
            "17867351"="ESXi 7.0 Update 2a,2021-04-29"
            "17630552"="ESXi 7.0 Update 2,2021-03-09"
            "19324898"="ESXi 7.0 Update 1e,2022-02-15"
            "17551050"="ESXi 7.0 Update 1d,2021-02-02"
            "17325551"="ESXi 7.0 Update 1c,2020-12-17"
            "17325020"="ESXi 7.0 Update 1c (security only),2020-12-17"
            "17168206"="ESXi 7.0 Update 1b,2020-11-19"
            "17119627"="ESXi 7.0 Update 1a,2020-11-04"
            "16850804"="ESXi 7.0 Update 1,2020-10-06"
            "16324942"="ESXi 7.0b,2020-06-23"
            "15843807"="ESXi 7.0 GA,2020-04-02"
            "19997733"="ESXi 6.7 EP24,2022-07-12"
            "19898906"="ESXi 6.7 P07,2022-06-14"
            "19195723"="ESXi 6.7 EP 23,2022-01-25"
            "18828794"="ESXi 6.7 P07,2021-11-23"
            "17700523"="ESXi 6.7 P05,2021-03-18"
            "17499825"="ESXi 6.7 EP 18,2021-02-23"
            "17167734"="ESXi 6.7 P04,2020-11-19"
            "17098360"="ESXi 6.7 EP 17,2020-11-04"
            "16773714"="ESXi 6.7 EP 16,2020-10-15"
            "16713306"="ESXi 6.7 P03,2020-08-20"
            "16316930"="ESXi 6.7 EP 15,2020-06-09"
            "16075168"="ESXi 6.7 P02,2020-04-28"
            "15820472"="ESXi 6.7 EP 14,2020-04-07"
            "15160138"="ESXi 6.7 P01,2019-12-05"
            "15018017"="ESXi 6.7 EP 13,2019-11-12"
            "14320388"="ESXi 6.7 U3,2019-08-20"
            "13981272"="ESXi 6.7 EP 10,2019-06-20"
            "13644319"="ESXi 6.7 EP 09,2019-05-14"
            "13473784"="ESXi 6.7 EP 08,2019-04-30"
            "13006603"="ESXi 6.7 U2,2019-04-11"
            "13004448"="ESXi 6.7 EP 07,2019-03-28"
            "11675023"="ESXi 6.7 EP 06,2019-01-17"
            "10764712"="ESXi 6.7 EP 05,2018-11-09"
            "10302608"="ESXi 6.7 U1,2018-10-16"
            "10176752"="ESXi 6.7 EP 04,2018-10-02"
            "9484548"="ESXi 6.7 EP 03,2018-08-14"
            "9214924"="ESXi 6.7 EP 02a,2018-07-26"
            "8941472"="ESXi 6.7 EP 02,2018-06-28"
            "8169922"="ESXi 6.7 GA,2018-04-17"
            "19997716"="ESXi 6.5 EP 27,2022-07-12"
            "19588618"="ESXi 6.5 P08,2022-05-12"
            "19092475"="ESXi 6.5 EP 26,2022-02-15"
            "18678235"="ESXi 6.5 P07,2021-12-12"
            "18071574"="ESXi 6.5 EP 24,2021-07-13"
            "17477841"="ESXi 6.5 P06,2021-02-23"
            "17167537"="ESXi 6.5 EP 23,2020-11-19"
            "17097218"="ESXi 6.5 EP 22,2020-11-04"
            "16901156"="ESXi 6.5 EP 21,2020-10-15"
            "16576891"="ESXi 6.5 P05,2020-07-30"
            "16389870"="ESXi 6.5 EP 20,2020-06-30"
            "16207673"="ESXi 6.5 EP 19,2020-05-28"
            "15256549"="ESXi 6.5 P04,2019-12-19"
            "15177306"="ESXi 6.5 EP 18,2019-12-05"
            "14990892"="ESXi 6.5 EP 17,2019-11-12"
            "14874964"="ESXi 6.5 EP 16,2019-10-24"
            "14320405"="ESXi 6.5 EP 15,2019-08-20"
            "13932383"="ESXi 6.5 U3,2019-07-02"
            "13635690"="ESXi 6.5 EP 14,2019-05-14"
            "13004031"="ESXi 6.5 EP 13,2019-03-28"
            "11925212"="ESXi 6.5 EP 12,2019-01-31"
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
            "15517548"="ESXi 6.0 EP 25,2020-02-20"
            "15169789"="ESXi 6.0 EP 23,2019-12-05"
            "14513180"="ESXi 6.0 P08,2019-09-12"
            "15018929"="ESXi 6.0 EP 22,2019-11-12"
            "13635687"="ESXi 6.0 EP 21,2019-05-14"
            "13003896"="ESXi 6.0 EP 20,2019-03-28"
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
            "9919047"="ESXi 5.5 U3k,2018-09-14"
            "9313066"="ESXi 5.5 U3J,2018-08-14"
            "8934887"="ESXi 5.5 U3i,2018-06-28"
            "7967571"="ESXi 5.5 U3h,2018-03-20"
            "7618464"="ESXi 5.5 EP 13,2018-01-22"
            "6480324"="ESXi 5.5 U3f,2017-09-14"
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
 
 $Title = "[Hosts] Version"
 $Header = "[Hosts] Build details"
 $Comments = "Details about all hosts per cluster"
 $Display = "Table"
 $Author = "Dario Doerflinger"
 $PluginVersion = 1.3
 $PluginCategory = "vSphere"
 
 #Changelog
 # 1.1 Updated Releases to July 9th 2019
 # 1.2 Updated releases to december 2020
 # 1.3 Updated released to September 2022