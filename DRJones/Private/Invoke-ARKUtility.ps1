function Invoke-ARKUtility {
	<#
	.SYNOPSIS
	Runs a CyberArk recovery utility.

	.DESCRIPTION
	Runs Recover.exe, SafeRecover.exe, PARestore.exe, PAReplicate.exe or CAVaultManager.exe from the first folder set
	with Set-ARKConfiguration -UtilityPath that contains it, passing the supplied arguments in order.

	The utility runs with its own folder as the working directory.

	A non-zero exit code, or a PARestore cancellation (PARST032E) after a confirmation prompt, is reported as an error;
	otherwise the exit code and output are returned.
	An exit code of 0xC0000135 (STATUS_DLL_NOT_FOUND) is reported as a missing DLL.
	Known PARestore errors (ITATS633E, ITATS004E, ITATS654E, a missing original Safe, CASCF034E) include a hint to the likely cause.

	.PARAMETER Utility
	The utility to run: Recover, SafeRecover, PARestore, PAReplicate or CAVaultManager.

	.PARAMETER ArgumentList
	The utility arguments, in command line order.

	.PARAMETER SensitiveValue
	Values, such as passwords, to mask in debug output and error records.

	.PARAMETER Interactive
	Runs the utility in the current console without redirecting its input or output, so the user sees and answers its
	prompts.
	The output is not captured.

	.EXAMPLE
	Invoke-ARKUtility -Utility SafeRecover -ArgumentList 'Research', 'C:\Research', 'C:\MasterKey'

	Runs: SafeRecover.exe Research C:\Research C:\MasterKey
	#>
	[CmdletBinding()]
	[OutputType('DRJones.UtilityResult')]
	param(

		[Parameter(
			Mandatory = $true
		)]
		[ValidateSet('Recover', 'SafeRecover', 'PARestore', 'PAReplicate', 'CAVaultManager')]
		[string]$Utility,

		[Parameter(
			Mandatory = $true
		)]
		[ValidateNotNullOrEmpty()]
		[string[]]$ArgumentList,

		[Parameter(
			Mandatory = $false
		)]
		[string[]]$SensitiveValue,

		[Parameter(
			Mandatory = $false
		)]
		[switch]$Interactive

	)

	#STATUS_DLL_NOT_FOUND (0xC0000135)
	$DllNotFound = -1073741515

	$FilePath = Get-ARKUtilityPath -Utility $Utility

	$WorkingDirectory = Split-Path -Path $FilePath -Parent

	$Arguments = ConvertTo-ARKArgument -Value $ArgumentList

	$MaskedArguments = ConvertTo-ARKArgument -Value @(
		foreach ($Argument in $ArgumentList) {

			foreach ($Value in $SensitiveValue | Where-Object { $_ }) {

				$Argument = $Argument.Replace($Value, '********')

			}

			$Argument

		}
	)

	Write-Debug "Command: $FilePath $MaskedArguments"

	$Process = [System.Diagnostics.Process]::new()

	try {

		$Process.StartInfo.FileName = $FilePath
		$Process.StartInfo.Arguments = $Arguments
		$Process.StartInfo.WorkingDirectory = $WorkingDirectory
		$Process.StartInfo.RedirectStandardInput = -not $Interactive
		$Process.StartInfo.RedirectStandardOutput = -not $Interactive
		$Process.StartInfo.RedirectStandardError = -not $Interactive
		$Process.StartInfo.UseShellExecute = $false
		$Process.StartInfo.CreateNoWindow = -not $Interactive

		$Result = Start-ARKUtilityProcess -Process $Process

	} finally {

		$Process.Dispose()

	}

	$Cancelled = [regex]::Match([string]$Result.StdOut, 'PARST032E.*')

	if ($Result.ExitCode -ne 0 -or $Cancelled.Success) {

		$Message = if ($Result.ExitCode -eq $DllNotFound) {

			"$Utility.exe could not start: a required DLL was not found. Copy the DLLs supplied with $Utility.exe in the Vault Server folder to $WorkingDirectory, and install the Visual C++ redistributable it requires."

		} elseif ($Cancelled.Success) {

			$Cancelled.Value

		} else {

			@(@($Result.StdErr, $Result.StdOut) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })[0]

		}

		if (-not $Message) { $Message = "$Utility.exe exited with code $($Result.ExitCode)" }

		$Message = $Message.Trim()

		$Hints = [ordered]@{
			'ITATS633E'                                      = 'Check that the backup files are in the SafesDirectory set in tsparm.ini, that the Metadata folder holds every metadata file, and that BackupPoolName matches the pool used by PAReplicate. With LoadOnly, the files must already be in the Restored Safes folder on the Vault server.'
			'ITATS654E'                                      = 'The target Safe must not exist: restore into a new Safe name.'
			'ITATS004E'                                      = 'Check the password or credentials file. A user created to run PARestore or PAReplicate must have the CABACKUP user type.'
			'corresponding safe does not exis|Code: 929\b' = 'The Safe being restored must exist in the Vault, with the restoring user as an owner. If it was deleted, create an empty Safe with the same name and its original owners.'
			'CASCF034E'                                      = 'The credentials file is restricted to another OS user, executable path or machine. A file restricted to SYSTEM works only from a scheduled task, such as one registered by Register-ARKBackupTask.'
		}

		foreach ($Pattern in $Hints.Keys) {

			if ($Message -match $Pattern) { $Message = "$Message`n$($Hints[$Pattern])" }

		}

		Write-Error -Message $Message -ErrorId "$Utility.ExitCode.$($Result.ExitCode)" -Category InvalidResult -TargetObject $MaskedArguments

	} else {

		[PSCustomObject]@{
			PSTypeName = 'DRJones.UtilityResult'
			Utility    = $Utility
			ExitCode   = $Result.ExitCode
			StdOut     = $Result.StdOut
			StdErr     = $Result.StdErr
		}

	}

}
