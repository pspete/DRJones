function Start-ARKUtilityProcess {
	<#
	.SYNOPSIS
	Starts a recovery utility process.

	.DESCRIPTION
	Starts the process described by a System.Diagnostics.Process object prepared by Invoke-ARKUtility,
	waits for it to exit, and returns its exit code and output.

	When input and output are redirected, standard input is closed as soon as the process starts, so a utility
	prompting for input reads end of input rather than waiting indefinitely.
	Otherwise the process runs in the current console and its output is not captured.

	.PARAMETER Process
	System.Diagnostics.Process object containing the utility path and arguments.

	.EXAMPLE
	Start-ARKUtilityProcess -Process $Process

	Starts the process and returns an object with ExitCode, StdOut and StdErr properties.
	#>
	[CmdletBinding(SupportsShouldProcess)]
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '', Justification = 'ShouldProcess handling is in the calling public function')]
	[OutputType('System.Management.Automation.PSCustomObject')]
	param(

		[Parameter(
			Mandatory = $true,
			ValueFromPipelineByPropertyName = $true
		)]
		[System.Diagnostics.Process]$Process

	)

	process {

		$null = $Process.Start()

		$StdOut = $null
		$StdErr = $null

		if ($Process.StartInfo.RedirectStandardInput) {

			$Process.StandardInput.Close()

			#Read output streams before waiting, otherwise a full output buffer blocks the process from exiting.
			$StdOut = $Process.StandardOutput.ReadToEnd()
			$StdErr = $Process.StandardError.ReadToEnd()

		}

		$Process.WaitForExit()

		[PSCustomObject]@{
			ExitCode = $Process.ExitCode
			StdOut   = $StdOut
			StdErr   = $StdErr
		}

	}

}
