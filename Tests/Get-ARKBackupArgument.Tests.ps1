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

Describe 'Get-ARKBackupArgument' {

	InModuleScope 'DRJones' {

		BeforeEach {

			$Credential = [pscredential]::new('Operator', [System.Net.NetworkCredential]::new('', 'Secret1').SecurePassword)

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Credential' },
				@{Parameter = 'LogonFile' }
			) {

				(Get-Command Get-ARKBackupArgument).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Output' {

			It 'defaults the Vault file to Vault.ini' {

				(Get-ARKBackupArgument -Credential $Credential)[0] | Should -BeExactly 'Vault.ini'

			}

			It 'resolves a relative Vault file' {

				Push-Location -Path $TestDrive

				try {
					$Arguments = Get-ARKBackupArgument -Credential $Credential -VaultFile '.\Vault.ini'
				} finally {
					Pop-Location
				}

				$Arguments[0] | Should -Be (Join-Path $TestDrive 'Vault.ini')

			}

			It 'joins user and password' {

				$Arguments = Get-ARKBackupArgument -Credential $Credential

				($Arguments -join '|') | Should -BeExactly 'Vault.ini|Operator/Secret1'

			}

			It 'uses a logon file' {

				$Arguments = Get-ARKBackupArgument -LogonFile 'C:\Creds\Operator.cred'

				($Arguments -join '|') | Should -BeExactly 'Vault.ini|/LogonFromFile|C:\Creds\Operator.cred'

			}

			It 'adds the backup pool name' {

				$Arguments = Get-ARKBackupArgument -Credential $Credential -BackupPoolName 'Pool A'

				($Arguments -join '|') | Should -BeExactly 'Vault.ini|Operator/Secret1|/BackupPoolName|Pool A'

			}

		}

	}

}
