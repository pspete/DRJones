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

Describe 'Restore-ARKRecordingSafe' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$Credential = [pscredential]::new('Operator', [System.Net.NetworkCredential]::new('', 'Secret1').SecurePassword)
			$LogonFile = New-Item -Path (Join-Path $TestDrive 'Operator.cred') -ItemType File -Force

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ PSTypeName = 'DRJones.UtilityResult'; Utility = 'PARestore'; ExitCode = 0; StdOut = 'Restored'; StdErr = '' }
			}

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Safe' },
				@{Parameter = 'TargetSafe' },
				@{Parameter = 'Credential' },
				@{Parameter = 'LogonFile' }
			) {

				(Get-Command Restore-ARKRecordingSafe).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Input' {

			It 'throws if Retention is <Retention>' -TestCases @(
				@{Retention = 0 },
				@{Retention = 91 }
			) {

				{ Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential -Retention $Retention } |
					Should -Throw

			}

			It 'throws if an owner contains a backslash' {

				{ Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential -Owners 'A\B' } |
					Should -Throw

			}

		}

		Context 'Restore' {

			It 'runs the PARestore utility' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $Utility -eq 'PARestore' }

			}

			It 'runs PARestore interactively so the user answers its prompts' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $Interactive }

			}

			It 'passes Vault file, logon, recordings switch, Safe and target Safe in order' {

				Restore-ARKRecordingSafe 'PSMRecordings' 'PSMRecordings_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'Vault.ini|Operator/Secret1|/RestoreRecordings|/RestoreSafe|PSMRecordings|/TargetSafe|PSMRecordings_R' -and
					$SensitiveValue -eq 'Secret1'
				}

			}

			It 'logs on from a file' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -LogonFile $LogonFile.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList[0..2] -join '|') -eq "Vault.ini|/LogonFromFile|$($LogonFile.FullName)"
				}

			}

			It 'joins owners with a backslash' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential -Owners 'Auditors', 'Vault Admins'

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList[-2..-1] -join '|') -eq '/Owners|Auditors\Vault Admins'
				}

			}

			It 'adds the retention period' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential -Retention 30

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList[-2..-1] -join '|') -eq '/Retention|30'
				}

			}

			It 'does not add owners or retention by default' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					$ArgumentList -notcontains '/Owners' -and $ArgumentList -notcontains '/Retention'
				}

			}

			It 'does nothing with -WhatIf' {

				Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the utility result' {

				$Result = Restore-ARKRecordingSafe -Safe 'PSMRecordings' -TargetSafe 'PSMRecordings_R' -Credential $Credential

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'

			}

		}

	}

}
