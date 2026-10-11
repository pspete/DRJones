---
external help file: DRJones-help.xml
Module Name: DRJones
online version:
schema: 2.0.0
title: Restore-ARKVaultSafe
---

# Restore-ARKVaultSafe

## SYNOPSIS
Restores a Safe from backup into a new Safe using the CyberArk PARestore utility.

## SYNTAX

### Credential (Default)
```
Restore-ARKVaultSafe [-Safe] <String> [-TargetSafe] <String> -Credential <PSCredential> [-VaultFile <String>]
 [-BackupPoolName <String>] [-DataOnly] [-MetadataOnly] [-LoadOnly] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LogonFile
```
Restore-ARKVaultSafe [-Safe] <String> [-TargetSafe] <String> -LogonFile <String>
 [-VaultFile <String>] [-BackupPoolName <String>] [-DataOnly] [-MetadataOnly] [-LoadOnly] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Runs PARestore.exe to restore a single Safe from the backup files into a new Safe in the Vault.

Equivalent to: PARestore \<VaultFile\> \<User\>/\<Password\> /RestoreSafe \<Safe\> /TargetSafe \<TargetSafe\>

A Safe with the same name as the Safe being restored must exist in the Vault.
If the original Safe was deleted, create an empty Safe with the same name, with the same owners as the original.
The target Safe must not exist; PARestore creates it, with the owners of the Safe with the same name.
Backed-up owners that are not owners of that Safe are removed from the target Safe and reported as ITATS658W
warnings; if every owner is removed, only the Master user can access the target Safe.

The restoring user needs the Restore All Safes Vault authorization, typically the Operator user, or the Backup Safe
authorization in the Safe being restored.
It must be an owner of the Safe with the same name, but cannot be an owner of the restored Safe, so Administrator
cannot be used.
A user created to run PARestore must have the CABACKUP user type, which needs a CABACKUP license.

Only Safes that existed at the last full backup can be restored.
A Safe created since then, held only in incremental backups, cannot be restored individually: restore the full Vault
to an isolated server, take a full backup there, and restore the Safe from that backup.

To restore from an older backup, point SafesDirectory in tsparm.ini in the PARestore.exe folder at a folder holding
the complete Metadata folder and the Data folder of each Safe to restore, all from the same backup.
Revert tsparm.ini before the next PAReplicate backup runs.

Dependencies of restored accounts (Windows Server, Scheduled Task, IIS Application, Windows Registry, COM+ Application,
IIS Anonymous User) are not linked to their accounts and show as empty lines in the PVWA.
Add them again from the PVWA, then remove the original dependency files from the Safe with the PrivateArk Client.

## EXAMPLES

### EXAMPLE 1
```
Restore-ARKVaultSafe -Safe Banners -TargetSafe Banners_R -Credential (Get-Credential Backup)
```

Restores the Banners Safe into a new Safe named Banners_R, using Vault.ini in the PARestore folder.

### EXAMPLE 2
```
Restore-ARKVaultSafe Banners Banners_R -LogonFile 'C:\Creds\Backup.cred' -VaultFile 'C:\PrivateArk\Server\Vault.ini'
```

Restores the Banners Safe, logging on with a credentials file and a specific Vault parameter file.

### EXAMPLE 3
```
Restore-ARKVaultSafe -Safe Vines -TargetSafe Vines_R -Credential $Cred -DataOnly
```

Restores only the data files of the Vines Safe, after an earlier restore from the same backup restored the metadata.

### EXAMPLE 4
```
Restore-ARKVaultSafe -Safe Banners -TargetSafe Banners_R -LogonFile 'C:\Creds\Operator.cred' -LoadOnly
```

Restores a Safe from files copied manually, for example from a third-party backup: copy the complete Metadata folder
and the Data folder of the Safe, unrenamed, into the Restored Safes folder on the Vault server first.

## PARAMETERS

### -Safe
The name of the Safe to restore.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SafeName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetSafe
The name of the new Safe to restore into.
The Safe must not already exist.

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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DataOnly
Restores only the Safe data files, into a new target Safe.
The Vault metadata must already have been restored by an earlier restore from the same backup, for example of
another Safe.
A DataOnly restore into the target Safe of a MetadataOnly restore fails with ITATS654E.
Cannot be used with MetadataOnly.

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

### -MetadataOnly
Restores only the Safe metadata, without the data files.
The restored files are reported missing (ITATS850W) and their records kept in the Safe.
Cannot be used with DataOnly.

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

### -LoadOnly
Restores the Safe to the Vault from the files already in the Restored Safes folder on the Vault server.
Use after copying the complete Metadata folder and the Data folder of the Safe there, from a third-party backup or
an older PAReplicate backup.

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
Requires PARestore.exe, located with Set-ARKConfiguration -UtilityPath.
PARestore.exe runs with its own folder as the working directory.

With Credential, the password is passed on the PARestore.exe command line and is visible to other processes on the
machine while it runs.
It is masked in debug output and error records.
Use LogonFile to avoid this.

A non-zero exit code from PARestore.exe is reported as an error.
Each ITATS658W line in the PARestore.exe output is also written as a warning.

PARestore.exe locks Vault database tables while it runs, so it can take a long time and Vault logons can fail or
time out until it finishes.
Run it when Vault activity is low.

## RELATED LINKS
