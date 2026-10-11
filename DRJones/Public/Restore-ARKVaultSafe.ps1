# .ExternalHelp DRJones-help.xml
function Restore-ARKVaultSafe {
	[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Credential')]
	[OutputType('DRJones.UtilityResult')]
	param(

		[Parameter(
			Mandatory = $true,
			Position = 0,
			ValueFromPipelineByPropertyName = $true
		)]
		[Alias('SafeName')]
		[ValidateNotNullOrEmpty()]
		[string]$Safe,

		[Parameter(
			Mandatory = $true,
			Position = 1,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[string]$TargetSafe,

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
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateNotNullOrEmpty()]
		[string]$BackupPoolName,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$DataOnly,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$MetadataOnly,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$LoadOnly

	)

	process {

		if ($DataOnly -and $MetadataOnly) {

			throw 'DataOnly and MetadataOnly cannot be used together'

		}

		$LogonParameters = @{ }
		foreach ($Key in 'VaultFile', 'Credential', 'LogonFile', 'BackupPoolName') {
			if ($PSBoundParameters.ContainsKey($Key)) { $LogonParameters[$Key] = $PSBoundParameters[$Key] }
		}

		$ArgumentList = @(
			Get-ARKBackupArgument @LogonParameters
			if ($LoadOnly) { '/LoadOnly' }
			'/RestoreSafe'
			$Safe
			'/TargetSafe'
			$TargetSafe
			if ($DataOnly) { '/DataOnly' }
			if ($MetadataOnly) { '/MetadataOnly' }
		)

		if ($PSCmdlet.ShouldProcess($TargetSafe, "Restore Safe $Safe")) {

			$Result = Invoke-ARKUtility -Utility PARestore -ArgumentList $ArgumentList -SensitiveValue $(
				if ($Credential) { $Credential.GetNetworkCredential().Password }
			)

			#ITATS658W: a backed-up owner not matched in the Vault is removed from the target Safe
			$Result.StdOut -split '\r?\n' | Where-Object { $_ -match 'ITATS658W' } | ForEach-Object {
				Write-Warning $_.Trim()
			}

			$Result

		}

	}

}
