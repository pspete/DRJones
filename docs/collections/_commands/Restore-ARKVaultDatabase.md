---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Restore-ARKVaultDatabase
---

# Restore-ARKVaultDatabase

## SYNOPSIS
Restores the Vault database from the Restored Safes folder using CAVaultManager RestoreDB.

## SYNTAX

```
Restore-ARKVaultDatabase [-BackupPoolName <String>] [-NoSynchronize] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Runs CAVaultManager.exe RestoreDB to restore the Vault database from the backup files in the Restored Safes
folder, as part of a full Vault restore.

Equivalent to: CAVaultManager RestoreDB /BackupPoolName \<BackupPoolName\> /NoSynchronize /Force

After the database is restored, CAVaultManager synchronizes it with the restored Safe files unless NoSynchronize
is specified.

The Vault must be stopped, and the session must be elevated.

## EXAMPLES

### EXAMPLE 1
```
Restore-ARKVaultDatabase
```

Restores the Vault database and synchronizes it with the restored Safe files, after confirmation.

### EXAMPLE 2
```
Restore-ARKVaultDatabase -BackupPoolName PoolA -NoSynchronize -Confirm:$false
```

Restores the Vault database from the PoolA backup pool without synchronizing, without prompting.

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

### -NoSynchronize
Skips synchronizing the restored database with the restored Safe files.
Use Sync-ARKVaultDatabase to synchronize later.

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
Prompts for confirmation by default; CAVaultManager.exe is always run with /Force so it does not prompt.

Must be run from an elevated session; the command throws otherwise.

Requires CAVaultManager.exe, located with Set-ARKConfiguration -UtilityPath.
CAVaultManager.exe runs with its own folder as the working directory.

A non-zero exit code from CAVaultManager.exe is reported as an error.

## RELATED LINKS
