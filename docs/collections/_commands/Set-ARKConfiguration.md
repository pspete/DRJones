---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Set-ARKConfiguration
---

# Set-ARKConfiguration

## SYNOPSIS
Sets the default folders used by DRJones.

## SYNTAX

```
Set-ARKConfiguration [[-UtilityPath] <String[]>] [[-KeyPath] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets the folders containing the CyberArk recovery utilities (Recover.exe, SafeRecover.exe, PARestore.exe and
CAVaultManager.exe), and the default folder containing the recovery keys.

When several utility folders are set, each utility is run from the first folder that contains it.

The configuration is saved to DRJonesConfiguration.xml in the user's home folder and loaded when the module is
imported.

Only the values provided are changed; any existing value of a parameter not provided is kept.

## EXAMPLES

### EXAMPLE 1
```
Set-ARKConfiguration -UtilityPath 'C:\Program Files (x86)\PrivateArk\Server' -KeyPath 'D:\RecoveryKeys'
```

Sets the utility folder and the default recovery key folder.

### EXAMPLE 2
```
Set-ARKConfiguration -KeyPath 'E:\MasterKey'
```

Changes the default recovery key folder, keeping the configured utility folder.

### EXAMPLE 3
```
Set-ARKConfiguration -UtilityPath 'C:\Program Files (x86)\PrivateArk\Replicate', 'C:\Program Files (x86)\PrivateArk\Server'
```

Sets the Replicate folder (PARestore.exe) and the Vault Server folder (CAVaultManager.exe) as utility folders.

## PARAMETERS

### -UtilityPath
The folders containing the recovery utilities, searched in order.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KeyPath
The default folder containing the recovery keys, used when -KeyPath is not provided to Restore-ARKFile or
Restore-ARKSafe.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

## NOTES
Both folders must exist.

## RELATED LINKS
