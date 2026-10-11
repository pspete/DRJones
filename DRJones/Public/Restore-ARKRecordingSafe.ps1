# .ExternalHelp DRJones-help.xml
function Restore-ARKRecordingSafe {
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
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateScript( { $_ -notmatch '\\' })]
		[string[]]$Owners,

		[Parameter(
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateRange(1, 90)]
		[int]$Retention,

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
		[string]$BackupPoolName

	)

	process {

		$LogonParameters = @{ }
		foreach ($Key in 'VaultFile', 'Credential', 'LogonFile', 'BackupPoolName') {
			if ($PSBoundParameters.ContainsKey($Key)) { $LogonParameters[$Key] = $PSBoundParameters[$Key] }
		}

		$ArgumentList = @(
			Get-ARKBackupArgument @LogonParameters
			'/RestoreRecordings'
			'/RestoreSafe'
			$Safe
			'/TargetSafe'
			$TargetSafe
			if ($PSBoundParameters.ContainsKey('Owners')) {
				'/Owners'
				$Owners -join '\'
			}
			if ($PSBoundParameters.ContainsKey('Retention')) {
				'/Retention'
				$Retention
			}
		)

		if ($PSCmdlet.ShouldProcess($TargetSafe, "Restore recordings Safe $Safe")) {

			Invoke-ARKUtility -Utility PARestore -ArgumentList $ArgumentList -Interactive -SensitiveValue $(
				if ($Credential) { $Credential.GetNetworkCredential().Password }
			)

		}

	}

}
