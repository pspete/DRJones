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

Describe 'Set-ARKConfiguration' {

	InModuleScope 'DRJones' {

		BeforeAll {

			$Script:SavedConfig = $Script:ARKConfig
			$Script:SavedConfigFile = $Script:ARKConfigFile

		}

		AfterAll {

			$Script:ARKConfig = $Script:SavedConfig
			$Script:ARKConfigFile = $Script:SavedConfigFile

		}

		BeforeEach {

			$Script:ARKConfigFile = Join-Path $TestDrive 'DRJonesConfiguration.xml'
			$Script:ARKConfig = [PSCustomObject]@{ UtilityPath = $null; KeyPath = $null }

			$UtilityFolder = New-Item -Path (Join-Path $TestDrive 'Server') -ItemType Directory -Force
			$KeyFolder = New-Item -Path (Join-Path $TestDrive 'Keys') -ItemType Directory -Force

		}

		AfterEach {

			Remove-Item -Path $Script:ARKConfigFile -Force -ErrorAction SilentlyContinue

		}

		Context 'Input' {

			It 'throws if UtilityPath does not exist' {

				{ Set-ARKConfiguration -UtilityPath (Join-Path $TestDrive 'Missing') } | Should -Throw

			}

			It 'throws if KeyPath does not exist' {

				{ Set-ARKConfiguration -KeyPath (Join-Path $TestDrive 'Missing') } | Should -Throw

			}

			It 'throws if UtilityPath is a file' {

				$File = New-Item -Path (Join-Path $TestDrive 'Recover.exe') -ItemType File -Force

				{ Set-ARKConfiguration -UtilityPath $File.FullName } | Should -Throw

			}

		}

		Context 'Configuration' {

			It 'sets UtilityPath' {

				Set-ARKConfiguration -UtilityPath $UtilityFolder.FullName

				$Script:ARKConfig.UtilityPath | Should -Be $UtilityFolder.FullName

			}

			It 'sets multiple UtilityPath folders in order' {

				$ReplicatorFolder = New-Item -Path (Join-Path $TestDrive 'Replicator') -ItemType Directory -Force

				Set-ARKConfiguration -UtilityPath $ReplicatorFolder.FullName, $UtilityFolder.FullName

				$Script:ARKConfig.UtilityPath | Should -Be @($ReplicatorFolder.FullName, $UtilityFolder.FullName)

				(Import-Clixml -Path $Script:ARKConfigFile).UtilityPath | Should -Be @($ReplicatorFolder.FullName, $UtilityFolder.FullName)

			}

			It 'throws if any UtilityPath folder does not exist' {

				{ Set-ARKConfiguration -UtilityPath $UtilityFolder.FullName, (Join-Path $TestDrive 'Missing') } | Should -Throw

			}

			It 'sets KeyPath' {

				Set-ARKConfiguration -KeyPath $KeyFolder.FullName

				$Script:ARKConfig.KeyPath | Should -Be $KeyFolder.FullName

			}

			It 'keeps the existing value of a parameter not provided' {

				Set-ARKConfiguration -UtilityPath $UtilityFolder.FullName
				Set-ARKConfiguration -KeyPath $KeyFolder.FullName

				$Script:ARKConfig.UtilityPath | Should -Be $UtilityFolder.FullName
				$Script:ARKConfig.KeyPath | Should -Be $KeyFolder.FullName

			}

			It 'resolves a relative path' {

				Push-Location -Path $TestDrive

				try {
					Set-ARKConfiguration -KeyPath '.\Keys'
				} finally {
					Pop-Location
				}

				$Script:ARKConfig.KeyPath | Should -Be $KeyFolder.FullName

			}

			It 'saves the configuration file' {

				Set-ARKConfiguration -UtilityPath $UtilityFolder.FullName -KeyPath $KeyFolder.FullName

				$Saved = Import-Clixml -Path $Script:ARKConfigFile

				$Saved.UtilityPath | Should -Be $UtilityFolder.FullName
				$Saved.KeyPath | Should -Be $KeyFolder.FullName

			}

			It 'changes nothing with -WhatIf' {

				Set-ARKConfiguration -UtilityPath $UtilityFolder.FullName -WhatIf

				$Script:ARKConfig.UtilityPath | Should -BeNullOrEmpty
				$Script:ARKConfigFile | Should -Not -Exist

			}

		}

	}

}
