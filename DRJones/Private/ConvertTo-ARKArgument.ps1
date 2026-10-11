function ConvertTo-ARKArgument {
	<#
	.SYNOPSIS
	Converts values into an argument string for a recovery utility command line.

	.DESCRIPTION
	Joins values with spaces, wrapping a value in double quotes only when it is empty or contains whitespace or
	double quotes, so switches such as /RestoreSafe are passed as typed.

	In a quoted value, embedded double quotes are escaped, and trailing backslashes are doubled so a folder path
	such as 'C:\Vault Keys\' is not read as an escaped closing quote when the utility parses its command line.

	.PARAMETER Value
	The values to convert, in command line order.

	.EXAMPLE
	ConvertTo-ARKArgument -Value 'C:\Vault\Data\*', 'D:\Restored', 'C:\Vault Keys\'

	Returns: C:\Vault\Data\* D:\Restored "C:\Vault Keys\\"
	#>
	[CmdletBinding()]
	[OutputType('System.String')]
	param(

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $true
		)]
		[AllowEmptyString()]
		[string[]]$Value

	)

	begin {

		$Arguments = [System.Collections.Generic.List[string]]::new()

	}

	process {

		foreach ($Item in $Value) {

			if ($Item -eq '' -or $Item -match '[\s"]') {

				$Item = ($Item -replace '(\\*)"', '$1$1\"') -replace '(\\+)$', '$1$1'
				$Item = '"{0}"' -f $Item

			}

			$Arguments.Add($Item)

		}

	}

	end {

		$Arguments -join ' '

	}

}
