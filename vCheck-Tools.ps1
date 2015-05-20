<#
.SYNOPSIS 
	This script aims to make configuring an scheduling vCheck easier by 
	providing a graphical interface.
.DESCRIPTION
	The following options can be configured for vCheck:
		- Plugins
		- Settings
		- Scheduled Task
		
	Possible other options:
		- Config Backup/Restore (for vCheck and Plugins)
		- Updates (Plugin and vCheck Core)
		- ???
.NOTES 
   File Name  : vCheck-Tools.ps1 
   Author     : John Sneddon - @JohnSneddonAU
   Version    : 0.1
  
.INPUTS
   No inputs required
.OUTPUTS
   No outputs
#>
################################################################################
#                                INITIALISATION                                #
################################################################################
# Initialise any required variables
$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)+"\vCheck"
$vCheckPath = $ScriptPath

$pluginXMLURL = "https://raw.github.com/alanrenouf/vCheck-vSphere/master/plugins.xml"
$pluginURL = "https://raw.github.com/alanrenouf/vCheck-{0}/master/Plugins/{1}"

$ToolsVersion = 0.1

################################################################################
#                                 REQUIREMENTS                                 #
################################################################################
# Load all requirements for the script here
# Adding PowerCLI core snapin
if (!(Get-PSSnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
	Add-PSSnapin VMware.VimAutomation.Core
}
 
# Add WPF Type
Add-Type -AssemblyName PresentationFramework

################################################################################
#                                   LANGUAGE                                   #
################################################################################
$l = DATA {
    ConvertFrom-StringData @'
		XAMLError = Unable to load XAML: .NET Framework is missing or invalid XAML code was encountered.
'@ }
# If a localized version is available, overwrite the defaults
Import-LocalizedData -BaseDirectory ($ScriptPath + "\lang") -bindingVariable l -ErrorAction SilentlyContinue

################################################################################
#                                  FUNCTIONS                                   #
################################################################################
 
 function Get-PluginDetail
 {
   write-host $grid_Plugins.Rows[$grid_Plugins.SelectedCells[0].RowIndex]
 }
 <#
.SYNOPSIS
   Retrieves installed vCheck plugins and available plugins from the Virtu-Al.net repository.

.DESCRIPTION
   Get-vCheckPlugin parses your vCheck plugins folder, as well as searches the online plugin respository on Github.
   After finding the plugin you are looking for, you can download and install it with Add-vCheckPlugin. Get-vCheckPlugins
   also supports finding a plugin by name. Future version will support categories (e.g. Datastore, Security, vCloud)
     
.PARAMETER name
   Name of the plugin.

.PARAMETER proxy
   URL for proxy usage.

.EXAMPLE
   Get list of all vCheck Plugins
   Get-vCheckPlugin

.EXAMPLE
   Get plugin by name
   Get-vCheckPlugin PluginName

.EXAMPLE
   Get plugin by name using proxy
   Get-vCheckPlugin PluginName -proxy "http://127.0.0.1:3128"


.EXAMPLE
   Get plugin information
   Get-vCheckPlugins PluginName
 #>
function Get-vCheckPlugin
{
    [CmdletBinding()]
    Param
    (
        [Parameter(mandatory=$false)] [String]$name,
        [Parameter(mandatory=$false)] [String]$proxy,
        [Parameter(mandatory=$false)] [Switch]$installed,
        [Parameter(mandatory=$false)] [Switch]$notinstalled,
        [Parameter(mandatory=$false)] [String]$category
    )
    Process
    {
        $pluginObjectList = @()

        foreach ($localPluginFile in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse))
        {
            $localPluginContent = Get-Content $localPluginFile
            
            if ($localPluginContent | Select-String -pattern "title")
            {
                $localPluginName = ($localPluginContent | Select-String -pattern "Title").toString().split("""")[1]
            }
            if($localPluginContent | Select-String -pattern "description")
            {
                $localPluginDesc = ($localPluginContent | Select-String -pattern "description").toString().split("""")[1]
            }
            elseif ($localPluginContent | Select-String -pattern "comments")
            {
                $localPluginDesc = ($localPluginContent | Select-String -pattern "comments").toString().split("""")[1]
            }
            if ($localPluginContent | Select-String -pattern "author")
            {
                $localPluginAuthor = ($localPluginContent | Select-String -pattern "author").toString().split("""")[1]
            }
            if ($localPluginContent | Select-String -pattern "PluginVersion")
            {
                $localPluginVersion = @($localPluginContent | Select-String -pattern "PluginVersion")[0].toString().split(" ")[-1]
            }
			if ($localPluginContent | Select-String -pattern "PluginCategory")
            {
                $localPluginCategory = @($localPluginContent | Select-String -pattern "PluginCategory")[0].toString().split("""")[1]
            }

            $pluginObject = New-Object PSObject
            $pluginObject | Add-Member -MemberType NoteProperty -Name Name -value $localPluginName
            $pluginObject | Add-Member -MemberType NoteProperty -Name Description -value $localPluginDesc
            $pluginObject | Add-Member -MemberType NoteProperty -Name Author -value $localPluginAuthor
            $pluginObject | Add-Member -MemberType NoteProperty -Name Version -value $localPluginVersion
            $pluginObject | Add-Member -MemberType NoteProperty -Name Category -Value $localPluginCategory
            $pluginObject | Add-Member -MemberType NoteProperty -Name Enabled -value ($localPluginFile.name -match "\.ps1$")
            $pluginObject | Add-Member -MemberType NoteProperty -Name Location -Value $LocalpluginFile.name
            $pluginObjectList += $pluginObject
        }

        if (!$installed)
        {
            try
            {
                $webClient = new-object system.net.webclient
				if ($proxy)
				{
					$proxyURL = new-object System.Net.WebProxy $proxy
					$proxyURL.UseDefaultCredentials = $true
					$webclient.proxy = $proxyURL
				}
                $response = $webClient.openread($pluginXMLURL)
                $streamReader = new-object system.io.streamreader $response
                [xml]$plugins = $streamReader.ReadToEnd()

                foreach ($plugin in $plugins.pluginlist.plugin)
                {
                    $current = $pluginObjectList | where {$_.name -eq $plugin.name}					
					If ($current -and [double]$current.version -lt [double]$plugin.version) {
						$index = $pluginObjectList.Indexof($current)
						$pluginObjectList[$index].status = "New Version Available - " + $plugin.version						
					}
					if (!($pluginObjectList | where {$_.name -eq $plugin.name}))
                    {
                        $pluginObject = New-Object PSObject
                        $pluginObject | Add-Member -MemberType NoteProperty -Name Name -value $plugin.name
                        $pluginObject | Add-Member -MemberType NoteProperty -Name Description -value $plugin.description
                        $pluginObject | Add-Member -MemberType NoteProperty -Name Author -value $plugin.author
                        $pluginObject | Add-Member -MemberType NoteProperty -Name Version -value $plugin.version
                        $pluginObject | Add-Member -MemberType NoteProperty -Name Category -Value $plugin.category
                        $pluginObject | Add-Member -MemberType NoteProperty -Name Enabled -value $false
                        $pluginObject | Add-Member -MemberType NoteProperty -name Location -value $plugin.href
                        $pluginObjectList += $pluginObject
                    }
                }
            }
            catch [System.Net.WebException]
            {
                write-error $_.Exception.ToString()
                return
            }
        }

        if ($name){
            $pluginObjectList | where {$_.name -eq $name}
        } Else {
			if ($category){
				$pluginObjectList | Where {$_.Category -eq $category}
			} Else {
	            if($notinstalled){
	                $pluginObjectList | where {$_.status -eq "Not Installed"}
	            } else {
	                $pluginObjectList
	            }
	        }
		}
    }

}

# Function to handle Browse Button Click
function Get-FileName($initialDirectory)
{   
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

	$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$OpenFileDialog.initialDirectory = $initialDirectory
   $OpenFileDialog.AddExtension = $true 
   $OpenFileDialog.CheckFileExists = $false
   $OpenFileDialog.FileName = "vCheckSettings.csv"
	$OpenFileDialog.filter = "vCheck Backup| *.csv"
	$OpenFileDialog.ShowDialog() | Out-Null
   #vCheckSettings.csv
	$txtBackupLoc.Text = $OpenFileDialog.filename.ToString()
}

Function Get-PluginSettings {
	Param
    (
        [Parameter(mandatory=$true)] [String]$filename
    )
	$psettings = @()
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
	if (!(($OriginalLine +1) -eq $EndLine)) {		
		$Line = $OriginalLine		
		do {
			$Question = $file[$Line]
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0]
			$CurSet = $Split[1]			
			$settings = @{}
			$settings.filename = $filename
			$settings.question = $Question
			$settings.var = $CurSet
			$currentsetting = New-Object -TypeName PSObject -Prop $settings
			$psettings += $currentsetting
			$Line ++ 
		} Until ( $Line -ge ($EndLine -1) )
	}
	$psettings
}

Function Set-PluginSettings {	
	Param
    (
        [Parameter(mandatory=$true)] [String]$filename,
		[Parameter(mandatory=$false)] [Array]$settings,
		[Parameter(mandatory=$false)] [Switch]$GB
    )
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
	$PluginName = ($filename.split("\")[-1]).split(".")[0]
	Write-Verbose "`nProcessing - $PluginName"
	if (!(($OriginalLine +1) -eq $EndLine)) {
		$Array = @()
		$Line = $OriginalLine
		do {
			$Question = $file[$Line]
			$Found = $false
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0]
			$CurSet = $Split[1].Trim()
			Foreach ($setting in $settings) {
				If ($question -eq $setting.question) {	
					$NewSet = $setting.var
					$Found = $true
				}
			}
			If (!$Found) {
				# Check if the current setting is in speech marks
				$String = $false
				if ($CurSet -match '"') {
					$String = $true
					$CurSet = $CurSet.Replace('"', '').Trim()
				}
				$NewSet = Read-Host "$Question [$CurSet]"
				If (-not $NewSet) {
					$NewSet = $CurSet
				}
				If ($String) {
					$NewSet = "`"$NewSet`""
				}
			}
			$Array += $Question
			$Array += "$Var= $NewSet"
			$Line ++ 
		} Until ( $Line -ge ($EndLine -1) )
		$Array += "# End of Settings"

		$out = @()
		$out = $File[0..($OriginalLine -1)]
		$out += $Array
		$out += $File[$Endline..($file.count -1)]
		If ($GB) {
			$Setup = ($file | Select-String -Pattern '# Set the following to true to enable the setup wizard for first time run').LineNumber
			$SetupLine = $Setup ++
			$out[$SetupLine] = '$SetupWizard = $False'
		}
		$out | Out-File $filename
	}
}

Function Export-vCheckSettings {
	Param
    (
        [Parameter(mandatory=$false)] [String]$outfile = "$vCheckPath\vCheckSettings.csv"
    )
	
	$Export = @()
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$Export = Get-PluginSettings -Filename $GlobalVariables
	Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) { 
		$Export += Get-PluginSettings -Filename $plugin.Fullname
	}
	$Export | Select filename, question, var | Export-Csv -NoTypeInformation $outfile
   
   (new-object -ComObject wscript.shell).Popup("Export Completed",0,"vCheck Export")
}

Function Import-vCheckSettings {
	Param
    (
        [Parameter(mandatory=$false)] [String]$csvfile = "$vCheckPath\vCheckSettings.csv"
    )
	
	If (!(Test-Path $csvfile)) {
		$csvfile = Read-Host "Enter full path to settings CSV file you want to import"
	}
	$Import = Import-Csv $csvfile
	$GlobalVariables = "$vCheckPath\GlobalVariables.ps1"
	$settings = $Import | Where {($_.filename).Split("\")[-1] -eq ($GlobalVariables).Split("\")[-1]}
	Set-PluginSettings -Filename $GlobalVariables -Settings $settings -GB
	Foreach ($plugin in (Get-ChildItem -Path $vCheckPath\Plugins\* -Include *.ps1, *.ps1.disabled -Recurse)) { 
		$settings = $Import | Where {($_.filename).Split("\")[-1] -eq ($plugin.Fullname).Split("\")[-1]}
		Set-PluginSettings -Filename $plugin.Fullname -Settings $settings
	}
	(new-object -ComObject wscript.shell).Popup("Import Completed",0,"vCheck Import")
}

Function Set-GlobalVariables {
		$out = @()
		$out = $File[0..($OriginalLine -1)]
		$out += $array
		$out += $File[$Endline..($file.count -1)]
		if ($GB) { $out[$SetupLine] = '$SetupWizard = $False' }
		$out | Out-File $Filename
}


function Set-PluginsChecked {
   param ([bool]$State)
   Write-Host "asdrfasdf"
   
   

}
################################################################################
#                                     GUI                                      #
################################################################################
# Use XAML to define the form, data to be populated in code
[xml]$XAML_Main = @"
	<Window
		xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		Height="500" Width="500" Title="vCheck Tools">
		<Window.Resources>
			<Style TargetType="Label">
				<Setter Property="Height" Value="30" />			
				<Setter Property="Background" Value="#0A77BA" />
				<Setter Property="Foreground" Value="White" />
				<Setter Property="VerticalAlignment" Value="Top" />
				<Setter Property="HorizontalAlignment" Value="Left" />
			</Style>
			<BitmapImage x:Key="masterImage" UriSource="{PATH}\Styles\VMware\Header.jpg" />
			<CroppedBitmap x:Key="croppedImage" Source="{StaticResource masterImage}" SourceRect="0 0 246 108"/>
		</Window.Resources>
		<DockPanel>
			<DockPanel DockPanel.Dock="Top" Background="#0A77BA" >
				<Image Source="{StaticResource croppedImage}" Width="123" Height="54"/>
				<Label FontSize="18" FontWeight="Bold" Padding="0 17 0 17" Content="vCheck Tools" Height="54" VerticalAlignment="Center"/>
				<Label FontSize="10"  Content="by John Sneddon - @JohnSneddonAU" Padding="0 10 0 0" VerticalAlignment="Bottom" HorizontalAlignment="Right" />
			</DockPanel>
			
			<TabControl TabStripPlacement="Top" Margin="0">
				<TabItem Name="tab_vCheckInfo" Header="Information">
					<Grid Margin="0,0,-0.2,0.2">
					<Grid.ColumnDefinitions>  
						<ColumnDefinition Width="175"/>  
						<ColumnDefinition />  
					</Grid.ColumnDefinitions>  
					<Grid.RowDefinitions>  
						<RowDefinition Height="30" />  
						<RowDefinition Height="5" />
						<RowDefinition Height="30" />  
						<RowDefinition Height="5" />
						<RowDefinition Height="30" />  
					</Grid.RowDefinitions>  
						<Label Content="Powershell Version" Width="170" Grid.Row="0" Grid.Column="0" />
						<TextBox Name="txtPowershellVer" HorizontalAlignment="Stretch" Height="30" Grid.Row="0" Grid.Column="1"  TextWrapping="Wrap" Text="" VerticalAlignment="Top" IsEnabled="False" />
						<Label Content="PowerCLI Version" Width="170" Grid.Row="2" Grid.Column="0" />
						<TextBox Name="txtPowerCLIVer" HorizontalAlignment="Stretch" Height="30" Grid.Row="2" Grid.Column="1" TextWrapping="Wrap" Text="" VerticalAlignment="Top" IsEnabled="False" /> 
						<Label Content="vCheck Version" Width="170" Grid.Row="4" Grid.Column="0" />
						<TextBox Name="txtvCheckVer" HorizontalAlignment="Stretch" Height="30" Grid.Row="4" Grid.Column="1"  TextWrapping="Wrap" Text="" VerticalAlignment="Top" IsEnabled="False" /> 
					</Grid>
				</TabItem>
				
				<TabItem Name="tab_vCheckConfig" Header="Configure">
               <DockPanel>
                  <DockPanel DockPanel.Dock="Bottom" Margin="5">
                     <Button Name="btn_Save" Content="Save" Height="34" BorderThickness="0"/>
                  </DockPanel>
						<ScrollViewer>
							<Grid Name="grid_Config" Margin="0,0,-0.2,0.2">
								<Grid.ColumnDefinitions>  
									<ColumnDefinition Width="175"/>  
									<ColumnDefinition />  
								</Grid.ColumnDefinitions> 
							</Grid>
						</ScrollViewer>
					</DockPanel>
				</TabItem>
				
				<TabItem Name="tab_vCheckPugins" Header="Plugins">
					<DockPanel>
                  <DockPanel DockPanel.Dock="Bottom" Margin="5">
                     <Button Name="btn_SelectAll" Content="Select All" Height="34" BorderThickness="0"/>
                     <Button Name="btn_CheckUpdate" Content="Check for Updates" Height="34" BorderThickness="0"/>
                  </DockPanel>
                  <DataGrid Name="grid_Plugins" AutoGenerateColumns="False" CanUserAddRows="false" ColumnWidth="*">
                     <DataGrid.Columns>
                        <DataGridCheckBoxColumn Header="Enabled" Binding="{Binding Enabled}" Width="60" />
                        <DataGridTextColumn Header="Name" Binding="{Binding Name}" IsReadOnly="True" />
                        <DataGridTextColumn Header="Version" Binding="{Binding Version}" IsReadOnly="True" Width="50" />
                     </DataGrid.Columns>
                  </DataGrid>
               </DockPanel>
				</TabItem>
<!--
				<TabItem Name="tab_vCheckTask" Header="Schedule">
					<Grid Margin="0,0,-0.2,0.2">
						<Grid.ColumnDefinitions>  
							<ColumnDefinition Width="175"/>  
							<ColumnDefinition />  
						</Grid.ColumnDefinitions>  
						<Grid.RowDefinitions>  
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />
							<RowDefinition Height="65" />  
							<RowDefinition Height="5" />
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />							
						</Grid.RowDefinitions>
						<Label Content="Start Date" Width="170" Grid.Row="0" Grid.Column="0" />
						<DatePicker Name="SchDate" HorizontalAlignment="Stretch" Height="30"  Grid.Row="0" Grid.Column="1" VerticalAlignment="Top" />
						<Label Content="Start Time" Width="170" Grid.Row="2" Grid.Column="0" />
						<StackPanel Grid.Row="2" Grid.Column="1" Orientation="Horizontal" >
							<TextBox Name="txtSchTimeHour" Height="30" Width="30" TextWrapping="Wrap" Text="00" VerticalAlignment="Top" />
							<TextBox Name="txtSchTimeMin" Height="30" Width="30"  TextWrapping="Wrap" Text="00" VerticalAlignment="Top" />
						</StackPanel>
						<Label Content="Recurrance" Width="170" Height="65" Grid.Row="4" Grid.Column="0" />
						<StackPanel Grid.Row="4" Grid.Column="1" HorizontalAlignment="Stretch">
							<RadioButton GroupName="recurrance" Content="None" IsChecked="True"/>
							<RadioButton GroupName="recurrance" Content="Daily" />
							<RadioButton GroupName="recurrance" Content="Weekly" />
							<RadioButton GroupName="recurrance" Content="Monthly" />
						</StackPanel>
						<Label Content="Username" Width="170" Grid.Row="6" Grid.Column="0" />
						<TextBox Name="txtSchUser" Height="30" Grid.Row="6" Grid.Column="1" TextWrapping="Wrap" Text="" VerticalAlignment="Center" HorizontalAlignment="Stretch" />
						<Label Content="Password" Width="170" Grid.Row="8" Grid.Column="0" />
						<PasswordBox x:Name="txtSchPass" Grid.Row="8" Grid.Column="1" HorizontalAlignment="Stretch"  />
						<Button Name="btn_Schedule" Grid.Row="10" Grid.Column="1" Content="Create Task" Height="30" BorderThickness="0"/>
					</Grid>
				</TabItem>
-->				
				<TabItem Name="tab_vCheckBackup" Header="Backup/Restore">
					<Grid Margin="0,0,-0.2,0.2">
						<Grid.ColumnDefinitions>  
							<ColumnDefinition Width="175"/>  
							<ColumnDefinition />  
						</Grid.ColumnDefinitions>  
						<Grid.RowDefinitions>  
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />
							<RowDefinition Height="30" />  
							<RowDefinition Height="5" />
						</Grid.RowDefinitions>
						<Label Content="File" Width="170" Grid.Row="0" Grid.Column="0" />
						<DockPanel Grid.Row="0" Grid.Column="1" HorizontalAlignment="Stretch" >
							<Button Name="btn_BackupBrowse" Height="30" Width="60" DockPanel.Dock="Right" Content="Browse..." VerticalAlignment="Top" />
                     <TextBox Name="txtBackupLoc" Height="30" HorizontalAlignment="Stretch" TextWrapping="Wrap" Text="" VerticalAlignment="Top" />
						</DockPanel>
                  <StackPanel Grid.Row="2" Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Stretch" >
                     <Button Name="btn_BackupExport" Height="30" Width="60" Margin="0, 0, 5, 0" Content="Export" VerticalAlignment="Top" />
                     <Button Name="btn_BackupImport" Height="30" Width="60" Content="Import" VerticalAlignment="Top" />
                  </StackPanel>
					</Grid>
				</TabItem>
			</TabControl>
		</DockPanel>
	</Window>
"@

# Populate form inputs
$XAML_Main.Window.'Window.Resources'.BitmapImage.UriSource = $XAML_Main.Window.'Window.Resources'.BitmapImage.UriSource -replace "{PATH}", $ScriptPath

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $XAML_Main) 
Try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
Catch{Write-Error $l.XAMLError; exit}

# Read form controls into Powershell Objects for ease of maodifcation
$XAML_Main.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

################################################################################
#                                POPULATE FORM                                 #
################################################################################
#------------------------------------ INFO ------------------------------------#
$txtPowershellVer.Text = $host.Version.Tostring()
$txtPowerCLIVer.Text = (Get-PowerCLIVersion).UserFriendlyVersion -replace "VMware vSphere PowerCLI", ""
$txtvCheckVer.Text = ((Get-Content ("{0}\vCheck.ps1" -f $ScriptPath) | Select-String -Pattern "\$+vCheckVersion\s=").toString().split("=")[1]).Trim(' "')

#----------------------------------- PLUGINS ----------------------------------#
$Plugins = Get-vCheckPlugin -installed

$array = New-Object System.Collections.ArrayList
$Script:pluginInfo = $Plugins | Select Enabled, Name, Version
$array.AddRange($pluginInfo)
$grid_Plugins.itemssource = $array

#----------------------------------- CONFIG -----------------------------------#
$row = 0

$RowDef = new-object System.Windows.Controls.RowDefinition
$RowDef.Height = "30"
$grid_Config.RowDefinitions.Add($RowDef)
$RowDef = new-object System.Windows.Controls.RowDefinition
$RowDef.Height = "5"
$grid_Config.RowDefinitions.Add($RowDef)
$label = New-Object System.Windows.Controls.Label
$label.Content = "GlobalVariables"
$label.Background="#1D6325"
$label.HorizontalAlignment="Stretch"
$label.HorizontalContentAlignment="Stretch"
$grid_Config.Children.Add($label) | Out-Null
[Windows.Controls.Grid]::SetRow($label,$row)
[Windows.Controls.Grid]::SetColumn($label,0)
[Windows.Controls.Grid]::SetColumnSpan($label,2)
		
$file = Get-Content "$ScriptPath\GlobalVariables.ps1"
$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
$row=$row+2
if (!(($OriginalLine +1) -eq $EndLine)) {
	$Array = @()
	$Line = $OriginalLine

	do {
		$Question = $file[$Line]
		Write-Debug ("Line {0}: {1}" -f $Line, $Question)
		$Line ++
		$Split= ($file[$Line]).Split("=")
		$Var = ($Split[0] -replace "\$", "").Trim()
		$CurSet = $Split[1].Replace('"', '').Trim()
		
		$RowDef = new-object System.Windows.Controls.RowDefinition
		$RowDef.Height = "30"
		$grid_Config.RowDefinitions.Add($RowDef)
		
		Write-Debug ("   Row {0}: {1}={2}" -f $row, $Var, $CurSet)
		$label = new-object System.Windows.Controls.Label
		$label.Content = $Var
		$label.Width="170"
		$grid_Config.Children.Add($label) | Out-Null
		[Windows.Controls.Grid]::SetRow($label,$row)
		[Windows.Controls.Grid]::SetColumn($label,0)

		$TextBox = New-Object System.Windows.Controls.TextBox
		$TextBox.Name = "txt"+$Var
		$TextBox.Text = $CurSet
		$TextBox.HorizontalAlignment = "Stretch"
		$TextBox.VerticalAlignment="Top" 
		$TextBox.Height="30" 
		[Windows.Controls.Grid]::SetRow($TextBox,$row)
		[Windows.Controls.Grid]::SetColumn($TextBox,1)
		$grid_Config.Children.Add($TextBox) | Out-Null
		
		$RowDef = new-object System.Windows.Controls.RowDefinition
		$RowDef.Height = "5"
		$grid_Config.RowDefinitions.Add($RowDef)
		
		$Line++
		$row=$row+2
		
	} Until ( $Line -ge ($EndLine -1) )
}
#---------------------------------- SCHEDULE ----------------------------------#
# Pre-populate fields on Schedule tab
#$txtSchUser.Text = ("{0}\{1}" -f $env:USERDOMAIN, $env:Username).ToString()
#$txtSchTimeHour.Text = (Get-Date).Hour.ToString()
#$txtSchTimeMin.Text = (Get-Date).Minute.ToString()
#$SchDate.SelectedDate = (Get-Date)
#----------------------------------- BACKUP -----------------------------------#
# Nothing to do on Backup TabControl

################################################################################
#                                    EVENTS                                    #
################################################################################
# Add Save button handler
$btn_Save.Add_Click({Set-GlobalVariables})

# Plugins
$btn_SelectAll.Add_Click({Set-PluginsChecked $true})
Write-Host $grid_Plugins.Rows.Count
# Add Backup tab button actions
$btn_BackupBrowse.Add_Click({Get-FileName $ScriptPath})
$btn_BackupExport.Add_Click({Export-vCheckSettings $txtBackupLoc.Text})
$btn_BackupImport.Add_Click({Import-vCheckSettings $txtBackupLoc.Text})

# Add schedule action
#$btn_Schedule.Add_Click({})

################################################################################
#                                    DISPLAY                                   #
################################################################################
$Form.ShowDialog() | out-null
