# .ExternalHelp DRJones-help.xml
function Restore-ARKVaultDatabase {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType('DRJones.UtilityResult')]
	param(

		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNullOrEmpty()]
		[string]$BackupPoolName,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$NoSynchronize

	)

	Assert-ARKElevated -Operation 'CAVaultManager RestoreDB'

	$ArgumentList = @(
		'RestoreDB'
		if ($BackupPoolName) {
			'/BackupPoolName'
			$BackupPoolName
		}
		if ($NoSynchronize) { '/NoSynchronize' }
		'/Force'
	)

	if ($PSCmdlet.ShouldProcess('Vault database', 'Restore from Restored Safes folder')) {

		Invoke-ARKUtility -Utility CAVaultManager -ArgumentList $ArgumentList

	}

}
