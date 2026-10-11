#region Loader
<#
.SYNOPSIS
DRJones: Disaster Recovery Helper for CyberArk Vault Data.

.DESCRIPTION
Loads the module functions and imports any saved DRJones configuration.

.EXAMPLE
Import-Module DRJones

.INPUTS
None

.OUTPUTS
None
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'DotSourceModule', Justification = 'Used within the ForEach-Object script block')]
[CmdletBinding()]
param(

	[bool]$DotSourceModule = $false

)

#Get function files
Get-ChildItem $PSScriptRoot\ -Recurse -Include '*.ps1' -Exclude '*.ps1xml' |

	ForEach-Object {

		if ($DotSourceModule) {
			. $_.FullName
		} else {
			$ExecutionContext.InvokeCommand.InvokeScript(
				$false,
				(
					[scriptblock]::Create(
						[io.file]::ReadAllText(
							$_.FullName,
							[Text.Encoding]::UTF8
						)
					)
				),
				$null,
				$null
			)

		}

	}
#endregion Loader

# Module scope code below the Loader region is appended to the built module after the function definitions.

# Script scope configuration object, persisted by Set-ARKConfiguration
$Script:ARKConfigFile = Join-Path $HOME 'DRJonesConfiguration.xml'

$Script:ARKConfig = [PSCustomObject]@{
	UtilityPath = $null
	KeyPath     = $null
}

if (Test-Path -Path $Script:ARKConfigFile -PathType Leaf) {

	Write-Verbose "Importing Settings: $Script:ARKConfigFile"
	$Script:ARKConfig = Import-Clixml -Path $Script:ARKConfigFile

}
