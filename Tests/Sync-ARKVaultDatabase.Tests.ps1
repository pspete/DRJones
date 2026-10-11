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

Describe 'Sync-ARKVaultDatabase' {

	InModuleScope 'DRJones' {

		BeforeEach {

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ PSTypeName = 'DRJones.UtilityResult'; Utility = 'CAVaultManager'; ExitCode = 0; StdOut = 'Synchronized'; StdErr = '' }
			}

		}

		Context 'Simulate' {

			It 'runs CAVaultManager SynchronizeDB with Force and without Update' {

				Sync-ARKVaultDatabase

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					$Utility -eq 'CAVaultManager' -and ($ArgumentList -join '|') -eq 'SynchronizeDB|/Force'
				}

			}

			It 'simulates without confirmation' {

				Sync-ARKVaultDatabase -Confirm

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly

			}

			It 'adds the Safe pattern and sync switches' {

				Sync-ARKVaultDatabase 'Fin*' -FilesSyncOnly -QuotaSyncOnly

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'SynchronizeDB|/SafePattern|Fin*|/FilesSyncOnly|/QuotaSyncOnly|/Force'
				}

			}

		}

		Context 'Update' {

			It 'adds the Update switch' {

				Sync-ARKVaultDatabase -Update -Confirm:$false

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'SynchronizeDB|/Update|/Force'
				}

			}

			It 'does nothing with -Update -WhatIf' {

				Sync-ARKVaultDatabase -Update -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the utility result' {

				$Result = Sync-ARKVaultDatabase

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'

			}

		}

	}

}
