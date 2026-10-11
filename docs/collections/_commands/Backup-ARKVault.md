---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Backup-ARKVault
---

# Backup-ARKVault

## SYNOPSIS
Backs up the Vault using the CyberArk PAReplicate utility.

## SYNTAX

### LogonFile (Default)
```
Backup-ARKVault -LogonFile <String> [-VaultFile <String>] [-BackupPoolName <String>] [-Incremental]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Credential
```
Backup-ARKVault -Credential <PSCredential> [-VaultFile <String>] [-BackupPoolName <String>] [-Incremental] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Runs PAReplicate.exe on the Replicate server to back up the Vault: a full backup by default, or an incremental
backup with Incremental.

Equivalent to: PAReplicate \<VaultFile\> /LogonFromFile \<LogonFile\> \[/FullBackup\]

Back up as the built-in Backup user, enabled with a password set from the PrivateArk Client, or another user with
the CABACKUP user type.

Only Safes that existed at the last full backup can be restored individually, so take a full backup regularly.
Use Register-ARKBackupTask to schedule weekly incremental and full backups.

## EXAMPLES

### EXAMPLE 1
```
Backup-ARKVault -LogonFile 'C:\Creds\backup.cred'
```

Runs a full backup, using Vault.ini in the PAReplicate folder.

### EXAMPLE 2
```
Backup-ARKVault -LogonFile 'C:\Creds\backup.cred' -Incremental
```

Runs an incremental backup.

### EXAMPLE 3
```
Backup-ARKVault -Credential (Get-Credential Backup) -BackupPoolName DRPool
```

Runs a full backup to the DRPool backup pool, logging on with a password.

## PARAMETERS

### -LogonFile
The user credentials file, passed as /LogonFromFile.

A credentials file restricted to the SYSTEM OS user, for a scheduled task, cannot be used from an interactive
session.

```yaml
Type: String
Parameter Sets: LogonFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The Vault user and password.

```yaml
Type: PSCredential
Parameter Sets: Credential
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
Restores from this backup must use the same name.

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

### -Incremental
Runs an incremental backup.
Without it, the backup is full, passed as /FullBackup.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### DRJones.UtilityResult

## NOTES
Requires PAReplicate.exe, located with Set-ARKConfiguration -UtilityPath.
PAReplicate.exe runs with its own folder as the working directory.

With Credential, the password is passed on the PAReplicate.exe command line and is visible to other processes on
the machine while it runs.
It is masked in debug output and error records.
Use LogonFile to avoid this.

A non-zero exit code from PAReplicate.exe is reported as an error.

## RELATED LINKS
