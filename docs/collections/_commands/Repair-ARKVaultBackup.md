---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Repair-ARKVaultBackup
---

# Repair-ARKVaultBackup

## SYNOPSIS
Recovers restored full Vault backup files using CAVaultManager RecoverBackupFiles.

## SYNTAX

```
Repair-ARKVaultBackup [-BackupPoolName <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Runs CAVaultManager.exe RecoverBackupFiles to access the backup files in the Restored Safes folder with the
Vault Recovery Private Key, and re-encrypt them with a new backup key, when the original backup key cannot be used.

Equivalent to: CAVaultManager RecoverBackupFiles /BackupPoolName \<BackupPoolName\>

The Recovery Private Key is read from the location set in the RecoveryPrvKey parameter of DBParm.ini.

Run after Restore-ARKVault with the Vault stopped, and before Restore-ARKVaultDatabase.

## EXAMPLES

### EXAMPLE 1
```
Repair-ARKVaultBackup
```

Recovers the backup files in the Restored Safes folder, after confirmation.

### EXAMPLE 2
```
Repair-ARKVaultBackup -BackupPoolName PoolA -Confirm:$false
```

Recovers the backup files of the PoolA backup pool without prompting.

## PARAMETERS

### -BackupPoolName
The name of the backup pool the backup files belong to.

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
Prompts for confirmation by default.

Requires the Recovery Private Key from the Master CD, set as RecoveryPrvKey in DBParm.ini.
When the restore is complete, remove the Recovery Private Key from the Vault, and from any Safe or folder used to
copy it there.

Must be run from an elevated session; the command throws otherwise.

Requires CAVaultManager.exe, located with Set-ARKConfiguration -UtilityPath.
CAVaultManager.exe runs with its own folder as the working directory.

A non-zero exit code from CAVaultManager.exe is reported as an error.

## RELATED LINKS
