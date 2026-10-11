---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Get-ARKVaultDatabaseReport
---

# Get-ARKVaultDatabaseReport

## SYNOPSIS
Runs a Vault database diagnostic report using CAVaultManager DiagnoseDBReport.

## SYNTAX

```
Get-ARKVaultDatabaseReport [<CommonParameters>]
```

## DESCRIPTION
Runs CAVaultManager.exe DiagnoseDBReport on the Vault server and returns the report in the utility output.

Equivalent to: CAVaultManager DiagnoseDBReport

Use to inspect the Vault database, for example after Restore-ARKVaultDatabase.

The session must be elevated.

## EXAMPLES

### EXAMPLE 1
```
Get-ARKVaultDatabaseReport
```

Runs the database diagnostic report and returns the result.

### EXAMPLE 2
```
(Get-ARKVaultDatabaseReport).StdOut | Set-Content -Path 'C:\Windows\Temp\diagnosedbreport.txt'
```

Saves the database diagnostic report to a file.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### DRJones.UtilityResult

## NOTES
Must be run from an elevated session; the command throws otherwise.

Requires CAVaultManager.exe, located with Set-ARKConfiguration -UtilityPath.
CAVaultManager.exe runs with its own folder as the working directory.

A non-zero exit code from CAVaultManager.exe is reported as an error.

## RELATED LINKS
