# .ExternalHelp DRJones-help.xml
function Get-ARKVaultParameter {
	[CmdletBinding()]
	[OutputType('DRJones.VaultParameter')]
	param(

		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[Alias('FullName')]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$Path,

		[Parameter(
			Mandatory = $false,
			Position = 0
		)]
		[ValidateNotNullOrEmpty()]
		[SupportsWildcards()]
		[string[]]$Name = '*',

		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNullOrEmpty()]
		[string]$Section

	)

	process {

		$FullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

		$Ini = Read-ARKIniFile -Path $FullPath

		foreach ($Parameter in $Ini.Parameters) {

			if ($Section -and $Parameter.Section -ne $Section) { continue }

			if (-not ($Name | Where-Object { $Parameter.Name -like $_ })) { continue }

			[PSCustomObject]@{
				PSTypeName = 'DRJones.VaultParameter'
				Section    = $Parameter.Section
				Name       = $Parameter.Name
				Value      = $Parameter.Value
				Path       = $FullPath
			}

		}

	}

}
