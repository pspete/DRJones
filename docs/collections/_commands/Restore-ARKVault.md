---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Restore-ARKVault
---

# Restore-ARKVault

## SYNOPSIS
Copies full Vault backup files to the Vault using the CyberArk PARestore utility.

## SYNTAX

### Credential (Default)
```
Restore-ARKVault -Credential <PSCredential> [-VaultFile <String>] [-BackupPoolName <String>] [-FromRestored]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LogonFile
```
Restore-ARKVault -LogonFile <String> [-VaultFile <String>] [-BackupPoolName <String>]
 [-FromRestored] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Runs PARestore.exe to copy the backup files of the entire Vault to the Restored Safes folder on the Vault server,
as the first step of a full Vault restore.

Equivalent to: PARestore \<VaultFile\> \<User\>/\<Password\> /FullVaultRestore

All data in the destination Vault is overwritten.
The destination Vault must have been installed with the same keys as the Vault that was backed up.

The full Vault restore procedure is:

1. Start the destination Vault, with no PADR services running, and enable a user with the Restore All Safes
authorization, such as Operator.
2. On the destination Vault, Set-ARKVaultParameter in DBParm.ini: BackupFilesDeletion=No, and RecoveryPrvKey
pointing to the Recovery Private Key on the Master CD.
3. On the Replicate server, Set-ARKVaultParameter in Vault.ini: ADDRESS of the destination Vault.
4. On the Replicate server, Restore-ARKVault to copy the backup files, with -FromRestored if an archived copy of
the backup files was restored to the local Restored Safes folder.
5. Stop the destination Vault.
6. On the destination Vault, Repair-ARKVaultBackup to recover the backup files.
7. Restore-ARKVaultDatabase.
8. Reset BackupFilesDeletion in DBParm.ini (default Yes,24,1,5,7d), and remove the Recovery Private Key from the
Vault.
9. Start the Vault.

## EXAMPLES

### EXAMPLE 1
```
Restore-ARKVault -Credential (Get-Credential Operator)
```

Copies the full Vault backup files to the Restored Safes folder, using Vault.ini in the PARestore folder.

### EXAMPLE 2
```
Restore-ARKVault -LogonFile 'C:\Creds\Operator.cred' -FromRestored -Confirm:$false
```

Logs on with a credentials file and copies the archived backup files restored to the local Restored Safes
folder, without prompting.

## PARAMETERS

### -Credential
The Vault user and password.

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogonFile
The user credentials file, passed as /LogonFromFile.

```yaml
Type: String
Parameter Sets: LogonFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultFile
The Vault parameter file.
Defaults to Vault.ini in the PARestore.exe folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Vault.ini
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupPoolName
The name of the backup pool the backup files belong to.
Must match the backup pool name used by PAReplicate.

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

### -FromRestored
Copies the backup files from the Restored Safes folder on this machine, next to the SafesDirectory set in tsparm.ini,
instead of from the Safes folder.
Use it when an archived copy of the PAReplicate backup files has been restored there.
Passed as /FromRestored.

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
Prompts for confirmation by default.

Must be run from an elevated session; the command throws otherwise.

The upload can take a long time, and the PARestore.exe output is returned only when it completes.
Monitor the size of the Restored Safes folder on the destination Vault to follow progress.

Requires PARestore.exe, located with Set-ARKConfiguration -UtilityPath.
PARestore.exe runs with its own folder as the working directory.

With Credential, the password is passed on the PARestore.exe command line and is visible to other processes on the
machine while it runs.
It is masked in debug output and error records.
Use LogonFile to avoid this.

A non-zero exit code from PARestore.exe is reported as an error.

## RELATED LINKS
