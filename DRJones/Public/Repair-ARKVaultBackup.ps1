# .ExternalHelp DRJones-help.xml
function Repair-ARKVaultBackup {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType('DRJones.UtilityResult')]
	param(

		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNullOrEmpty()]
		[string]$BackupPoolName

	)

	Assert-ARKElevated -Operation 'CAVaultManager RecoverBackupFiles'

	$ArgumentList = @(
		'RecoverBackupFiles'
		if ($BackupPoolName) {
			'/BackupPoolName'
			$BackupPoolName
		}
	)

	$Target = if ($BackupPoolName) { "Backup pool $BackupPoolName" } else { 'Restored Safes backup files' }

	if ($PSCmdlet.ShouldProcess($Target, 'Recover and re-encrypt with a new backup key')) {

		Invoke-ARKUtility -Utility CAVaultManager -ArgumentList $ArgumentList

	}

}
