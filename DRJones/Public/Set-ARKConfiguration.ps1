# .ExternalHelp DRJones-help.xml
function Set-ARKConfiguration {
	[CmdletBinding(SupportsShouldProcess)]
	param(

		[Parameter(
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Container })]
		[string[]]$UtilityPath,

		[Parameter(
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Container })]
		[string]$KeyPath

	)

	process {

		if ($PSCmdlet.ShouldProcess($Script:ARKConfigFile, 'Save DRJones Configuration')) {

			switch ($PSBoundParameters.Keys) {

				'UtilityPath' { $Script:ARKConfig.UtilityPath = [string[]]@($UtilityPath | ForEach-Object { $PSCmdlet.GetUnresolvedProviderPathFromPSPath($_) }) }

				'KeyPath' { $Script:ARKConfig.KeyPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($KeyPath) }

			}

			$Script:ARKConfig | Export-Clixml -Path $Script:ARKConfigFile -Force

		}

	}

}
