---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Restore-ARKSafe
---

# Restore-ARKSafe

## SYNOPSIS
Decrypts the contents of a Vault Safe using the CyberArk SafeRecover utility.

## SYNTAX

```
Restore-ARKSafe [-Safe] <String> [-OutputPath] <String> [[-KeyPath] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Runs SafeRecover.exe to decrypt the contents of one or more Safes into an output folder, using the master key in the
key folder.
SafeRecover.exe reads the Safe data from the SafesDirectory set in tsparm.ini on the Vault server.

Equivalent to: SafeRecover \<Safe\> \<OutputPath\> \<KeyPath\>

The output folder is created if it does not exist.

Relative paths are resolved against the current PowerShell location.

## EXAMPLES

### EXAMPLE 1
```
Restore-ARKSafe -Safe Research -OutputPath 'C:\Research' -KeyPath 'C:\MasterKey'
```

Decrypts the contents of the Research Safe into C:\Research using the master key in C:\MasterKey.

### EXAMPLE 2
```
Restore-ARKSafe -Safe 'Fin*' -OutputPath 'D:\Restored'
```

Decrypts all Safes with names starting Fin, using the default key folder set with Set-ARKConfiguration.

### EXAMPLE 3
```
Import-Csv -Path .\Safes.csv | Restore-ARKSafe
```

Decrypts each Safe listed in a CSV file with SafeName and OutputPath columns.

## PARAMETERS

### -Safe
The name of the Safe to decrypt.
Wildcards are passed to SafeRecover.exe, which expands them.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SafeName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -OutputPath
The folder to write the decrypted Safe contents to.

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

### -KeyPath
The folder containing the master key.
Defaults to the KeyPath set with Set-ARKConfiguration.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: KeyPath from Set-ARKConfiguration
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

### DRJones.RecoveryResult

## NOTES
Must be run from an elevated session; the command throws otherwise.

Requires SafeRecover.exe, located with Set-ARKConfiguration -UtilityPath.
SafeRecover.exe runs with its own folder as the working directory.

SafeRecover.exe reads the Vault Server registry settings, so it must run on a Vault server; elsewhere it fails with
ITASE001S System error: RegOpenKey_1 failed.
The PrivateArk Server service must be stopped; the command throws if it is running.
The PrivateArk Database service must be running.

A non-zero exit code from SafeRecover.exe is reported as an error.

## RELATED LINKS
