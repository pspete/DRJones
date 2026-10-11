# .ExternalHelp DRJones-help.xml
function Restore-ARKFile {
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType('DRJones.RecoveryResult')]
	param(

		[Parameter(
			Mandatory = $true,
			Position = 0,
			ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName')]
		[ValidateNotNullOrEmpty()]
		[string]$Path,

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
		[string]$KeyPath = $Script:ARKConfig.KeyPath,

		[Parameter(
			Mandatory = $false,
			Position = 3,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$SafeRecoveryKeyPath

	)

	process {

		if ([string]::IsNullOrEmpty($KeyPath)) {

			throw 'Recovery key folder not specified. Provide -KeyPath, or set a default with Set-ARKConfiguration -KeyPath'

		}

		$InFile = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
		$OutFolder = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath)

		$ArgumentList = @(
			$InFile
			$OutFolder
			$PSCmdlet.GetUnresolvedProviderPathFromPSPath($KeyPath)
		)

		if ($PSBoundParameters.ContainsKey('SafeRecoveryKeyPath')) {

			$ArgumentList += $PSCmdlet.GetUnresolvedProviderPathFromPSPath($SafeRecoveryKeyPath)

		}

		if ($PSCmdlet.ShouldProcess($OutFolder, "Recover $InFile")) {

			if (-not (Test-Path -Path $OutFolder -PathType Container)) {

				$null = New-Item -Path $OutFolder -ItemType Directory -Force

			}

			$Result = Invoke-ARKUtility -Utility Recover -ArgumentList $ArgumentList

			if ($Result) {

				[PSCustomObject]@{
					PSTypeName = 'DRJones.RecoveryResult'
					Source     = $InFile
					OutputPath = $OutFolder
					Utility    = $Result.Utility
					ExitCode   = $Result.ExitCode
					Output     = $Result.StdOut
				}

			}

		}

	}

}
