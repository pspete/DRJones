function Get-ARKUtilityPath {
	<#
	.SYNOPSIS
	Gets the path to a CyberArk utility.

	.DESCRIPTION
	Returns the path to the utility executable in the first folder set with Set-ARKConfiguration -UtilityPath that
	contains it.

	Throws if no utility folder is set, or if the utility is not found in any of them.

	.PARAMETER Utility
	The utility to locate: Recover, SafeRecover, PARestore, PAReplicate or CAVaultManager.

	.EXAMPLE
	Get-ARKUtilityPath -Utility PAReplicate

	Returns: C:\Program Files (x86)\PrivateArk\Replicate\PAReplicate.exe
	#>
	[CmdletBinding()]
	[OutputType('System.String')]
	param(

		[Parameter(
			Mandatory = $true
		)]
		[ValidateSet('Recover', 'SafeRecover', 'PARestore', 'PAReplicate', 'CAVaultManager')]
		[string]$Utility

	)

	$UtilityPath = @($Script:ARKConfig.UtilityPath | Where-Object { -not [string]::IsNullOrEmpty($_) })

	if ($UtilityPath.Count -eq 0) {

		throw "Recovery utility folder not set. Run Set-ARKConfiguration -UtilityPath <folder containing $Utility.exe>"

	}

	$FilePath = @(
		$UtilityPath |
			ForEach-Object { Join-Path -Path $_ -ChildPath "$Utility.exe" } |
			Where-Object { Test-Path -Path $_ -PathType Leaf }
	)[0]

	if (-not $FilePath) {

		throw "$Utility.exe not found in $($UtilityPath -join ', '). Run Set-ARKConfiguration -UtilityPath <folder containing $Utility.exe>"

	}

	$FilePath

}
