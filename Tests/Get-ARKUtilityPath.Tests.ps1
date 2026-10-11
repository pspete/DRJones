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

Describe 'Get-ARKUtilityPath' {

	InModuleScope 'DRJones' {

		BeforeAll {

			$Script:SavedConfig = $Script:ARKConfig

		}

		AfterAll {

			$Script:ARKConfig = $Script:SavedConfig

		}

		BeforeEach {

			$Script:ARKConfig = [PSCustomObject]@{
				UtilityPath = 'C:\PrivateArk\Server'
				KeyPath     = 'C:\Keys'
			}

			Mock Test-Path -MockWith { $true }

		}

		Context 'Mandatory Parameters' {

			It 'only accepts supported utilities' {

				{ Get-ARKUtilityPath -Utility PACLI } | Should -Throw

			}

		}

		Context 'Output' {

			It 'returns the path to <Utility>.exe' -TestCases @(
				@{Utility = 'Recover' },
				@{Utility = 'SafeRecover' },
				@{Utility = 'PARestore' },
				@{Utility = 'PAReplicate' },
				@{Utility = 'CAVaultManager' }
			) {

				Get-ARKUtilityPath -Utility $Utility | Should -BeExactly "C:\PrivateArk\Server\$Utility.exe"

			}

			It 'returns the path from the first configured folder that contains the utility' {

				$Script:ARKConfig.UtilityPath = 'C:\PrivateArk\Server', 'C:\Program Files (x86)\PrivateArk\Replicate'

				Mock Test-Path -MockWith { $Path -like '*\Replicate\PAReplicate.exe' }

				Get-ARKUtilityPath -Utility PAReplicate | Should -BeExactly 'C:\Program Files (x86)\PrivateArk\Replicate\PAReplicate.exe'

			}

			It 'throws if the utility folder is not set' {

				$Script:ARKConfig.UtilityPath = $null

				{ Get-ARKUtilityPath -Utility PAReplicate } | Should -Throw '*Run Set-ARKConfiguration*'

			}

			It 'throws if the utility is not found' {

				Mock Test-Path -MockWith { $false }

				{ Get-ARKUtilityPath -Utility PAReplicate } | Should -Throw '*PAReplicate.exe not found in C:\PrivateArk\Server*'

			}

		}

	}

}
