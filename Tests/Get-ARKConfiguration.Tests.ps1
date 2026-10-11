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

Describe 'Get-ARKConfiguration' {

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

		}

		Context 'Output' {

			It 'returns the configured UtilityPath' {

				(Get-ARKConfiguration).UtilityPath | Should -Be 'C:\PrivateArk\Server'

			}

			It 'returns the configured KeyPath' {

				(Get-ARKConfiguration).KeyPath | Should -Be 'C:\Keys'

			}

			It 'returns only UtilityPath and KeyPath' {

				(Get-ARKConfiguration).PSObject.Properties.Name | Should -Be @('UtilityPath', 'KeyPath')

			}

			It 'returns a copy of the configuration' {

				$Config = Get-ARKConfiguration
				$Config.KeyPath = 'D:\Other'

				$Script:ARKConfig.KeyPath | Should -Be 'C:\Keys'

			}

		}

	}

}
