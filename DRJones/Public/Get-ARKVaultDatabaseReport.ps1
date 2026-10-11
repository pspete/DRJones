# .ExternalHelp DRJones-help.xml
function Get-ARKVaultDatabaseReport {
	[CmdletBinding()]
	[OutputType('DRJones.UtilityResult')]
	param( )

	Assert-ARKElevated -Operation 'CAVaultManager DiagnoseDBReport'

	Invoke-ARKUtility -Utility CAVaultManager -ArgumentList 'DiagnoseDBReport'

}
