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

Describe 'Assert-ARKElevated' {

	InModuleScope 'DRJones' {

		It 'does nothing in an elevated session' {

			Mock Test-ARKElevated -MockWith { $true }

			{ Assert-ARKElevated -Operation 'CAVaultManager RestoreDB' } | Should -Not -Throw

		}

		It 'throws, naming the operation, if the session is not elevated' {

			Mock Test-ARKElevated -MockWith { $false }

			{ Assert-ARKElevated -Operation 'CAVaultManager RestoreDB' } |
				Should -Throw 'CAVaultManager RestoreDB must run in an elevated session. Run PowerShell as Administrator.'

		}

	}

}
