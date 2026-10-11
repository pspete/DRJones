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

Describe 'ConvertTo-ARKArgument' {

	InModuleScope 'DRJones' {

		Context 'Mandatory Parameters' {

			It 'specifies parameter <Parameter> as mandatory' -TestCases @(
				@{Parameter = 'Value' }
			) {

				(Get-Command ConvertTo-ARKArgument).Parameters["$Parameter"].Attributes.Mandatory | Should -Be $true

			}

		}

		Context 'Output' {

			It 'does not quote a simple value' {

				ConvertTo-ARKArgument -Value 'Research' | Should -BeExactly 'Research'

			}

			It 'joins values in order' {

				ConvertTo-ARKArgument -Value 'Research', 'C:\Research', '/RestoreSafe' |
					Should -BeExactly 'Research C:\Research /RestoreSafe'

			}

			It 'quotes a value containing spaces and preserves wildcards' {

				ConvertTo-ARKArgument -Value 'C:\Vault Data\Research\*' | Should -BeExactly '"C:\Vault Data\Research\*"'

			}

			It 'quotes a value containing a tab' {

				ConvertTo-ARKArgument -Value "A`tB" | Should -BeExactly "`"A`tB`""

			}

			It 'quotes an empty value' {

				ConvertTo-ARKArgument -Value 'A', '', 'B' | Should -BeExactly 'A "" B'

			}

			It 'doubles the trailing backslash of a quoted value' {

				ConvertTo-ARKArgument -Value 'C:\Vault Keys\' | Should -BeExactly '"C:\Vault Keys\\"'

			}

			It 'does not change the trailing backslash of an unquoted value' {

				ConvertTo-ARKArgument -Value 'D:\' | Should -BeExactly 'D:\'

			}

			It 'escapes embedded double quotes' {

				ConvertTo-ARKArgument -Value 'Say "Hi"' | Should -BeExactly '"Say \"Hi\""'

			}

			It 'doubles backslashes preceding an embedded double quote' {

				ConvertTo-ARKArgument -Value 'A\"B' | Should -BeExactly '"A\\\"B"'

			}

			It 'does not change backslashes inside a quoted value' {

				ConvertTo-ARKArgument -Value 'C:\A B\C' | Should -BeExactly '"C:\A B\C"'

			}

			It 'accepts values from the pipeline' {

				'One', 'Two' | ConvertTo-ARKArgument | Should -BeExactly 'One Two'

			}

		}

	}

}
