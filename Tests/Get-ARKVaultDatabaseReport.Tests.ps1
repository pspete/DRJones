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

Describe 'Get-ARKVaultDatabaseReport' {

	InModuleScope 'DRJones' {

		BeforeEach {

			Mock Test-ARKElevated -MockWith { $true }

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ PSTypeName = 'DRJones.UtilityResult'; Utility = 'CAVaultManager'; ExitCode = 0; StdOut = 'Report'; StdErr = '' }
			}

		}

		It 'throws if the session is not elevated' {

			Mock Test-ARKElevated -MockWith { $false }

			{ Get-ARKVaultDatabaseReport } | Should -Throw '*elevated session*'
			Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

		}

		It 'runs CAVaultManager DiagnoseDBReport' {

			Get-ARKVaultDatabaseReport

			Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
				$Utility -eq 'CAVaultManager' -and ($ArgumentList -join '|') -eq 'DiagnoseDBReport'
			}

		}

		It 'returns the utility result' {

			$Result = Get-ARKVaultDatabaseReport

			$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'
			$Result.StdOut | Should -Be 'Report'

		}

	}

}
