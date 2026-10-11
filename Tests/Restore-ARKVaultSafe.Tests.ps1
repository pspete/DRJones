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

Describe 'Restore-ARKVaultSafe' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$Credential = [pscredential]::new('Operator', [System.Net.NetworkCredential]::new('', 'Secret1').SecurePassword)
			$VaultFile = New-Item -Path (Join-Path $TestDrive 'Vault.ini') -ItemType File -Force
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

				(Get-Command Restore-ARKVaultSafe).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Input' {

			It 'throws if DataOnly and MetadataOnly are both specified' {

				{ Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -DataOnly -MetadataOnly } |
					Should -Throw '*cannot be used together*'
				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

			It 'throws if VaultFile does not exist' {

				{ Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -VaultFile (Join-Path $TestDrive 'Missing.ini') } |
					Should -Throw

			}

			It 'throws if LogonFile does not exist' {

				{ Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -LogonFile (Join-Path $TestDrive 'Missing.cred') } |
					Should -Throw

			}

			It 'accepts Safe from the SafeName property' {

				[PSCustomObject]@{ SafeName = 'Banners'; TargetSafe = 'Banners_R' } | Restore-ARKVaultSafe -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[3] -eq 'Banners' }

			}

		}

		Context 'Restore' {

			It 'runs the PARestore utility' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $Utility -eq 'PARestore' }

			}

			It 'passes Vault file, logon, Safe and target Safe in order' {

				Restore-ARKVaultSafe 'Banners' 'Banners_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'Vault.ini|Operator/Secret1|/RestoreSafe|Banners|/TargetSafe|Banners_R'
				}

			}

			It 'marks the password as sensitive' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $SensitiveValue -eq 'Secret1' }

			}

			It 'logs on from a file' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -LogonFile $LogonFile.FullName -VaultFile $VaultFile.FullName

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq "$($VaultFile.FullName)|/LogonFromFile|$($LogonFile.FullName)|/RestoreSafe|Banners|/TargetSafe|Banners_R" -and
					-not $SensitiveValue
				}

			}

			It 'adds the backup pool name' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -BackupPoolName 'PoolA'

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'Vault.ini|Operator/Secret1|/BackupPoolName|PoolA|/RestoreSafe|Banners|/TargetSafe|Banners_R'
				}

			}

			It 'adds the <Switch> switch' -TestCases @(
				@{Switch = 'DataOnly' },
				@{Switch = 'MetadataOnly' }
			) {

				$Parameters = @{ Safe = 'Banners'; TargetSafe = 'Banners_R'; Credential = $Credential; $Switch = $true }

				Restore-ARKVaultSafe @Parameters

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter { $ArgumentList[-1] -eq "/$Switch" }

			}

			It 'adds the LoadOnly switch before the Safe' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -LoadOnly

				Should -Invoke Invoke-ARKUtility -Times 1 -Exactly -ParameterFilter {
					($ArgumentList -join '|') -eq 'Vault.ini|Operator/Secret1|/LoadOnly|/RestoreSafe|Banners|/TargetSafe|Banners_R'
				}

			}

			It 'does nothing with -WhatIf' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -WhatIf

				Should -Invoke Invoke-ARKUtility -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the utility result' {

				$Result = Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'
				$Result.StdOut | Should -Be 'Restored'

			}

			It 'warns for each Safe owner removed from the target Safe' {

				Mock Invoke-ARKUtility -MockWith {
					[PSCustomObject]@{
						PSTypeName = 'DRJones.UtilityResult'; Utility = 'PARestore'; ExitCode = 0; StdErr = ''
						StdOut     = "Restoring`r`nITATS658W Backed-up Safe owner User1 (user id 2) will be removed from Safe Banners_R.`r`nITATS658W Backed-up Safe owner User2 (user id 3) will be removed from Safe Banners_R.`r`nDone"
					}
				}

				$Result = Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -WarningVariable Warnings -WarningAction SilentlyContinue

				$Warnings.Count | Should -Be 2
				$Warnings[0].Message | Should -Be 'ITATS658W Backed-up Safe owner User1 (user id 2) will be removed from Safe Banners_R.'
				$Result.ExitCode | Should -Be 0

			}

			It 'does not warn when no Safe owner is removed' {

				Restore-ARKVaultSafe -Safe 'Banners' -TargetSafe 'Banners_R' -Credential $Credential -WarningVariable Warnings -WarningAction SilentlyContinue

				$Warnings.Count | Should -Be 0

			}

		}

	}

}
