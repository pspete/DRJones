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

Describe 'Restore-ARKSafe' {

	InModuleScope 'DRJones' {

		BeforeAll {

			$Script:SavedConfig = $Script:ARKConfig

		}

		AfterAll {

			$Script:ARKConfig = $Script:SavedConfig

		}

		BeforeEach {

			$KeyFolder = New-Item -Path (Join-Path $TestDrive 'MasterKey') -ItemType Directory -Force
			$OutFolder = Join-Path $TestDrive 'Research'

			$Script:ARKConfig = [PSCustomObject]@{
				UtilityPath = 'C:\PrivateArk\Server'
				KeyPath     = $KeyFolder.FullName
			}

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ Utility = 'SafeRecover'; ExitCode = 0; StdOut = 'Recovered'; StdErr = '' }
			}

			Mock Get-Service -MockWith { }

			Mock Test-ARKElevated -MockWith { $true }

		}

		AfterEach {

			Remove-Item -Path $OutFolder -Recurse -Force -ErrorAction SilentlyContinue

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Safe' },
				@{Parameter = 'OutputPath' }
			) {

				(Get-Command Restore-ARKSafe).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Input' {

			It 'throws if no key folder is provided or configured' {

				$Script:ARKConfig.KeyPath = $null

				{ Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder } | Should -Throw '*Recovery key folder not specified*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

			It 'throws if the session is not elevated' {

				Mock Test-ARKElevated -MockWith { $false }

				{ Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder } | Should -Throw '*elevated session*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

			It 'throws if KeyPath does not exist' {

				{ Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder -KeyPath (Join-Path $TestDrive 'Missing') } | Should -Throw

			}

			It 'accepts Safe from the SafeName property' {

				[PSCustomObject]@{ SafeName = 'Research' } | Restore-ARKSafe -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[0] -eq 'Research' }

			}

		}

		Context 'Recover' {

			It 'runs the SafeRecover utility' {

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $Utility -eq 'SafeRecover' }

			}

			It 'passes Safe, output folder and configured key folder in order' {

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq (@('Research', $OutFolder, $KeyFolder.FullName) -join '|')
				}

			}

			It 'passes a wildcard Safe name unchanged' {

				Restore-ARKSafe -Safe 'Res*' -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[0] -eq 'Res*' }

			}

			It 'uses KeyPath over the configured key folder' {

				$OtherKeys = New-Item -Path (Join-Path $TestDrive 'OtherKeys') -ItemType Directory -Force

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder -KeyPath $OtherKeys.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[2] -eq $OtherKeys.FullName }

			}

			It 'accepts positional parameters' {

				Restore-ARKSafe 'Research' $OutFolder $KeyFolder.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList.Count -eq 3 }

			}

			It 'resolves relative paths' {

				Push-Location -Path $TestDrive

				try {
					Restore-ARKSafe -Safe 'Research' -OutputPath '.\Research' -KeyPath '.\MasterKey'
				} finally {
					Pop-Location
				}

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq (@('Research', $OutFolder, $KeyFolder.FullName) -join '|')
				}

			}

			It 'throws if the PrivateArk Server service is running' {

				Mock Get-Service -MockWith { [PSCustomObject]@{ Name = 'PrivateArk Server'; Status = 'Running' } }

				{ Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder } | Should -Throw '*PrivateArk Server service is running*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

			It 'runs if the PrivateArk Server service is stopped' {

				Mock Get-Service -MockWith { [PSCustomObject]@{ Name = 'PrivateArk Server'; Status = 'Stopped' } }

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly

			}

			It 'creates the output folder' {

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder

				$OutFolder | Should -Exist

			}

			It 'does nothing with -WhatIf' {

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly
				$OutFolder | Should -Not -Exist

			}

		}

		Context 'Output' {

			It 'returns a DRJones.RecoveryResult' {

				$Result = Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.RecoveryResult'
				$Result.Source | Should -Be 'Research'
				$Result.OutputPath | Should -Be $OutFolder
				$Result.Utility | Should -Be 'SafeRecover'
				$Result.ExitCode | Should -Be 0
				$Result.Output | Should -Be 'Recovered'

			}

			It 'returns nothing if the utility fails' {

				Mock Invoke-ARKUtility -MockWith { }

				Restore-ARKSafe -Safe 'Research' -OutputPath $OutFolder | Should -BeNullOrEmpty

			}

		}

	}

}
