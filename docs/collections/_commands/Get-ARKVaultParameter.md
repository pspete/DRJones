---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Get-ARKVaultParameter
---

# Get-ARKVaultParameter

## SYNOPSIS
Gets parameters from a CyberArk parameter file, such as DBParm.ini or Vault.ini.

## SYNTAX

```
Get-ARKVaultParameter [[-Name] <String[]>] -Path <String> [-Section <String>] [<CommonParameters>]
```

## DESCRIPTION
Reads a CyberArk parameter file and returns the parameters in it, with the section each belongs to.

Lines starting with ; or # are treated as comments.
Values are returned as written in the file, including any quotes.

## EXAMPLES

### EXAMPLE 1
```
Get-ARKVaultParameter -Path 'C:\Program Files (x86)\PrivateArk\Server\Conf\DBParm.ini' -Name BackupFilesDeletion, RecoveryPrvKey
```

Returns the BackupFilesDeletion and RecoveryPrvKey parameters from DBParm.ini.

### EXAMPLE 2
```
Get-ARKVaultParameter -Path 'C:\Program Files (x86)\PrivateArk\Replicate\Vault.ini' -Name ADDRESS
```

Returns the Vault address that PARestore.exe connects to.

### EXAMPLE 3
```
Get-ARKVaultParameter -Path .\DBParm.ini -Section BACKUP
```

Returns every parameter in the BACKUP section.

## PARAMETERS

### -Name
The parameter names to return.
Wildcards are permitted.
Defaults to all parameters.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: True
```

### -Path
The parameter file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Section
Returns only the parameters in this section.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### DRJones.VaultParameter

## NOTES

## RELATED LINKS
