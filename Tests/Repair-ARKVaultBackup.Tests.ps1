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

Describe 'Repair-ARKVaultBackup' {

	InModuleScope 'DRJones' {

		BeforeEach {

			Mock Test-ARKElevated -MockWith { $true }

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ PSTypeName = 'DRJones.UtilityResult'; Utility = 'CAVaultManager'; ExitCode = 0; StdOut = 'Recovered'; StdErr = '' }
			}

		}

		Context 'Input' {

			It 'throws if the session is not elevated' {

				Mock Test-ARKElevated -MockWith { $false }

				{ Repair-ARKVaultBackup -Confirm:$false } | Should -Throw '*elevated session*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Recover' {

			It 'runs CAVaultManager RecoverBackupFiles' {

				Repair-ARKVaultBackup -Confirm:$false

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					$Utility -eq 'CAVaultManager' -and ($ArgumentList -join '|') -eq 'RecoverBackupFiles'
				}

			}

			It 'adds the backup pool name' {

				Repair-ARKVaultBackup -BackupPoolName 'PoolA' -Confirm:$false

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'RecoverBackupFiles|/BackupPoolName|PoolA'
				}

			}

			It 'does nothing with -WhatIf' {

				Repair-ARKVaultBackup -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the utility result' {

				$Result = Repair-ARKVaultBackup -Confirm:$false

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'

			}

		}

	}

}
