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

Describe 'Restore-ARKVault' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$Credential = [pscredential]::new('Operator', [System.Net.NetworkCredential]::new('', 'Secret1').SecurePassword)
			$VaultFile = New-Item -Path (Join-Path $TestDrive 'Vault.ini') -ItemType File -Force
			$LogonFile = New-Item -Path (Join-Path $TestDrive 'Operator.cred') -ItemType File -Force

			Mock Test-ARKElevated -MockWith { $true }

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ PSTypeName = 'DRJones.UtilityResult'; Utility = 'PARestore'; ExitCode = 0; StdOut = 'Restored'; StdErr = '' }
			}

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Credential' },
				@{Parameter = 'LogonFile' }
			) {

				(Get-Command Restore-ARKVault).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

			It 'has a high confirm impact' {

				(Get-Command Restore-ARKVault).ScriptBlock.Attributes |
					Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] } |
					Select-Object -ExpandProperty ConfirmImpact | Should -Be 'High'

			}

			It 'throws if the session is not elevated' {

				Mock Test-ARKElevated -MockWith { $false }

				{ Restore-ARKVault -Credential $Credential -Confirm:$false } | Should -Throw '*elevated session*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Restore' {

			It 'runs PARestore with the full Vault restore switch' {

				Restore-ARKVault -Credential $Credential -Confirm:$false

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					$Utility -eq 'PARestore' -and
					($ArgumentList -join '|') -eq 'Vault.ini|Operator/Secret1|/FullVaultRestore' -and
					$SensitiveValue -eq 'Secret1'
				}

			}

			It 'logs on from a file with a Vault file and backup pool' {

				Restore-ARKVault -LogonFile $LogonFile.FullName -VaultFile $VaultFile.FullName -BackupPoolName 'PoolA' -Confirm:$false

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq "$($VaultFile.FullName)|/LogonFromFile|$($LogonFile.FullName)|/BackupPoolName|PoolA|/FullVaultRestore"
				}

			}

			It 'adds the FromRestored switch' {

				Restore-ARKVault -Credential $Credential -FromRestored -Confirm:$false

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[-1] -eq '/FromRestored' }

			}

			It 'does nothing with -WhatIf' {

				Restore-ARKVault -Credential $Credential -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the utility result' {

				$Result = Restore-ARKVault -Credential $Credential -Confirm:$false

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'

			}

		}

	}

}
