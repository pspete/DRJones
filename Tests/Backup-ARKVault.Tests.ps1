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

Describe 'Backup-ARKVault' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$Credential = [pscredential]::new('Backup', [System.Net.NetworkCredential]::new('', 'Secret1').SecurePassword)
			$VaultFile = New-Item -Path (Join-Path $TestDrive 'Vault.ini') -ItemType File -Force
			$LogonFile = New-Item -Path (Join-Path $TestDrive 'backup.cred') -ItemType File -Force

			Mock Invoke-ARKUtility -MockWith {
				[PSCustomObject]@{ PSTypeName = 'DRJones.UtilityResult'; Utility = 'PAReplicate'; ExitCode = 0; StdOut = 'Backed up'; StdErr = '' }
			}

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Credential' },
				@{Parameter = 'LogonFile' }
			) {

				(Get-Command Backup-ARKVault).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Backup' {

			It 'runs a full backup with a credentials file' {

				Backup-ARKVault -LogonFile $LogonFile.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					$Utility -eq 'PAReplicate' -and
					($ArgumentList -join '|') -eq "Vault.ini|/LogonFromFile|$($LogonFile.FullName)|/FullBackup"
				}

			}

			It 'runs an incremental backup' {

				Backup-ARKVault -LogonFile $LogonFile.FullName -Incremental

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq "Vault.ini|/LogonFromFile|$($LogonFile.FullName)"
				}

			}

			It 'passes the Vault file and backup pool' {

				Backup-ARKVault -LogonFile $LogonFile.FullName -VaultFile $VaultFile.FullName -BackupPoolName 'PoolA'

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq "$($VaultFile.FullName)|/LogonFromFile|$($LogonFile.FullName)|/BackupPoolName|PoolA|/FullBackup"
				}

			}

			It 'logs on with a credential, masking the password' {

				Backup-ARKVault -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'Vault.ini|Backup/Secret1|/FullBackup' -and
					$SensitiveValue -eq 'Secret1'
				}

			}

			It 'does nothing with -WhatIf' {

				Backup-ARKVault -LogonFile $LogonFile.FullName -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the utility result' {

				$Result = Backup-ARKVault -LogonFile $LogonFile.FullName

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'

			}

		}

	}

}
