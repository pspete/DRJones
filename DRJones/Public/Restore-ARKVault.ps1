# .ExternalHelp DRJones-help.xml
function Restore-ARKVault {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Credential')]
	[OutputType('DRJones.UtilityResult')]
	param(

		[Parameter(
			Mandatory = $true,
			ParameterSetName = 'Credential'
		)]
		[pscredential]$Credential,

		[Parameter(
			Mandatory = $true,
			ParameterSetName = 'LogonFile'
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$LogonFile,

		[Parameter(
			Mandatory = $false
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$VaultFile,

		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNullOrEmpty()]
		[string]$BackupPoolName,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$FromRestored

	)

	Assert-ARKElevated -Operation 'PARestore /FullVaultRestore'

	$LogonParameters = @{ }
	foreach ($Key in 'VaultFile', 'Credential', 'LogonFile', 'BackupPoolName') {
		if ($PSBoundParameters.ContainsKey($Key)) { $LogonParameters[$Key] = $PSBoundParameters[$Key] }
	}

	$ArgumentList = @(
		Get-ARKBackupArgument @LogonParameters
		'/FullVaultRestore'
		if ($FromRestored) { '/FromRestored' }
	)

	if ($PSCmdlet.ShouldProcess('Vault Restored Safes folder', 'Upload full Vault backup')) {

		Invoke-ARKUtility -Utility PARestore -ArgumentList $ArgumentList -SensitiveValue $(
			if ($Credential) { $Credential.GetNetworkCredential().Password }
		)

	}

}
