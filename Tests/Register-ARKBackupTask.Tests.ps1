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

Describe 'Register-ARKBackupTask' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$VaultFile = New-Item -Path (Join-Path $TestDrive 'Vault.ini') -ItemType File -Force
			$LogonFile = New-Item -Path (Join-Path $TestDrive 'backup.cred') -ItemType File -Force

			Mock Test-ARKElevated -MockWith { $true }

			Mock Get-ARKUtilityPath -MockWith { 'C:\Program Files (x86)\PrivateArk\Replicate\PAReplicate.exe' }

			Mock Register-ScheduledTask -MockWith { [PSCustomObject]@{ TaskName = $TaskName; TaskPath = $TaskPath } }

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter LogonFile as mandatory' {

				(Get-Command Register-ARKBackupTask).Parameters['LogonFile'].Attributes.Mandatory | Should -Be $true

			}

			It 'throws if the session is not elevated' {

				Mock Test-ARKElevated -MockWith { $false }

				{ Register-ARKBackupTask -LogonFile $LogonFile.FullName } | Should -Throw '*elevated session*'
				Should -Invoke Register-ScheduledTask -Times 0 -Exactly

			}

			It 'rejects a task path without leading and trailing backslashes' {

				{ Register-ARKBackupTask -LogonFile $LogonFile.FullName -TaskPath 'DRJones' } | Should -Throw

			}

		}

		Context 'Registration' {

			It 'registers an incremental and a full backup task' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName

				Should -Invoke Register-ScheduledTask -Times 2 -Exactly
				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Incremental Backup' -and $TaskPath -eq '\DRJones\'
				}
				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Full Backup' -and $TaskPath -eq '\DRJones\'
				}

			}

			It 'runs PAReplicate from its folder with a credentials file' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName

				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Incremental Backup' -and
					$Action.Execute -eq 'C:\Program Files (x86)\PrivateArk\Replicate\PAReplicate.exe' -and
					$Action.WorkingDirectory -eq 'C:\Program Files (x86)\PrivateArk\Replicate' -and
					$Action.Arguments -eq (ConvertTo-ARKArgument -Value 'Vault.ini', '/LogonFromFile', $LogonFile.FullName)
				}

			}

			It 'adds the full backup switch to the full backup task' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName

				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Full Backup' -and
					$Action.Arguments -eq (ConvertTo-ARKArgument -Value 'Vault.ini', '/LogonFromFile', $LogonFile.FullName, '/FullBackup')
				}

			}

			It 'passes the Vault file and backup pool' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName -VaultFile $VaultFile.FullName -BackupPoolName 'PoolA'

				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Incremental Backup' -and
					$Action.Arguments -eq (ConvertTo-ARKArgument -Value $VaultFile.FullName, '/LogonFromFile', $LogonFile.FullName, '/BackupPoolName', 'PoolA')
				}

			}

			It 'runs as SYSTEM with highest privileges' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName

				Should -Invoke Register-ScheduledTask -Times 2 -Exactly -ParameterFilter {
					$Principal.UserId -like '*SYSTEM' -and
					"$($Principal.RunLevel)" -eq 'Highest'
				}

			}

			It 'runs the full backup on Sunday and the incremental backup on the other days by default' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName

				#DaysOfWeek bitmask: Sunday 1, Monday 2 ... Saturday 64
				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Full Backup' -and $Trigger.DaysOfWeek -eq 1
				}
				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Incremental Backup' -and $Trigger.DaysOfWeek -eq 126
				}

			}

			It 'runs the full backup on the given day' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName -FullBackupDay Saturday

				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Full Backup' -and $Trigger.DaysOfWeek -eq 64
				}
				Should -Invoke Register-ScheduledTask -Times 1 -Exactly -ParameterFilter {
					$TaskName -eq 'PAReplicate Incremental Backup' -and $Trigger.DaysOfWeek -eq 63
				}

			}

			It 'runs at the given local time' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName -At '22:30'

				Should -Invoke Register-ScheduledTask -Times 2 -Exactly -ParameterFilter {
					$Trigger.StartBoundary -like '*T22:30:00'
				}

			}

			It 'uses the given task path' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName -TaskPath '\CyberArk\Backup\'

				Should -Invoke Register-ScheduledTask -Times 2 -Exactly -ParameterFilter { $TaskPath -eq '\CyberArk\Backup\' }

			}

			It 'does nothing with -WhatIf' {

				Register-ARKBackupTask -LogonFile $LogonFile.FullName -WhatIf

				Should -Invoke Register-ScheduledTask -Times 0 -Exactly

			}

		}

		Context 'Output' {

			It 'returns the registered tasks' {

				$Result = Register-ARKBackupTask -LogonFile $LogonFile.FullName

				$Result.TaskName | Should -Be 'PAReplicate Incremental Backup', 'PAReplicate Full Backup'

			}

		}

	}

}
