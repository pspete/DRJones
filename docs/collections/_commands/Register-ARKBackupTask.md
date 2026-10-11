---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Register-ARKBackupTask
---

# Register-ARKBackupTask

## SYNOPSIS
Schedules weekly incremental and full Vault backups with the CyberArk PAReplicate utility.

## SYNTAX

```
Register-ARKBackupTask -LogonFile <String> [-VaultFile <String>] [-BackupPoolName <String>]
 [-At <DateTime>] [-FullBackupDay <DayOfWeek>] [-TaskPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Registers two scheduled tasks on the Replicate server that run PAReplicate.exe as SYSTEM, with its own folder as
the working directory:

- PAReplicate Incremental Backup: PAReplicate \<VaultFile\> /LogonFromFile \<LogonFile\>, every day except
FullBackupDay.
- PAReplicate Full Backup: PAReplicate \<VaultFile\> /LogonFromFile \<LogonFile\> /FullBackup, on FullBackupDay.

Both tasks run at the same local time, and start as soon as possible after a missed start.
Tasks with the same names in TaskPath are replaced.

Create the credentials file for the Backup user with CreateCredFile.exe, restricted to PAReplicate running as
SYSTEM:

CreateCredFile.exe backup.cred Password /Username Backup /AppType CABACKUP /IpAddress /Hostname /ExePath
"C:\Program Files (x86)\PrivateArk\Replicate\PAReplicate.exe" /OSUsername "NT AUTHORITY\SYSTEM" /EntropyFile
/DPAPIMachineProtection /Password \<password\>

## EXAMPLES

### EXAMPLE 1
```
Register-ARKBackupTask -LogonFile 'C:\Program Files (x86)\PrivateArk\Replicate\backup.cred'
```

Schedules an incremental backup Monday to Saturday and a full backup on Sunday, at 01:00.

### EXAMPLE 2
```
Register-ARKBackupTask -LogonFile 'C:\Program Files (x86)\PrivateArk\Replicate\backup.cred' -FullBackupDay Saturday -At '22:30'
```

Schedules the full backup on Saturday and the incremental backup on the other days, at 22:30.

## PARAMETERS

### -LogonFile
The user credentials file, passed as /LogonFromFile.
Relative paths are resolved against the current location.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultFile
The Vault parameter file.
Defaults to Vault.ini in the PAReplicate.exe folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Vault.ini
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupPoolName
The name of the backup pool to back up to.
Restores from these backups must use the same name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -At
The local time of day both backups start.
Defaults to 01:00.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 01:00
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullBackupDay
The day of the week for the full backup.
The incremental backup runs on every other day.
Defaults to Sunday.

```yaml
Type: DayOfWeek
Parameter Sets: (All)
Aliases:
Accepted values: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

Required: False
Position: Named
Default value: Sunday
Accept pipeline input: False
Accept wildcard characters: False
```

### -TaskPath
The Task Scheduler folder for the tasks, starting and ending with a backslash.
Defaults to \DRJones\.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: \DRJones\
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.Management.Infrastructure.CimInstance#MSFT_ScheduledTask

## NOTES
Must run in an elevated session.

Requires PAReplicate.exe, located with Set-ARKConfiguration -UtilityPath.

The task results are recorded in the Task Scheduler history; PAReplicate.exe output is not captured.

## RELATED LINKS
