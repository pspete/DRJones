function Get-ARKBackupArgument {
	<#
	.SYNOPSIS
	Builds the leading PARestore and PAReplicate arguments: Vault file, user logon and backup pool.

	.DESCRIPTION
	Returns the arguments common to every PARestore and PAReplicate operation, in command line order:

	<VaultFile> <User>/<Password> | /LogonFromFile <LogonFile>, then /BackupPoolName <BackupPoolName>.

	VaultFile defaults to Vault.ini, which the utility reads from its own folder.
	Relative paths provided for VaultFile and LogonFile are resolved against the current PowerShell location.

	.PARAMETER VaultFile
	The Vault parameter file.

	.PARAMETER Credential
	The Vault user and password.

	.PARAMETER LogonFile
	The user credentials file.

	.PARAMETER BackupPoolName
	The backup pool name.

	.EXAMPLE
	Get-ARKBackupArgument -LogonFile C:\Creds\Operator.cred

	Returns: Vault.ini, /LogonFromFile, C:\Creds\Operator.cred
	#>
	[CmdletBinding()]
	[OutputType('System.String')]
	param(

		[Parameter(
			Mandatory = $false
		)]
		[string]$VaultFile,

		[Parameter(
			Mandatory = $true,
			ParameterSetName = 'Credential'
		)]
		[pscredential]$Credential,

		[Parameter(
			Mandatory = $true,
			ParameterSetName = 'LogonFile'
		)]
		[string]$LogonFile,

		[Parameter(
			Mandatory = $false
		)]
		[string]$BackupPoolName

	)

	if ($VaultFile) {
		$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($VaultFile)
	} else {
		'Vault.ini'
	}

	switch ($PSCmdlet.ParameterSetName) {

		'Credential' {
			'{0}/{1}' -f $Credential.UserName, $Credential.GetNetworkCredential().Password
		}

		'LogonFile' {
			'/LogonFromFile'
			$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogonFile)
		}

	}

	if ($BackupPoolName) {

		'/BackupPoolName'
		$BackupPoolName

	}

}
