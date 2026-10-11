---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Restore-ARKRecordingSafe
---

# Restore-ARKRecordingSafe

## SYNOPSIS
Restores a recordings Safe from backup into a new Safe using the CyberArk PARestore utility.

## SYNTAX

### Credential (Default)
```
Restore-ARKRecordingSafe [-Safe] <String> [-TargetSafe] <String> [-Owners <String[]>] [-Retention <Int32>]
 -Credential <PSCredential> [-VaultFile <String>] [-BackupPoolName <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### LogonFile
```
Restore-ARKRecordingSafe [-Safe] <String> [-TargetSafe] <String> [-Owners <String[]>] [-Retention <Int32>]
 -LogonFile <String> [-VaultFile <String>] [-BackupPoolName <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Runs PARestore.exe to restore a recordings Safe from the backup files into a new Safe in the Vault.

Equivalent to: PARestore \<VaultFile\> \<User\>/\<Password\> /RestoreRecordings /RestoreSafe \<Safe\>
/TargetSafe \<TargetSafe\> /Owners \<Owners\> /Retention \<Retention\>

A Safe with the same name as the recordings Safe does not need to exist in the Vault.
The target Safe must not exist; PARestore creates it, with the given owners and retention period.

The restoring user cannot be added as an owner of the restored Safe.

Recordings restored this way may not play in the PVWA (seen on v12.6 and v14.0).
If they are needed, restore the whole Vault, with Restore-ARKVault, to an isolated server instead.

## EXAMPLES

### EXAMPLE 1
```
Restore-ARKRecordingSafe -Safe PSMRecordings -TargetSafe PSMRecordings_R -Credential (Get-Credential Backup)
```

Restores the PSMRecordings Safe into a new Safe named PSMRecordings_R, owned by Auditors with a 7 day retention.

### EXAMPLE 2
```
Restore-ARKRecordingSafe PSMRecordings PSMRecordings_R -Owners Auditors, 'Vault Admins' -Retention 30 -Credential $Cred
```

Restores the recordings Safe with Auditors and Vault Admins as owners, keeping recordings for 30 days.

## PARAMETERS

### -Safe
The name of the recordings Safe to restore.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SafeName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetSafe
The name of the new Safe to restore into.
The Safe must not already exist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Owners
The users and groups to add as owners of the restored Safe.
Defaults to Auditors.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Auditors
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Retention
The number of days, from 1 to 90, to keep the restored recordings.
Defaults to 7.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 7
Accept pipeline input: True (ByPropertyName)
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

### -LogonFile
The user credentials file, passed as /LogonFromFile.

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

### -VaultFile
The Vault parameter file.
Defaults to Vault.ini in the PARestore.exe folder.

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
The name of the backup pool the backup files belong to.
Must match the backup pool name used by PAReplicate.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Requires PARestore.exe, located with Set-ARKConfiguration -UtilityPath.
PARestore.exe runs with its own folder as the working directory.

With Credential, the password is passed on the PARestore.exe command line and is visible to other processes on the
machine while it runs.
It is masked in debug output and error records.
Use LogonFile to avoid this.

PARestore.exe runs in the current console, so its prompts, such as the warning about the supported PVWA version, are
shown and answered there.
Its output is not captured: StdOut and StdErr of the result are empty.
Run the command from a console host, such as pwsh or the VS Code terminal.

A non-zero exit code from PARestore.exe is reported as an error.

PARestore.exe locks Vault database tables while it runs, so it can take a long time and Vault logons can fail or
time out until it finishes.
Run it when Vault activity is low.

## RELATED LINKS
