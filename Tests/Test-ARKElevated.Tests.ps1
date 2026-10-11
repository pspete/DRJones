BeforeDiscovery {

	#Get Current Directory
	$Here = Split-Path -Parent $PSCommandPath

	#Module Name
	$ModuleName = 'DRJones'

	#Resolve Path to Module Directory
	$ModulePath = Resolve-Path "$Here\..\$ModuleName"

	#Define Path to Module Manifest
	$ManifestPath = Join-Path "$ModulePath" "$ModuleName.psd1"

	if ( -not (Get-Module -Name $ModuleName -All)) {

		Import-Module -Name "$ManifestPath" -ArgumentList $true -Force -ErrorAction Stop

	}

}

Describe 'Test-ARKElevated' {

	InModuleScope 'DRJones' {

		Context 'Output' {

			It 'returns a boolean' {

				Test-ARKElevated | Should -BeOfType [bool]

			}

			It 'matches the Administrator role of the current identity' {

				$Expected = [Security.Principal.WindowsPrincipal]::new(
					[Security.Principal.WindowsIdentity]::GetCurrent()
				).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

				Test-ARKElevated | Should -Be $Expected

			}

		}

	}

}
