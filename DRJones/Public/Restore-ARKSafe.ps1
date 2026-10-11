# .ExternalHelp DRJones-help.xml
function Restore-ARKSafe {
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType('DRJones.RecoveryResult')]
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
		[string]$OutputPath,

		[Parameter(
			Mandatory = $false,
			Position = 2,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Container })]
		[string]$KeyPath = $Script:ARKConfig.KeyPath

	)

	begin {

		Assert-ARKElevated -Operation 'SafeRecover'

	}

	process {

		if ([string]::IsNullOrEmpty($KeyPath)) {

			throw 'Recovery key folder not specified. Provide -KeyPath, or set a default with Set-ARKConfiguration -KeyPath'

		}

		$OutFolder = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath)

		$ArgumentList = @(
			$Safe
			$OutFolder
			$PSCmdlet.GetUnresolvedProviderPathFromPSPath($KeyPath)
		)

		if ($PSCmdlet.ShouldProcess($OutFolder, "Recover Safe $Safe")) {

			if ((Get-Service -Name 'PrivateArk Server' -ErrorAction Ignore).Status -eq 'Running') {

				throw 'The PrivateArk Server service is running. Stop it before recovering a Safe; SafeRecover.exe cannot run while the Vault is running'

			}

			if (-not (Test-Path -Path $OutFolder -PathType Container)) {

				$null = New-Item -Path $OutFolder -ItemType Directory -Force

			}

			$Result = Invoke-ARKUtility -Utility SafeRecover -ArgumentList $ArgumentList

			if ($Result) {

				[PSCustomObject]@{
					PSTypeName = 'DRJones.RecoveryResult'
					Source     = $Safe
					OutputPath = $OutFolder
					Utility    = $Result.Utility
					ExitCode   = $Result.ExitCode
					Output     = $Result.StdOut
				}

			}

		}

	}

}
