# .ExternalHelp DRJones-help.xml
function Register-ARKBackupTask {
	[CmdletBinding(SupportsShouldProcess)]
	[OutputType('Microsoft.Management.Infrastructure.CimInstance#MSFT_ScheduledTask')]
	param(

		[Parameter(
			Mandatory = $true
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$LogonFile,

		[Parameter(
			Mandatory = $false
		)]
		[ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
		[string]$VaultFile,

		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNullOrEmpty()]
		[string]$BackupPoolName,

		[Parameter(
			Mandatory = $false
		)]
		[datetime]$At = '01:00',

		[Parameter(
			Mandatory = $false
		)]
		[System.DayOfWeek]$FullBackupDay = 'Sunday',

		[Parameter(
			Mandatory = $false
		)]
		[ValidatePattern('^\\(.+\\)?$')]
		[string]$TaskPath = '\DRJones\'

	)

	Assert-ARKElevated -Operation 'Registering a SYSTEM scheduled task'

	$FilePath = Get-ARKUtilityPath -Utility PAReplicate

	$LogonParameters = @{ }
	foreach ($Key in 'VaultFile', 'LogonFile', 'BackupPoolName') {
		if ($PSBoundParameters.ContainsKey($Key)) { $LogonParameters[$Key] = $PSBoundParameters[$Key] }
	}

	$ArgumentList = @(Get-ARKBackupArgument @LogonParameters)

	$Principal = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
	$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

	$Tasks = @(
		@{
			TaskName = 'PAReplicate Incremental Backup'
			Argument = ConvertTo-ARKArgument -Value $ArgumentList
			Days     = [System.DayOfWeek].GetEnumValues() | Where-Object { $_ -ne $FullBackupDay }
		}
		@{
			TaskName = 'PAReplicate Full Backup'
			Argument = ConvertTo-ARKArgument -Value ($ArgumentList + '/FullBackup')
			Days     = $FullBackupDay
		}
	)

	foreach ($Task in $Tasks) {

		if ($PSCmdlet.ShouldProcess("$TaskPath$($Task.TaskName)", 'Register scheduled task')) {

			$Action = New-ScheduledTaskAction -Execute $FilePath -Argument $Task.Argument -WorkingDirectory (Split-Path -Path $FilePath -Parent)
			$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Task.Days -At $At
			#Local time, so the task keeps its time of day across daylight saving changes
			$Trigger.StartBoundary = $At.ToString('s')

			Register-ScheduledTask -TaskName $Task.TaskName -TaskPath $TaskPath -Action $Action -Trigger $Trigger `
				-Principal $Principal -Settings $Settings -Description 'CyberArk Vault backup, registered by DRJones.' -Force

		}

	}

}
