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

Describe 'Get-ARKVaultParameter' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$IniFile = Join-Path $TestDrive 'DBParm.ini'

			[System.IO.File]::WriteAllText($IniFile, "[MAIN]`r`nRecoveryPrvKey=D:\recprv.key`r`nRecoveryPubKey=D:\recpub.key`r`n`r`n[BACKUP]`r`nBackupFilesDeletion=No`r`n")

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter Path as mandatory' {

				(Get-Command Get-ARKVaultParameter).Parameters['Path'].Attributes.Mandatory | Should -Be $true

			}

			It 'throws if the file does not exist' {

				{ Get-ARKVaultParameter -Path (Join-Path $TestDrive 'Missing.ini') } | Should -Throw

			}

		}

		Context 'Output' {

			It 'returns every parameter by default' {

				$Result = Get-ARKVaultParameter -Path $IniFile

				$Result.Name | Should -Be 'RecoveryPrvKey', 'RecoveryPubKey', 'BackupFilesDeletion'
				$Result[0].PSObject.TypeNames[0] | Should -Be 'DRJones.VaultParameter'
				$Result[0].Section | Should -Be 'MAIN'
				$Result[0].Value | Should -Be 'D:\recprv.key'
				$Result[0].Path | Should -Be $IniFile

			}

			It 'filters by name, with wildcards' {

				(Get-ARKVaultParameter -Path $IniFile -Name 'Recovery*').Name | Should -Be 'RecoveryPrvKey', 'RecoveryPubKey'
				(Get-ARKVaultParameter BackupFilesDeletion -Path $IniFile).Value | Should -Be 'No'

			}

			It 'filters by section' {

				(Get-ARKVaultParameter -Path $IniFile -Section BACKUP).Name | Should -Be 'BackupFilesDeletion'

			}

			It 'returns nothing when no parameter matches' {

				Get-ARKVaultParameter -Path $IniFile -Name 'Missing' | Should -BeNullOrEmpty

			}

			It 'accepts files from the pipeline' {

				(Get-Item -Path $IniFile | Get-ARKVaultParameter -Name BackupFilesDeletion).Path | Should -Be $IniFile

			}

			It 'resolves a relative path' {

				Push-Location -Path $TestDrive
				try {
					(Get-ARKVaultParameter -Path '.\DBParm.ini' -Name BackupFilesDeletion).Path | Should -Be $IniFile
				} finally {
					Pop-Location
				}

			}

		}

	}

}
