---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Restore-ARKFile
---

# Restore-ARKFile

## SYNOPSIS
Decrypts Vault data files using the CyberArk Recover utility.

## SYNTAX

```
Restore-ARKFile [-Path] <String> [-OutputPath] <String> [[-KeyPath] <String>] [[-SafeRecoveryKeyPath] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Runs Recover.exe to decrypt one or more encrypted Vault data files into an output folder, using the recovery keys
in the key folder.

Equivalent to: Recover \<Path\> \<OutputPath\> \<KeyPath\> \[\<SafeRecoveryKeyPath\>\]

The output folder is created if it does not exist.

Relative paths are resolved against the current PowerShell location.

## EXAMPLES

### EXAMPLE 1
```
Restore-ARKFile -Path 'C:\Temp\my_data_file\*' -OutputPath 'D:\Restored' -KeyPath 'C:\Keys'
```

Decrypts all files in C:\Temp\my_data_file into D:\Restored using the recovery keys in C:\Keys.

### EXAMPLE 2
```
Restore-ARKFile -Path 'C:\Temp\my_data_file\*' -OutputPath 'D:\Restored' -SafeRecoveryKeyPath 'C:\Temp\saferecover.key'
```

Decrypts the files using the default key folder set with Set-ARKConfiguration and an RSA-4096 Safe recovery key.

### EXAMPLE 3
```
Get-ChildItem -Path 'C:\Temp\my_data_file' -File | Restore-ARKFile -OutputPath 'D:\Restored'
```

Decrypts each file found by Get-ChildItem, running Recover.exe once per file.

## PARAMETERS

### -Path
The encrypted data file to decrypt.
Wildcards are passed to Recover.exe, which expands them.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -OutputPath
The folder to write the decrypted files to.

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
The folder containing the recovery keys.
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

### -SafeRecoveryKeyPath
The RSA-4096 Safe recovery key file, for Safes encrypted with a Safe recovery key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

### DRJones.RecoveryResult

## NOTES
Requires Recover.exe, located with Set-ARKConfiguration -UtilityPath.
Recover.exe runs with its own folder as the working directory.

Recover.exe can run from any folder containing it and the DLLs, openssl.cnf and icudt74l.dat supplied with it in
the Vault Server folder; these differ between Vault versions.
Without openssl.cnf, Recover.exe fails with no output.
The Visual C++ redistributable it requires must be installed.
A missing DLL is reported as an error.

A non-zero exit code from Recover.exe is reported as an error.

## RELATED LINKS
