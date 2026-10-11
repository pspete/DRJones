---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Set-ARKVaultParameter
---

# Set-ARKVaultParameter

## SYNOPSIS
Sets a parameter in a CyberArk parameter file, such as DBParm.ini or Vault.ini.

## SYNTAX

```
Set-ARKVaultParameter [-Name] <String> [-Value] <String> -Path <String> [-Section <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Changes the value of a parameter in a CyberArk parameter file, keeping the rest of the file unchanged.

If the parameter already exists, its value is changed wherever it is in the file.
If it does not exist, it is added to the end of the section given in Section, creating the section if needed.
In a file without sections, a new parameter is added to the end of the file.

Use to prepare the Vault for a full Vault restore, and to reset it afterwards.

## EXAMPLES

### EXAMPLE 1
```
$DBParm = 'C:\Program Files (x86)\PrivateArk\Server\Conf\DBParm.ini'
Set-ARKVaultParameter -Path $DBParm -Name BackupFilesDeletion -Value No -Section BACKUP
Set-ARKVaultParameter -Path $DBParm -Name RecoveryPrvKey -Value 'D:\recprv.key' -Section MAIN
```

Prepares DBParm.ini for a full Vault restore: keeps the restored backup files, and points to the Recovery Private
Key on the Master CD.

### EXAMPLE 2
```
Set-ARKVaultParameter -Path $DBParm -Name BackupFilesDeletion -Value 'Yes,24,1,5,7d'
```

Resets BackupFilesDeletion to its default after a full Vault restore.

### EXAMPLE 3
```
Set-ARKVaultParameter -Path 'C:\Program Files (x86)\PrivateArk\Replicate\Vault.ini' -Name ADDRESS -Value 10.0.0.5
```

Points PARestore.exe at the destination Vault.

## PARAMETERS

### -Name
The parameter name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The parameter value, written as given.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
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
The section to add the parameter to, if it is not already in the file.
Required to add a parameter to a file with sections.

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

### System.String

## OUTPUTS

## NOTES
The file keeps its encoding; lines are written with CRLF line endings.

The Vault reads DBParm.ini when it starts; restart the Vault for changes to take effect.

## RELATED LINKS
