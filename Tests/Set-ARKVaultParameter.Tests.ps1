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

Describe 'Set-ARKVaultParameter' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$IniFile = Join-Path $TestDrive 'DBParm.ini'

			[System.IO.File]::WriteAllText($IniFile, "[MAIN]`r`nRecoveryPrvKey = C:\Keys\recprv.key`r`n`r`n[BACKUP]`r`nBackupFilesDeletion=Yes,24,1,5,7d`r`n`r`n[CACHE]`r`nCacheSize=1`r`n")

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Path' },
				@{Parameter = 'Name' },
				@{Parameter = 'Value' }
			) {

				(Get-Command Set-ARKVaultParameter).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

			It 'rejects a value containing a line break' {

				{ Set-ARKVaultParameter -Path $IniFile -Name ADDRESS -Value "1`r`n2" } | Should -Throw

			}

			It 'rejects an invalid name' {

				{ Set-ARKVaultParameter -Path $IniFile -Name 'A=B' -Value 1 } | Should -Throw

			}

		}

		Context 'Update' {

			It 'changes an existing value, keeping the line format' {

				Set-ARKVaultParameter -Path $IniFile -Name RecoveryPrvKey -Value 'D:\recprv.key'

				(Get-Content -Path $IniFile)[1] | Should -BeExactly 'RecoveryPrvKey = D:\recprv.key'

			}

			It 'matches the name case-insensitively' {

				Set-ARKVaultParameter -Path $IniFile -Name backupfilesdeletion -Value No

				(Get-Content -Path $IniFile)[4] | Should -BeExactly 'BackupFilesDeletion=No'

			}

			It 'leaves other lines unchanged' {

				Set-ARKVaultParameter -Path $IniFile -Name BackupFilesDeletion -Value No

				[System.IO.File]::ReadAllText($IniFile) |
					Should -BeExactly "[MAIN]`r`nRecoveryPrvKey = C:\Keys\recprv.key`r`n`r`n[BACKUP]`r`nBackupFilesDeletion=No`r`n`r`n[CACHE]`r`nCacheSize=1`r`n"

			}

			It 'sets an empty value' {

				Set-ARKVaultParameter -Path $IniFile -Name CacheSize -Value ''

				(Get-Content -Path $IniFile)[7] | Should -BeExactly 'CacheSize='

			}

		}

		Context 'Add' {

			It 'adds a parameter to the end of an existing section' {

				Set-ARKVaultParameter -Path $IniFile -Name RecoveryPubKey -Value 'D:\recpub.key' -Section MAIN

				(Get-Content -Path $IniFile)[1..3] | Should -BeExactly 'RecoveryPrvKey = C:\Keys\recprv.key', 'RecoveryPubKey=D:\recpub.key', ''

			}

			It 'adds a parameter to the last section' {

				Set-ARKVaultParameter -Path $IniFile -Name CacheTime -Value 5 -Section CACHE

				[System.IO.File]::ReadAllText($IniFile) | Should -BeLike "*`r`nCacheSize=1`r`nCacheTime=5`r`n"

			}

			It 'adds a new section' {

				Set-ARKVaultParameter -Path $IniFile -Name Level -Value 1 -Section LOG

				[System.IO.File]::ReadAllText($IniFile) | Should -BeLike "*`r`nCacheSize=1`r`n``[LOG``]`r`nLevel=1`r`n"

			}

			It 'updates an existing parameter wherever it is, without adding it to the section' {

				Set-ARKVaultParameter -Path $IniFile -Name BackupFilesDeletion -Value No -Section MAIN

				$Content = Get-Content -Path $IniFile
				@($Content | Where-Object { $_ -like 'BackupFilesDeletion*' }) | Should -BeExactly 'BackupFilesDeletion=No'
				$Content[4] | Should -BeExactly 'BackupFilesDeletion=No'

			}

			It 'throws if a file with sections does not contain the parameter and no section is given' {

				{ Set-ARKVaultParameter -Path $IniFile -Name Missing -Value 1 } | Should -Throw '*Specify -Section*'

			}

			It 'adds a parameter to the end of a file without sections' {

				[System.IO.File]::WriteAllText($IniFile, "VAULT=`"Vault`"`r`nADDRESS=10.0.0.1`r`n")

				Set-ARKVaultParameter -Path $IniFile -Name PORT -Value 1858

				[System.IO.File]::ReadAllText($IniFile) | Should -BeExactly "VAULT=`"Vault`"`r`nADDRESS=10.0.0.1`r`nPORT=1858`r`n"

			}

			It 'adds a parameter to an empty file' {

				[System.IO.File]::WriteAllText($IniFile, '')

				Set-ARKVaultParameter -Path $IniFile -Name ADDRESS -Value 10.0.0.1

				[System.IO.File]::ReadAllText($IniFile) | Should -BeExactly "ADDRESS=10.0.0.1`r`n"

			}

		}

		Context 'Encoding' {

			It 'keeps the bytes of a file without a byte order mark' {

				[System.IO.File]::WriteAllBytes($IniFile, [byte[]](0x41, 0x3D, 0xE9, 0x0D, 0x0A, 0x42, 0x3D, 0x31))

				Set-ARKVaultParameter -Path $IniFile -Name B -Value 2

				[System.IO.File]::ReadAllBytes($IniFile) | Should -Be 0x41, 0x3D, 0xE9, 0x0D, 0x0A, 0x42, 0x3D, 0x32

			}

			It 'keeps the byte order mark of a UTF-8 file' {

				[System.IO.File]::WriteAllText($IniFile, 'A=1', [System.Text.UTF8Encoding]::new($true))

				Set-ARKVaultParameter -Path $IniFile -Name A -Value 2

				[System.IO.File]::ReadAllBytes($IniFile) | Should -Be 0xEF, 0xBB, 0xBF, 0x41, 0x3D, 0x32

			}

		}

		Context 'ShouldProcess' {

			It 'does not change the file with -WhatIf' {

				$Before = [System.IO.File]::ReadAllText($IniFile)

				Set-ARKVaultParameter -Path $IniFile -Name BackupFilesDeletion -Value No -WhatIf

				[System.IO.File]::ReadAllText($IniFile) | Should -BeExactly $Before

			}

			It 'returns no output' {

				Set-ARKVaultParameter -Path $IniFile -Name BackupFilesDeletion -Value No | Should -BeNullOrEmpty

			}

		}

	}

}
