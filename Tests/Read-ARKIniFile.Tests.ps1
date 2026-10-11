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

Describe 'Read-ARKIniFile' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$IniFile = Join-Path $TestDrive 'DBParm.ini'

		}

		Context 'Parameters' {

			It 'returns parameters with their section, name, value and line' {

				[System.IO.File]::WriteAllText($IniFile, "[MAIN]`r`nRecoveryPrvKey = D:\recprv.key`r`n`r`n[BACKUP]`r`nBackupFilesDeletion=Yes,24,1,5,7d`r`n")

				$Ini = Read-ARKIniFile -Path $IniFile

				$Ini.Parameters.Count | Should -Be 2
				$Ini.Parameters[0].Section | Should -Be 'MAIN'
				$Ini.Parameters[0].Name | Should -Be 'RecoveryPrvKey'
				$Ini.Parameters[0].Value | Should -Be 'D:\recprv.key'
				$Ini.Parameters[0].Index | Should -Be 1
				$Ini.Parameters[0].Prefix | Should -Be 'RecoveryPrvKey = '
				$Ini.Parameters[1].Section | Should -Be 'BACKUP'
				$Ini.Parameters[1].Value | Should -Be 'Yes,24,1,5,7d'
				$Ini.Sections | Should -Be 2

			}

			It 'returns parameters without a section' {

				[System.IO.File]::WriteAllText($IniFile, "VAULT = `"Vault`"`r`nADDRESS=10.0.0.1`r`n")

				$Ini = Read-ARKIniFile -Path $IniFile

				$Ini.Parameters.Name | Should -Be 'VAULT', 'ADDRESS'
				$Ini.Parameters[0].Value | Should -Be '"Vault"'
				$Ini.Parameters[0].Section | Should -BeNullOrEmpty
				$Ini.Sections | Should -Be 0

			}

			It 'ignores comments and blank lines' {

				[System.IO.File]::WriteAllText($IniFile, "; Comment=1`r`n# Comment=2`r`n`r`nADDRESS=10.0.0.1")

				(Read-ARKIniFile -Path $IniFile).Parameters.Name | Should -Be 'ADDRESS'

			}

			It 'returns an empty value' {

				[System.IO.File]::WriteAllText($IniFile, 'ADDRESS=')

				(Read-ARKIniFile -Path $IniFile).Parameters[0].Value | Should -BeExactly ''

			}

		}

		Context 'Encoding' {

			It 'reads a file without a byte order mark byte for byte' {

				[System.IO.File]::WriteAllBytes($IniFile, [byte[]](0x41, 0x3D, 0xE9))

				$Ini = Read-ARKIniFile -Path $IniFile

				$Ini.Encoding.CodePage | Should -Be 28591
				$Ini.Encoding.GetPreamble().Length | Should -Be 0
				$Ini.Encoding.GetBytes($Ini.Lines[0]) | Should -Be 0x41, 0x3D, 0xE9

			}

			It 'reads a UTF-8 file with a byte order mark' {

				[System.IO.File]::WriteAllText($IniFile, 'A=1', [System.Text.UTF8Encoding]::new($true))

				$Ini = Read-ARKIniFile -Path $IniFile

				$Ini.Encoding.CodePage | Should -Be 65001
				$Ini.Encoding.GetPreamble().Length | Should -Be 3
				$Ini.Parameters[0].Name | Should -BeExactly 'A'

			}

			It 'reads a Unicode file with a byte order mark' {

				[System.IO.File]::WriteAllText($IniFile, 'A=1', [System.Text.UnicodeEncoding]::new($false, $true))

				$Ini = Read-ARKIniFile -Path $IniFile

				$Ini.Encoding.CodePage | Should -Be 1200
				$Ini.Parameters[0].Name | Should -BeExactly 'A'

			}

		}

	}

}
