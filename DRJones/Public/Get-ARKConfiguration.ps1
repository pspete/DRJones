# .ExternalHelp DRJones-help.xml
function Get-ARKConfiguration {
	[CmdletBinding()]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param( )

	$Script:ARKConfig | Select-Object -Property UtilityPath, KeyPath

}
