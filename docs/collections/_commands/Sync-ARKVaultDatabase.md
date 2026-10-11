---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Sync-ARKVaultDatabase
---

# Sync-ARKVaultDatabase

## SYNOPSIS
Synchronizes the Vault database with the restored Safe files using CAVaultManager SynchronizeDB.

## SYNTAX

```
Sync-ARKVaultDatabase [[-SafePattern] <String>] [-FilesSyncOnly] [-QuotaSyncOnly] [-Update] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Runs CAVaultManager.exe SynchronizeDB to synchronize the restored Vault metadata with the files and quotas in the
Safes folder, for example after Restore-ARKVaultDatabase -NoSynchronize.

Equivalent to: CAVaultManager SynchronizeDB /SafePattern \<SafePattern\> /FilesSyncOnly /QuotaSyncOnly /Update
/Force

Without Update, the synchronization is only simulated and the differences are reported in the output.
With Update, the database is changed, after confirmation.

## EXAMPLES

### EXAMPLE 1
```
Sync-ARKVaultDatabase
```

Simulates synchronizing all Safes, reporting the differences without changing the database.

### EXAMPLE 2
```
Sync-ARKVaultDatabase -SafePattern 'Fin*' -FilesSyncOnly -Update
```

Synchronizes the files of Safes with names starting Fin with the restored metadata, after confirmation.

## PARAMETERS

### -SafePattern
The Safes to synchronize, as a name or wildcard pattern.
Defaults to all Safes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: All Safes
Accept pipeline input: False
Accept wildcard characters: True
```

### -FilesSyncOnly
Synchronizes only the files in the Safes folder with the restored metadata.

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

### -QuotaSyncOnly
Synchronizes only the quotas in the Safes folder with the restored metadata.

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

### -Update
Updates the database.
Without Update, the synchronization is only simulated.

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
Shows what would happen if the cmdlet runs with Update.
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
Prompts you for confirmation before running the cmdlet with Update.

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
With Update, prompts for confirmation by default; CAVaultManager.exe is always run with /Force so it does not
prompt.

Requires CAVaultManager.exe, located with Set-ARKConfiguration -UtilityPath.
CAVaultManager.exe runs with its own folder as the working directory.

A non-zero exit code from CAVaultManager.exe is reported as an error.

## RELATED LINKS
