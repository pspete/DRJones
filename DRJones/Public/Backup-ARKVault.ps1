# .ExternalHelp DRJones-help.xml
function Backup-ARKVault {
	[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'LogonFile')]
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
		[switch]$Incremental

	)

	$LogonParameters = @{ }
	foreach ($Key in 'VaultFile', 'Credential', 'LogonFile', 'BackupPoolName') {
		if ($PSBoundParameters.ContainsKey($Key)) { $LogonParameters[$Key] = $PSBoundParameters[$Key] }
	}

	$ArgumentList = @(
		Get-ARKBackupArgument @LogonParameters
		if (-not $Incremental) { '/FullBackup' }
	)

	$BackupType = if ($Incremental) { 'incremental' } else { 'full' }

	if ($PSCmdlet.ShouldProcess('Vault', "Run $BackupType backup")) {

		Invoke-ARKUtility -Utility PAReplicate -ArgumentList $ArgumentList -SensitiveValue $(
			if ($Credential) { $Credential.GetNetworkCredential().Password }
		)

	}

}
