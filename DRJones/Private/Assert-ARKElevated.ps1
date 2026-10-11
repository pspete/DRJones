function Assert-ARKElevated {
	<#
	.SYNOPSIS
	Throws if the current session is not elevated.

	.DESCRIPTION
	Throws a terminating error naming the operation when the current session is not running as Administrator.

	.PARAMETER Operation
	The operation that requires elevation, used in the error message.

	.EXAMPLE
	Assert-ARKElevated -Operation 'CAVaultManager RestoreDB'

	Throws: CAVaultManager RestoreDB must run in an elevated session. Run PowerShell as Administrator.
	#>
	[CmdletBinding()]
	param(

		[Parameter(
			Mandatory = $true
		)]
		[ValidateNotNullOrEmpty()]
		[string]$Operation

	)

	if (-not (Test-ARKElevated)) {

		throw "$Operation must run in an elevated session. Run PowerShell as Administrator."

	}

}
