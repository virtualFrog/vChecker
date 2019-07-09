# Start of Settings
# End of Settings

Function Get-VCVersion {
    <#
        .NOTES
        ===========================================================================
         Created by:    William Lam, Dario Doerflinger, Alex Lopez
        ===========================================================================
        .DESCRIPTION
            This function extracts the vCenter Server (Windows or VCSA) build from your env
            and maps it to https://kb.vmware.com/kb/2143838 to retrieve the version and release date
        .EXAMPLE
            Get-VCVersion
    #>
        param(
            [Parameter(Mandatory=$false)][VMware.VimAutomation.ViCore.Util10.VersionedObjectImpl]$Server
        )



    
        # Pulled from https://kb.vmware.com/kb/2143838
        $vcenterBuildVersionMappings = @{
            "13843380"="vCenter Appliance 6.7 U2b,2019-05-30"
            "13643870"="vCenter 6.7 U2a,2019-05-14"
            "13010631"="vCenter 6.7 U2,2019-04-11"
            "11727113"="vCenter Appliance 6.7 U1b,2019-01-17"
            "11726888"="vCenter 6.7 U1b,2019-01-17"
            "11338176"="vCenter Appliance 6.7 U1a,2018-12-20"
            "10244857"="vCenter Appliance 6.7 U1 (6.7.0.20000),2018-10-16"
            "10244745"="vCenter 6.7 U1 (6.7.0.20000),2018-10-16"
            "9451876"="vCenter 6.7d (6.7.0.14000),2018-08-14"
            "9433931"="vCenter Appliance 6.7d (6.7.0.14000),2018-08-14"
            "9433894"="vCenter Windows 6.7d (6.7.0.14000),2018-08-14"
            "9232942"="vCenter Appliance 6.7c (6.7.0.13000),2018-07-26"
            "9232933"="vCenter Windows 6.7c (6.7.0.13000),2018-07-26"
            "9232925"="vCenter 6.7c (6.7.0.13000),2018-07-26"
            "8833179"="vCenter Appliance 6.7b (6.7.0.12000),2018-06-28"
            "8833120"="vCenter Windows 6.7b (6.7.0.12000),2018-06-28"
            "8832884"="vCenter 6.7b (6.7.0.12000),2018-06-28"
            "8546281"="vCenter Windows 6.7a (6.7.0.11000),2018-05-22"
            "8546234"="vCenter 6.7a (6.7.0.11000),2018-05-22"
            "8217866"="vCenter 6.7 (6.7.0.10000),2018-04-17"
            "8170161"="vCenter Appliance 6.7 (6.7.0.10000),2018-04-17"
            "8170087"="vCenter Windows 6.7 (6.7.0.10000),2018-04-17"
            "14020092"="vCenter Server 6.5 U3,2019-07-92"
            "13834586"="vCenter Server 6.5 U2h,2019-05-30"
            "13638625"="vCenter Server 6.5 U2g,2019-05-14"
            "12863991"="vCenter Server 6.5 U2f,2019-03-21"
            "11347054"="vCenter Server 6.5 U2e,2018-12-20"
            "10964411"="vCenter Server 6.5 U2d,2018-11-29"
            "9451637"="vCenter Server 6.5 U2c,2018-08-14"
            "8815520"="vCenter Server 6.5 U2b,2018-06-28"
            "8667236"="vCenter Server 6.5 U2a,2018-05-31"
            "8307201"="vCenter Server 6.5 U2,2018-05-03"
            "8024368"="vCenter Server 6.5 Update 1g,2018-03-20"
            "7515524"="vCenter Server 6.5 Update 1e,2018-01-09"
            "7312210"="vCenter Server 6.5 Update 1d,2017-12-19"
            "6816762"="vCenter Server 6.5 Update 1b,2017-10-26"
            "5973321"="vCenter 6.5 Update 1,2017-07-27"
            "5705665"="vCenter 6.5 0e Express Patch 3,2017-06-15"
            "5318154"="vCenter 6.5 0d Express Patch 2,2017-04-18"
            "9313458"="vCenter 6.0 Update 3h,2018-08-14"
            "9109103"="vCenter 6.0 Update 3g,2018-07-26"
            "8874690"="vCenter 6.0 Update 3f,2018-06-28"
            "7924803"="vCenter 6.0 Update 3e,2018-03-20"
            "7462485"="vCenter 6.0 Update 3d,2018-01-09"
            "7462484"="vCenter 6.0 Update 3d,2018-01-09"
            "7037394"="vCenter 6.0 Update 3c,2017-11-09"
            "5318203"="vCenter 6.0 Update 3b,2017-04-13"
            "5318200"="vCenter 6.0 Update 3b,2017-04-13"
            "5183549"="vCenter 6.0 Update 3a,2017-03-21"
            "5112527"="vCenter 6.0 Update 3,2017-02-24"
            "4541947"="vCenter 6.0 Update 2a,2016-11-22"
            "3634793"="vCenter 6.0 Update 2,2016-03-16"
            "3339083"="vCenter 6.0 Update 1b,2016-01-07"
            "3018524"="vCenter 6.0 Update 1,2015-09-10"
            "2776511"="vCenter 6.0.0b,2015-07-07"
            "2656760"="vCenter 6.0.0a,2015-04-16"
            "2559268"="vCenter 6.0 GA,2015-03-12"
            "4180647"="vCenter 5.5 Update 3e,2016-08-04"
            "3721164"="vCenter 5.5 Update 3d,2016-04-14"
            "3660016"="vCenter 5.5 Update 3c,2016-03-29"
            "3252642"="vCenter 5.5 Update 3b,2015-12-08"
            "3142196"="vCenter 5.5 Update 3a,2015-10-22"
            "3000241"="vCenter 5.5 Update 3,2015-09-16"
            "2646482"="vCenter 5.5 Update 2e,2015-04-16"
            "2001466"="vCenter 5.5 Update 2,2014-09-09"
            "1945274"="vCenter 5.5 Update 1c,2014-07-22"
            "1891313"="vCenter 5.5 Update 1b,2014-06-12"
            "1750787"="vCenter 5.5 Update 1a,2014-04-19"
            "1750596"="vCenter 5.5.0c,2014-04-19"
            "1623099"="vCenter 5.5 Update 1,2014-03-11"
            "1378903"="vCenter 5.5.0a,2013-10-31"
            "1312299"="vCenter 5.5 GA,2013-09-22"
            "3900744"="vCenter 5.1 Update 3d,2016-05-19"
            "3070521"="vCenter 5.1 Update 3b,2015-10-01"
            "2669725"="vCenter 5.1 Update 3a,2015-04-30"
            "2207772"="vCenter 5.1 Update 2c,2014-10-30"
            "1473063"="vCenter 5.1 Update 2,2014-01-16"
            "1364037"="vCenter 5.1 Update 1c,2013-10-17"
            "1235232"="vCenter 5.1 Update 1b,2013-08-01"
            "1064983"="vCenter 5.1 Update 1,2013-04-25"
            "880146"="vCenter 5.1.0a,2012-10-25"
            "799731"="vCenter 5.1 GA,2012-09-10"
            "3891028"="vCenter 5.0 U3g,2016-06-14"
            "3073236"="vCenter 5.0 U3e,2015-10-01"
            "2656067"="vCenter 5.0 U3d,2015-04-30"
            "1300600"="vCenter 5.0 U3,2013-10-17"
            "913577"="vCenter 5.0 U2,2012-12-20"
            "755629"="vCenter 5.0 U1a,2012-07-12"
            "623373"="vCenter 5.0 U1,2012-03-15"
            "5318112"="vCenter 6.5.0c Express Patch 1b,2017-04-13"
            "5178943"="vCenter 6.5.0b,2017-03-14"
            "4944578"="vCenter 6.5.0a Express Patch 01,2017-02-02"
            "4602587"="vCenter 6.5,2016-11-15"
            "5326079"="vCenter 6.0 Update 3b,2017-04-13"
            "5183552"="vCenter 6.0 Update 3a,2017-03-21"
            "5112529"="vCenter 6.0 Update 3,2017-02-24"
            "4541948"="vCenter 6.0 Update 2a,2016-11-22"
            "4191365"="vCenter 6.0 Update 2m,2016-09-15"
            "3634794"="vCenter 6.0 Update 2,2016-03-15"
            "3339084"="vCenter 6.0 Update 1b,2016-01-07"
            "3018523"="vCenter 6.0 Update 1,2015-09-10"
            "2776510"="vCenter 6.0.0b,2015-07-07"
            "2656761"="vCenter 6.0.0a,2015-04-16"
            "2559267"="vCenter 6.0 GA,2015-03-12"
            "4180648"="vCenter 5.5 Update 3e,2016-08-04"
            "3730881"="vCenter 5.5 Update 3d,2016-04-14"
            "3660015"="vCenter 5.5 Update 3c,2016-03-29"
            "3255668"="vCenter 5.5 Update 3b,2015-12-08"
            "3154314"="vCenter 5.5 Update 3a,2015-10-22"
            "3000347"="vCenter 5.5 Update 3,2015-09-16"
            "2646489"="vCenter 5.5 Update 2e,2015-04-16"
            "2442329"="vCenter 5.5 Update 2d,2015-01-27"
            "2183111"="vCenter 5.5 Update 2b,2014-10-09"
            "2063318"="vCenter 5.5 Update 2,2014-09-09"
            "1623101"="vCenter 5.5 Update 1,2014-03-11"
            "1476327"="vCenter 5.5.0b,2013-12-22"
            "1398495"="vCenter 5.5.0a,2013-10-31"
            "1312298"="vCenter 5.5 GA,2013-09-22"
            "3868380"="vCenter 5.1 Update 3d,2016-05-19"
            "3630963"="vCenter 5.1 Update 3c,2016-03-29"
            "3072314"="vCenter 5.1 Update 3b,2015-10-01"
            "2306353"="vCenter 5.1 Update 3,2014-12-04"
            "1882349"="vCenter 5.1 Update 2a,2014-07-01"
            "1474364"="vCenter 5.1 Update 2,2014-01-16"
            "1364042"="vCenter 5.1 Update 1c,2013-10-17"
            "1123961"="vCenter 5.1 Update 1a,2013-05-22"
            "1065184"="vCenter 5.1 Update 1,2013-04-25"
            "947673"="vCenter 5.1.0b,2012-12-20"
            "880472"="vCenter 5.1.0a,2012-10-25"
            "799730"="vCenter 5.1 GA,2012-08-13"
            "3891027"="vCenter 5.0 U3g,2016-06-14"
            "3073237"="vCenter 5.0 U3e,2015-10-01"
            "2656066"="vCenter 5.0 U3d,2015-04-30"
            "2210222"="vCenter 5.0 U3c,2014-11-20"
            "1917469"="vCenter 5.0 U3a,2014-07-01"
            "1302764"="vCenter 5.0 U3,2013-10-17"
            "920217"="vCenter 5.0 U2,2012-12-20"
            "804277"="vCenter 5.0 U1b,2012-08-16"
            "759855"="vCenter 5.0 U1a,2012-07-12"
            "455964"="vCenter 5.0 GA,2011-08-24"
        }
    
        if(-not $Server) {
            $Server = $global:DefaultVIServer
        }
    
        $vcBuildNumber = $Server.Build
        $vcName = $Server.Name
        $vcOS = $Server.ExtensionData.Content.About.OsType
        $vcVersion,$vcRelDate = "Unknown","Unknown"
    
        if($vcenterBuildVersionMappings.ContainsKey($vcBuildNumber)) {
            ($vcVersion,$vcRelDate) = $vcenterBuildVersionMappings[$vcBuildNumber].split(",")
        }
    
        $tmp = [pscustomobject] @{
            Name = $vcName;
            Build = $vcBuildNumber;
            Version = $vcVersion;
            OS = $vcOS;
            ReleaseDate = $vcRelDate;
        }
        $tmp
    }

foreach ($vCenterInstance in $($global:DefaultVIServers)) {
    Get-VCVersion $vCenterInstance
}

$Title = "[vCenter] Version"
$Header =  "[vCenter] Build and version"
$Comments = "This plugin gets the vCenter server version and maps it to a build number"
$Display = "table"
$Author = "Dario Doerflinger"
$PluginVersion = 1.2
$PluginCategory = "vSphere"

# Changes:
# 1.2   Updated vCenter build up to July 9th 2019
