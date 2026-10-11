# .ExternalHelp DRJones-help.xml
function Sync-ARKVaultDatabase {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType('DRJones.UtilityResult')]
	param(

		[Parameter(
			Mandatory = $false,
			Position = 0
		)]
		[ValidateNotNullOrEmpty()]
		[string]$SafePattern,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$FilesSyncOnly,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$QuotaSyncOnly,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$Update

	)

	$ArgumentList = @(
		'SynchronizeDB'
		if ($SafePattern) {
			'/SafePattern'
			$SafePattern
		}
		if ($FilesSyncOnly) { '/FilesSyncOnly' }
		if ($QuotaSyncOnly) { '/QuotaSyncOnly' }
		if ($Update) { '/Update' }
		'/Force'
	)

	$Target = if ($SafePattern) { "Safes matching $SafePattern" } else { 'All Safes' }

	if ((-not $Update) -or $PSCmdlet.ShouldProcess($Target, 'Synchronize Vault database with restored files')) {

		Invoke-ARKUtility -Utility CAVaultManager -ArgumentList $ArgumentList

	}

}
