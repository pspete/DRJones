function Test-ARKElevated {
	<#
	.SYNOPSIS
	Tests whether the current session is elevated.

	.DESCRIPTION
	Returns true when the current Windows identity is running as a member of the local Administrators group.

	.EXAMPLE
	Test-ARKElevated

	Returns true in an elevated session.
	#>
	[CmdletBinding()]
	[OutputType('System.Boolean')]
	param( )

	$Principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
	$Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

}
