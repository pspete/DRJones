---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Get-ARKConfiguration
---

# Get-ARKConfiguration

## SYNOPSIS
Gets the default folders used by DRJones.

## SYNTAX

```
Get-ARKConfiguration [<CommonParameters>]
```

## DESCRIPTION
Returns the folder containing the CyberArk Recover.exe and SafeRecover.exe utilities, and the default folder
containing the recovery keys, as set with Set-ARKConfiguration.

## EXAMPLES

### EXAMPLE 1
```
Get-ARKConfiguration
```

Returns the configured UtilityPath and KeyPath.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
