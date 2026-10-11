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

Describe 'Start-ARKUtilityProcess' {

	InModuleScope 'DRJones' {

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Process' }
			) {

				(Get-Command Start-ARKUtilityProcess).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Default' {

			BeforeEach {

				$Process = New-MockObject -Type 'System.Diagnostics.Process'
				$StandardInput = New-Object -TypeName PSObject
				$StandardOutput = New-Object -TypeName PSObject
				$StandardError = New-Object -TypeName PSObject

				$StandardInput | Add-Member -MemberType NoteProperty -Name Closed -Value $false -Force
				$StandardInput | Add-Member -MemberType ScriptMethod -Name Close -Value { $this.Closed = $true } -Force

				$StandardOutput | Add-Member -MemberType ScriptMethod -Name ReadToEnd -Value { 'Standard Output String' } -Force
				$StandardError | Add-Member -MemberType ScriptMethod -Name ReadToEnd -Value { 'Standard Error String' } -Force

				$StartInfo = [System.Diagnostics.ProcessStartInfo]::new()
				$StartInfo.RedirectStandardInput = $true

				$Process | Add-Member -MemberType NoteProperty -Name StartInfo -Value $StartInfo -Force
				$Process | Add-Member -MemberType ScriptMethod -Name Start -Value { $true } -Force
				$Process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { $true } -Force
				$Process | Add-Member -MemberType NoteProperty -Name ExitCode -Value 9876 -Force
				$Process | Add-Member -MemberType NoteProperty -Name StandardInput -Value $StandardInput -Force
				$Process | Add-Member -MemberType NoteProperty -Name StandardOutput -Value $StandardOutput -Force
				$Process | Add-Member -MemberType NoteProperty -Name StandardError -Value $StandardError -Force

			}

			It 'executes without exception' {

				{ Start-ARKUtilityProcess -Process $Process } | Should -Not -Throw

			}

			It 'accepts the process from the pipeline' {

				{ [pscustomobject]@{Process = $Process } | Start-ARKUtilityProcess } | Should -Not -Throw

			}

			It 'closes standard input' {

				$null = Start-ARKUtilityProcess -Process $Process

				$Process.StandardInput.Closed | Should -Be $true

			}

			It 'returns the exit code' {

				(Start-ARKUtilityProcess -Process $Process).ExitCode | Should -Be 9876

			}

			It 'returns standard output' {

				(Start-ARKUtilityProcess -Process $Process).StdOut | Should -Be 'Standard Output String'

			}

			It 'returns standard error' {

				(Start-ARKUtilityProcess -Process $Process).StdErr | Should -Be 'Standard Error String'

			}

			It 'leaves input and output alone when they are not redirected' {

				$Process.StartInfo.RedirectStandardInput = $false

				$Result = Start-ARKUtilityProcess -Process $Process

				$Process.StandardInput.Closed | Should -Be $false
				$Result.ExitCode | Should -Be 9876
				$Result.StdOut | Should -BeNullOrEmpty
				$Result.StdErr | Should -BeNullOrEmpty

			}

		}

	}

}
