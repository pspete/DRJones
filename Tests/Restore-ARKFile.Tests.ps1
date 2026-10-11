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

Describe 'Restore-ARKFile' {

	InModuleScope 'DRJones' {

		BeforeAll {

			$Script:SavedConfig = $Script:ARKConfig

		}

		AfterAll {

			$Script:ARKConfig = $Script:SavedConfig

		}

		BeforeEach {

			$KeyFolder = New-Item -Path (Join-Path $TestDrive 'Keys') -ItemType Directory -Force
			$SafeKey = New-Item -Path (Join-Path $TestDrive 'saferecover.key') -ItemType File -Force
			$InFile =Join-Path $TestDrive 'Data\Research\*'
			$OutFolder = Join-Path $TestDrive 'Restored'

			$Script:ARKConfig = [PSCustomObject]@{
				UtilityPath = 'C:\PrivateArk\Server'
				KeyPath     = $KeyFolder.FullName
			}

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ Utility = 'Recover'; ExitCode = 0; StdOut = 'Recovered'; StdErr = '' }
			}

		}

		AfterEach {

			Remove-Item -Path $OutFolder -Recurse -Force -ErrorAction SilentlyContinue

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Path' },
				@{Parameter = 'OutputPath' }
			) {

				(Get-Command Restore-ARKFile).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Input' {

			It 'throws if no key folder is provided or configured' {

				$Script:ARKConfig.KeyPath = $null

				{ Restore-ARKFile -Path $InFile -OutputPath $OutFolder } | Should -Throw '*Recovery key folder not specified*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

			It 'throws if KeyPath does not exist' {

				{ Restore-ARKFile -Path $InFile -OutputPath $OutFolder -KeyPath (Join-Path $TestDrive 'Missing') } | Should -Throw

			}

			It 'throws if SafeRecoveryKeyPath does not exist' {

				{ Restore-ARKFile -Path $InFile -OutputPath $OutFolder -SafeRecoveryKeyPath (Join-Path $TestDrive 'missing.key') } |
					Should -Throw

			}

			It 'accepts Path from the FullName property' {

				[PSCustomObject]@{ FullName = $InFile } | Restore-ARKFile -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[0] -eq $InFile }

			}

		}

		Context 'Recover' {

			It 'runs the Recover utility' {

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $Utility -eq 'Recover' }

			}

			It 'passes file, output folder and configured key folder in order' {

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq (@($InFile, $OutFolder, $KeyFolder.FullName) -join '|')
				}

			}

			It 'uses KeyPath over the configured key folder' {

				$OtherKeys = New-Item -Path (Join-Path $TestDrive 'OtherKeys') -ItemType Directory -Force

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder -KeyPath $OtherKeys.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[2] -eq $OtherKeys.FullName }

			}

			It 'passes SafeRecoveryKeyPath as the fourth argument' {

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder -SafeRecoveryKeyPath $SafeKey.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList.Count -eq 4 -and $ArgumentList[3] -eq $SafeKey.FullName }

			}

			It 'passes three arguments without SafeRecoveryKeyPath' {

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList.Count -eq 3 }

			}

			It 'accepts positional parameters' {

				Restore-ARKFile $InFile $OutFolder $KeyFolder.FullName $SafeKey.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList.Count -eq 4 }

			}

			It 'resolves relative paths' {

				Push-Location -Path $TestDrive

				try {
					Restore-ARKFile -Path '.\Data\Research\*' -OutputPath '.\Restored' -KeyPath '.\Keys'
				} finally {
					Pop-Location
				}

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq (@($InFile, $OutFolder, $KeyFolder.FullName) -join '|')
				}

			}

			It 'creates the output folder' {

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder

				$OutFolder | Should -Exist

			}

			It 'does nothing with -WhatIf' {

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly
				$OutFolder | Should -Not -Exist

			}

		}

		Context 'Output' {

			It 'returns a DRJones.RecoveryResult' {

				$Result = Restore-ARKFile -Path $InFile -OutputPath $OutFolder

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.RecoveryResult'
				$Result.Source | Should -Be $InFile
				$Result.OutputPath | Should -Be $OutFolder
				$Result.Utility | Should -Be 'Recover'
				$Result.ExitCode | Should -Be 0
				$Result.Output | Should -Be 'Recovered'

			}

			It 'returns nothing if the utility fails' {

				Mock Invoke-ARKUtility -MockWith { }

				Restore-ARKFile -Path $InFile -OutputPath $OutFolder | Should -BeNullOrEmpty

			}

		}

	}

}
