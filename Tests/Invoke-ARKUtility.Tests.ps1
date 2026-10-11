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

Describe 'Invoke-ARKUtility' {

	InModuleScope 'DRJones' {

		BeforeAll {

			$Script:SavedConfig = $Script:ARKConfig

		}

		AfterAll {

			$Script:ARKConfig = $Script:SavedConfig

		}

		BeforeEach {

			$Script:ARKConfig = [PSCustomObject]@{
				UtilityPath = 'C:\PrivateArk\Server'
				KeyPath     = 'C:\Keys'
			}

			Mock Test-Path -MockWith { $true }

			Mock Start-ARKUtilityProcess -MockWith {
				[PSCustomObject]@{
					ExitCode = 0
					StdOut   = 'Recovered'
					StdErr   = ''
				}
			}

		}

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Utility' },
				@{Parameter = 'ArgumentList' }
			) {

				(Get-Command Invoke-ARKUtility).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

			It 'only accepts supported recovery utilities' {

				{ Invoke-ARKUtility -Utility PACLI -ArgumentList 'Something' } | Should -Throw

			}

		}

		Context 'Configuration' {

			It 'throws if the utility folder is not set' {

				$Script:ARKConfig.UtilityPath = $null

				{ Invoke-ARKUtility -Utility Recover -ArgumentList 'Something' } | Should -Throw '*Run Set-ARKConfiguration*'
				Should -Invoke Start-ARKUtilityProcess -Times 0 -Exactly

			}

			It 'throws if the utility is not found' {

				Mock Test-Path -MockWith { $false }

				{ Invoke-ARKUtility -Utility SafeRecover -ArgumentList 'Something' } | Should -Throw '*SafeRecover.exe not found*'
				Should -Invoke Start-ARKUtilityProcess -Times 0 -Exactly

			}

			It 'runs the utility from the first configured folder that contains it' {

				$Script:ARKConfig.UtilityPath = 'C:\PrivateArk\Replicator', 'C:\PrivateArk\Server'

				Mock Test-Path -MockWith { $Path -eq 'C:\PrivateArk\Server\CAVaultManager.exe' }

				Invoke-ARKUtility -Utility CAVaultManager -ArgumentList 'RestoreDB'

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					$Process.StartInfo.FileName -eq 'C:\PrivateArk\Server\CAVaultManager.exe' -and
					$Process.StartInfo.WorkingDirectory -eq 'C:\PrivateArk\Server'
				}

			}

			It 'lists every configured folder when the utility is not found' {

				$Script:ARKConfig.UtilityPath = 'C:\PrivateArk\Replicator', 'C:\PrivateArk\Server'

				Mock Test-Path -MockWith { $false }

				{ Invoke-ARKUtility -Utility PARestore -ArgumentList 'Something' } |
					Should -Throw '*PARestore.exe not found in C:\PrivateArk\Replicator, C:\PrivateArk\Server*'

			}

		}

		Context 'Process' {

			It 'runs <Utility>.exe from the configured folder' -TestCases @(
				@{Utility = 'Recover' },
				@{Utility = 'SafeRecover' },
				@{Utility = 'PARestore' },
				@{Utility = 'CAVaultManager' }
			) {

				Invoke-ARKUtility -Utility $Utility -ArgumentList 'Something'

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					$Process.StartInfo.FileName -eq "C:\PrivateArk\Server\$Utility.exe"
				}

			}

			It 'uses the utility folder as the working directory' {

				Invoke-ARKUtility -Utility Recover -ArgumentList 'Something'

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					$Process.StartInfo.WorkingDirectory -eq 'C:\PrivateArk\Server'
				}

			}

			It 'passes arguments in order, quoting where needed' {

				Invoke-ARKUtility -Utility SafeRecover -ArgumentList 'Research', 'C:\Research', 'C:\Master Key\'

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					$Process.StartInfo.Arguments -eq 'Research C:\Research "C:\Master Key\\"'
				}

			}

			It 'passes sensitive values to the utility unmasked' {

				Invoke-ARKUtility -Utility PARestore -ArgumentList 'Vault.ini', 'Operator/Secret1' -SensitiveValue 'Secret1'

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					$Process.StartInfo.Arguments -eq 'Vault.ini Operator/Secret1'
				}

			}

			It 'masks sensitive values in debug output' {

				$DebugPreference = 'Continue'

				$DebugOutput = Invoke-ARKUtility -Utility PARestore -ArgumentList 'Vault.ini', 'Operator/Secret1' -SensitiveValue 'Secret1' 5>&1 |
					Where-Object { $_ -is [System.Management.Automation.DebugRecord] }

				$DebugOutput.Message | Should -BeLike '*Vault.ini Operator/`*`*`*`*`*`*`*`*'
				$DebugOutput.Message | Should -Not -BeLike '*Secret1*'

			}

			It 'redirects input and output and runs without a window' {

				Invoke-ARKUtility -Utility Recover -ArgumentList 'Something'

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					$Process.StartInfo.RedirectStandardInput -and
					$Process.StartInfo.RedirectStandardOutput -and
					$Process.StartInfo.RedirectStandardError -and
					(-not $Process.StartInfo.UseShellExecute) -and
					$Process.StartInfo.CreateNoWindow
				}

			}

			It 'runs in the current console with Interactive' {

				Invoke-ARKUtility -Utility PARestore -ArgumentList 'Something' -Interactive

				Should -Invoke Start-ARKUtilityProcess -Times 1 -Exactly -ParameterFilter {
					(-not $Process.StartInfo.RedirectStandardInput) -and
					(-not $Process.StartInfo.RedirectStandardOutput) -and
					(-not $Process.StartInfo.RedirectStandardError) -and
					(-not $Process.StartInfo.UseShellExecute) -and
					(-not $Process.StartInfo.CreateNoWindow)
				}

			}

		}

		Context 'Output' {

			It 'returns the result of a successful run' {

				$Result = Invoke-ARKUtility -Utility Recover -ArgumentList 'Something'

				$Result.PSObject.TypeNames[0] | Should -Be 'DRJones.UtilityResult'
				$Result.Utility | Should -Be 'Recover'
				$Result.ExitCode | Should -Be 0
				$Result.StdOut | Should -Be 'Recovered'

			}

			It 'reports standard error when the exit code is not 0' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 1; StdOut = 'Some output'; StdErr = 'Key not found' }
				}

				{ Invoke-ARKUtility -Utility Recover -ArgumentList 'Something' -ErrorAction Stop } | Should -Throw 'Key not found'

			}

			It 'reports standard output when the exit code is not 0 and standard error is empty' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 1; StdOut = "Safe not found`r`n"; StdErr = '' }
				}

				{ Invoke-ARKUtility -Utility SafeRecover -ArgumentList 'Something' -ErrorAction Stop } | Should -Throw 'Safe not found'

			}

			It 'reports the exit code when there is no output' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 5; StdOut = ''; StdErr = $null }
				}

				{ Invoke-ARKUtility -Utility SafeRecover -ArgumentList 'Something' -ErrorAction Stop } |
					Should -Throw 'SafeRecover.exe exited with code 5'

			}

			It 'reports a missing DLL when the utility cannot start' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = -1073741515; StdOut = ''; StdErr = '' }
				}

				$UtilityError = { Invoke-ARKUtility -Utility Recover -ArgumentList 'Something' -ErrorAction Stop } |
					Should -Throw -PassThru

				$UtilityError.Exception.Message | Should -BeLike 'Recover.exe could not start: a required DLL was not found.*C:\PrivateArk\Server*'
				$UtilityError.FullyQualifiedErrorId | Should -BeLike 'Recover.ExitCode.-1073741515*'

			}

			It 'adds a hint for <Output>' -TestCases @(
				@{ Output = 'CASTM003E Vault transaction failed. Reason: ITATS633E Could not locate any backup dumps'; Hint = '*tsparm.ini*BackupPoolName*' },
				@{ Output = 'CASTM003 Vault transaction failed. Reason: ITATS004E Authentication failure for User Restore.'; Hint = '*CABACKUP*' },
				@{ Output = 'CASCF034E Cannot decrypt password from file [C:\Creds\backup.cred] using application verifiers - are you authorized to use this credentials file? Rc = -2166007.'; Hint = '*restricted to another OS user*' },
				@{ Output = 'CASTM003E Vault transaction failed. Reason: ITATS654E Safe Banners_R already exists. A different Safe cannot be restored into it.'; Hint = '*must not exist*' },
				@{ Output = 'Cannot restore safe "safe1" - a corresponding safe does not exist.'; Hint = '*must exist in the Vault*owner*' },
				@{ Output = 'CASTM003E Vault transaction failed. ITAGN001S System error (Code: 929, Diagnostic information: 1.SAFE1).'; Hint = '*must exist in the Vault*owner*' }
			) {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 1; StdOut = $Output; StdErr = '' }
				}

				$UtilityError = { Invoke-ARKUtility -Utility PARestore -ArgumentList 'Something' -ErrorAction Stop } |
					Should -Throw -PassThru

				$UtilityError.Exception.Message | Should -BeLike "$([WildcardPattern]::Escape($Output))`n*"
				$UtilityError.Exception.Message | Should -BeLike $Hint

			}

			It 'adds no hint for other errors' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 1; StdOut = 'PARST003E PARestore ended with errors.'; StdErr = '' }
				}

				$UtilityError = { Invoke-ARKUtility -Utility PARestore -ArgumentList 'Something' -ErrorAction Stop } |
					Should -Throw -PassThru

				$UtilityError.Exception.Message | Should -BeExactly 'PARST003E PARestore ended with errors.'

			}

			It 'reports a cancelled PARestore prompt as an error despite a zero exit code' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{
						ExitCode = 0
						StdOut   = "WARNING:`r`nEnter 'NO' to cancel or 'YES' to continue: `r`nPARST032E Restore process cancelled by user.`r`n"
						StdErr   = ''
					}
				}

				$UtilityError = { Invoke-ARKUtility -Utility PARestore -ArgumentList 'Something' -ErrorAction Stop } |
					Should -Throw -PassThru

				$UtilityError.Exception.Message | Should -BeExactly 'PARST032E Restore process cancelled by user.'
				$UtilityError.FullyQualifiedErrorId | Should -BeLike 'PARestore.ExitCode.0*'

			}

			It 'sets an error id from the utility and exit code' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 2; StdOut = ''; StdErr = 'Failure' }
				}

				$UtilityError = { Invoke-ARKUtility -Utility Recover -ArgumentList 'Something' -ErrorAction Stop } |
					Should -Throw -PassThru

				$UtilityError.FullyQualifiedErrorId | Should -BeLike 'Recover.ExitCode.2*'

			}

			It 'masks sensitive values in the error target' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 2; StdOut = ''; StdErr = 'Failure' }
				}

				$UtilityError = { Invoke-ARKUtility -Utility PARestore -ArgumentList 'Vault.ini', 'Operator/Secret1' -SensitiveValue 'Secret1' -ErrorAction Stop } |
					Should -Throw -PassThru

				$UtilityError.TargetObject | Should -BeExactly 'Vault.ini Operator/********'

			}

			It 'returns no result when the exit code is not 0' {

				Mock Start-ARKUtilityProcess -MockWith {
					[PSCustomObject]@{ ExitCode = 1; StdOut = ''; StdErr = 'Failure' }
				}

				Invoke-ARKUtility -Utility Recover -ArgumentList 'Something' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty

			}

		}

	}

}
