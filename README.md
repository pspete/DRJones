# DRJones

![DRJones: Restorers of the Lost Ark](media/DRJones-banner.svg)

**DRJones** is a PowerShell toolkit for backup and disaster recovery of CyberArk Vaults: from scheduling `PAReplicate` backups, through restoring a Safe or the whole Vault with `PARestore` and `CAVaultManager`, to decrypting Safe data offline with `Recover` and `SafeRecover`.

> _"It belongs in a Vault!"_

DR stands for Disaster Recovery, though the module answers to Doctor Jones. When the Vault is gone and all that remains is a backup and the recovery keys, Doctor Jones goes in after the lost (Cyber)Ark. Its commands take the ARK prefix, as in `Restore-ARKVault`.

| Main Branch              | CodeFactor                 | Coverage                     | PowerShell Gallery        | License                      |
| ------------------------ | -------------------------- | ---------------------------- | ------------------------- | ---------------------------- |
| [![build][]][build-site] | [![codefactor][]][cf-site] | [![codecov][]][codecov-link] | [![psgallery][]][ps-site] | [![license][]][license-link] |

[build]: https://github.com/pspete/DRJones/actions/workflows/ci.yml/badge.svg?branch=main&event=push
[build-site]: https://github.com/pspete/DRJones/actions/workflows/ci.yml?query=branch%3Amain
[psgallery]: https://img.shields.io/powershellgallery/v/DRJones.svg
[ps-site]: https://www.powershellgallery.com/packages/DRJones
[cf-site]: https://www.codefactor.io/repository/github/pspete/DRJones
[codefactor]: https://www.codefactor.io/repository/github/pspete/DRJones/badge
[codecov]: https://codecov.io/gh/pspete/DRJones/branch/main/graph/badge.svg
[codecov-link]: https://codecov.io/gh/pspete/DRJones
[license]: https://img.shields.io/github/license/pspete/DRJones.svg
[license-link]: https://github.com/pspete/DRJones/blob/main/LICENSE

> **Test it first.** Try DRJones in a non-production environment to see how it fits your own DR processes, procedures and tests before relying on it in a real recovery.

## Using the Module

### Configuration

Tell DRJones where the recovery utilities live, and where to find the recovery keys.

```powershell
Set-ARKConfiguration -UtilityPath 'C:\Program Files (x86)\PrivateArk\Server' -KeyPath 'D:\RecoveryKeys'

#PAReplicate and PARestore live on the Replicate server, CAVaultManager on the Vault server
Set-ARKConfiguration -UtilityPath 'C:\Program Files (x86)\PrivateArk\Replicate', 'C:\Program Files (x86)\PrivateArk\Server'

Get-ARKConfiguration
```

Each utility runs from the first configured folder that contains it.

The configuration is saved to `DRJonesConfiguration.xml` in your home folder and loaded on import.

`-KeyPath` can be set per command; the configured value is the default.

### Back Up the Vault

`Backup-ARKVault` runs `PAReplicate.exe` on the Replicate server to back up the Vault: full by default, incremental with `-Incremental`.

```powershell
Backup-ARKVault -LogonFile 'C:\Creds\backup.cred'
#PAReplicate.exe Vault.ini /LogonFromFile C:\Creds\backup.cred /FullBackup

Backup-ARKVault -LogonFile 'C:\Creds\backup.cred' -Incremental
#PAReplicate.exe Vault.ini /LogonFromFile C:\Creds\backup.cred

Backup-ARKVault -Credential (Get-Credential Backup) -BackupPoolName DRPool
#PAReplicate.exe Vault.ini Backup/******** /BackupPoolName DRPool /FullBackup
```

`Register-ARKBackupTask` schedules the backup as two weekly tasks running as SYSTEM: incremental Monday to Saturday, full on Sunday.

```powershell
Register-ARKBackupTask -LogonFile 'C:\Program Files (x86)\PrivateArk\Replicate\backup.cred'
#Incremental: PAReplicate.exe Vault.ini /LogonFromFile "C:\Program Files (x86)\PrivateArk\Replicate\backup.cred"
#Full:        PAReplicate.exe Vault.ini /LogonFromFile "C:\Program Files (x86)\PrivateArk\Replicate\backup.cred" /FullBackup

#Full backup on Saturday, both tasks at 22:30
Register-ARKBackupTask -LogonFile 'C:\Program Files (x86)\PrivateArk\Replicate\backup.cred' -FullBackupDay Saturday -At '22:30'
```

The tasks are registered in the `\DRJones\` Task Scheduler folder; registering them again replaces them.
`Register-ARKBackupTask` must run in an elevated session.

`-BackupPoolName` names the backup pool; restores from that backup must use the same name.

### Recover Data Files

`Restore-ARKFile` runs `Recover.exe` to decrypt Vault data files into an output folder.

```powershell
Restore-ARKFile -Path 'C:\Temp\my_data_file\*' -OutputPath 'D:\Restored' -KeyPath 'C:\Keys'
#Recover.exe C:\Temp\my_data_file\* D:\Restored C:\Keys

#One file at a time, with the key folder set with Set-ARKConfiguration
Get-ChildItem -Path 'C:\Temp\my_data_file' -File | Restore-ARKFile -OutputPath 'D:\Restored'
#Recover.exe C:\Temp\my_data_file\<file> D:\Restored D:\RecoveryKeys, for each file
```

### Recover Safes

`Restore-ARKSafe` runs `SafeRecover.exe` to decrypt the contents of a Safe into an output folder.

`SafeRecover.exe` reads the Vault Server registry settings and the Safe data from the `SafesDirectory` set in `tsparm.ini`, so it must run on a Vault server:

- from an elevated session;
- with the PrivateArk Server service stopped (the command throws if it is running);
- with the PrivateArk Database service running.

```powershell
Restore-ARKSafe -Safe Research -OutputPath 'C:\Research' -KeyPath 'C:\MasterKey'
#SafeRecover.exe Research C:\Research C:\MasterKey

#Wildcards are passed to SafeRecover
Restore-ARKSafe -Safe 'Fin*' -OutputPath 'D:\Restored'
#SafeRecover.exe Fin* D:\Restored D:\RecoveryKeys

#Many Safes from a CSV with SafeName and OutputPath columns
Import-Csv -Path .\Safes.csv | Restore-ARKSafe
#SafeRecover.exe <SafeName> <OutputPath> D:\RecoveryKeys, for each row
```

Both recovery commands:

- support `-WhatIf` and `-Confirm`;
- create the output folder if it does not exist;
- resolve relative paths against the current PowerShell location;
- report a non-zero utility exit code as an error;
- return a `DRJones.RecoveryResult` object with the utility output.

Use `-Debug` to see the exact command line passed to the utility.

### Restore a Safe to the Vault

`Restore-ARKVaultSafe` runs `PARestore.exe` to restore a Safe from backup into a new Safe.

A Safe with the same name as the Safe being restored must exist in the Vault; the target Safe must not.

Only Safes that existed at the last full backup can be restored; a Safe held only in incremental backups cannot be restored on its own.

`-BackupPoolName` must match the backup pool used by PAReplicate.

```powershell
Restore-ARKVaultSafe -Safe Banners -TargetSafe Banners_R -Credential (Get-Credential Operator)
#PARestore.exe Vault.ini Operator/******** /RestoreSafe Banners /TargetSafe Banners_R

#Log on with a credentials file instead of a password
Restore-ARKVaultSafe Banners Banners_R -LogonFile 'C:\Creds\Operator.cred'
#PARestore.exe Vault.ini /LogonFromFile C:\Creds\Operator.cred /RestoreSafe Banners /TargetSafe Banners_R

#Further Safes from the same backup: restore only their data files, reusing the metadata already restored
Restore-ARKVaultSafe Vines Vines_R -LogonFile 'C:\Creds\Operator.cred' -DataOnly
#PARestore.exe Vault.ini /LogonFromFile C:\Creds\Operator.cred /RestoreSafe Vines /TargetSafe Vines_R /DataOnly
```

### Restore a Recordings Safe

`Restore-ARKRecordingSafe` runs `PARestore.exe /RestoreRecordings`.

```powershell
#Owned by Auditors, 7 day retention by default
Restore-ARKRecordingSafe -Safe PSMRecordings -TargetSafe PSMRecordings_R -LogonFile 'C:\Creds\Operator.cred'
#PARestore.exe Vault.ini /LogonFromFile C:\Creds\Operator.cred /RestoreRecordings /RestoreSafe PSMRecordings /TargetSafe PSMRecordings_R

Restore-ARKRecordingSafe PSMRecordings PSMRecordings_R -Owners Auditors, 'Vault Admins' -Retention 30 -LogonFile 'C:\Creds\Operator.cred'
#PARestore.exe Vault.ini /LogonFromFile C:\Creds\Operator.cred /RestoreRecordings /RestoreSafe PSMRecordings /TargetSafe PSMRecordings_R /Owners "Auditors\Vault Admins" /Retention 30
```

### Restore the Whole Vault

> **All data in the destination Vault is overwritten.**

An example restore:

```powershell
#On the Replicate server: copy the backup files to the Vault
Restore-ARKVault -LogonFile 'C:\Creds\Operator.cred'
#PARestore.exe Vault.ini /LogonFromFile C:\Creds\Operator.cred /FullVaultRestore

#On the Vault server, with the Vault stopped: recover the backup files, then restore the database
Repair-ARKVaultBackup
#CAVaultManager.exe RecoverBackupFiles

Restore-ARKVaultDatabase
#CAVaultManager.exe RestoreDB /Force

#On the Vault server, with the Vault started: check the restored database
Get-ARKVaultDatabaseReport
#CAVaultManager.exe DiagnoseDBReport
```

To separate loading from synchronization, use `Restore-ARKVaultDatabase -NoSynchronize`, then `Sync-ARKVaultDatabase`:

```powershell
Restore-ARKVaultDatabase -NoSynchronize
#CAVaultManager.exe RestoreDB /NoSynchronize /Force

#Simulate: report differences only
Sync-ARKVaultDatabase
#CAVaultManager.exe SynchronizeDB /Force

#Synchronize for real, after confirmation
Sync-ARKVaultDatabase -Update
#CAVaultManager.exe SynchronizeDB /Update /Force
```

`Restore-ARKVault`, `Repair-ARKVaultBackup`, `Restore-ARKVaultDatabase` and `Get-ARKVaultDatabaseReport` must run in an elevated session.

`Restore-ARKVault`, `Repair-ARKVaultBackup`, `Restore-ARKVaultDatabase` and `Sync-ARKVaultDatabase` prompt for confirmation; use `-Confirm:$false` to skip.
`Restore-ARKVaultDatabase` and `Sync-ARKVaultDatabase` run `CAVaultManager.exe` with `/Force`, so PowerShell confirmation replaces its own prompt.

The vault restore commands return a `DRJones.UtilityResult` object with the utility output.

With `-Credential`, `PARestore.exe` and `PAReplicate.exe` receive the password on their command line, where other processes on the machine can see it.
DRJones masks it in debug output and errors; use `-LogonFile` to keep it off the command line.

### Vault Parameter Files

`Get-ARKVaultParameter` and `Set-ARKVaultParameter` read and change parameters in `DBParm.ini`, `Vault.ini` and similar files.

```powershell
$DBParm = 'C:\Program Files (x86)\PrivateArk\Server\Conf\DBParm.ini'

Get-ARKVaultParameter -Path $DBParm -Name BackupFilesDeletion, RecoveryPrvKey

#Changes an existing parameter wherever it is; -Section sets where to add a new one
Set-ARKVaultParameter -Path $DBParm -Name BackupFilesDeletion -Value No -Section BACKUP
```

The rest of the file, and its encoding, are left unchanged.

### Vault Database Report

`Get-ARKVaultDatabaseReport` runs `CAVaultManager.exe DiagnoseDBReport`, from an elevated session.

```powershell
(Get-ARKVaultDatabaseReport).StdOut | Set-Content -Path 'C:\Windows\Temp\diagnosedbreport.txt'
```

## Module Commands

| Command                      | Description                                                      |
| ---------------------------- | ---------------------------------------------------------------- |
| `Set-ARKConfiguration`       | Set the utility folders and default recovery key folder          |
| `Get-ARKConfiguration`       | Get the utility folders and default recovery key folder          |
| `Backup-ARKVault`            | Back up the Vault with `PAReplicate.exe`                         |
| `Register-ARKBackupTask`     | Schedule weekly incremental and full `PAReplicate.exe` backups   |
| `Restore-ARKFile`            | Decrypt Vault data files with `Recover.exe`                      |
| `Restore-ARKSafe`            | Decrypt the contents of a Safe with `SafeRecover.exe`            |
| `Restore-ARKVaultSafe`       | Restore a Safe from backup into a new Safe with `PARestore.exe`  |
| `Restore-ARKRecordingSafe`   | Restore a recordings Safe with `PARestore.exe`                   |
| `Restore-ARKVault`           | Copy full Vault backup files to the Vault with `PARestore.exe`   |
| `Repair-ARKVaultBackup`      | Recover full Vault backup files with `CAVaultManager.exe`        |
| `Restore-ARKVaultDatabase`   | Restore the Vault database with `CAVaultManager.exe`             |
| `Sync-ARKVaultDatabase`      | Synchronize the Vault database with `CAVaultManager.exe`         |
| `Get-ARKVaultDatabaseReport` | Run a Vault database diagnostic report with `CAVaultManager.exe` |
| `Get-ARKVaultParameter`      | Get parameters from `DBParm.ini`, `Vault.ini` and similar files  |
| `Set-ARKVaultParameter`      | Set a parameter in `DBParm.ini`, `Vault.ini` and similar files   |

## Installation

### Prerequisites

- Requires Powershell Core (recommended), or Windows PowerShell (version 5.1), on Windows
- CyberArk `Recover.exe` and `SafeRecover.exe`
  - `SafeRecover.exe` must run on a Vault server
- CyberArk `PAReplicate.exe` & `PARestore.exe`, from the Replicate installation, and `CAVaultManager.exe`, from the Vault server installation
- For Vault restores: a Vault user with the _Restore All Safes_ authorization, and the Master CD for a full Vault restore
- The Vault recovery keys (Recovery Private Key)
- The Vault data (Safes and metadata) to recover

### Install Options

Users can install DRJones from GitHub or the PowerShell Gallery.

Choose any of the following ways to download the module and install it:

#### Option 1: Install from PowerShell Gallery

This is the easiest and most popular way to install the module:

1. Open a PowerShell prompt

2. Run the following command:

```powershell
Install-Module -Name DRJones -Scope CurrentUser
```

#### Option 2: Manual Install

The module files can be manually copied to one of your PowerShell module directories.

Use the following command to get the paths to your local PowerShell module folders:

```powershell

$env:PSModulePath.split(';')

```

The module files must be placed in one of the listed directories, in a folder called `DRJones`.

More: [about_PSModulePath](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)

The module files are available to download using a variety of methods:

##### PowerShell Gallery

- Download from the module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/DRJones/):
  - Run the PowerShell command `Save-Module -Name DRJones -Path C:\temp`
  - Copy the `C:\temp\DRJones` folder to your "Powershell Modules" directory of choice.

##### DRJones Release

- [Download the latest GitHub release](https://github.com/pspete/DRJones/releases/latest)
  - Unblock & Extract the archive
  - Rename the extracted `DRJones-v#.#.#` folder to `DRJones`
  - Copy the `DRJones` folder to your "Powershell Modules" directory of choice.

##### DRJones Branch

- [Download the `main` branch](https://github.com/pspete/DRJones/archive/refs/heads/main.zip)
  - Unblock & Extract the archive
  - Copy the `DRJones` (`\<Archive Root>\DRJones-main\DRJones`) folder to your "Powershell Modules" directory of choice.

#### Verification

Validate Install:

```powershell

Get-Module -ListAvailable DRJones

```

Import the module:

```powershell

Import-Module DRJones

```

List Module Commands:

```powershell

Get-Command -Module DRJones

```

Get detailed information on specific commands:

```powershell

Get-Help Restore-ARKSafe -Full

```

## Sponsorship

Please support continued development; consider sponsoring <a href="https://github.com/sponsors/pspete"> @pspete on GitHub Sponsors</a>

## Changelog

All notable changes to this project will be documented in the [Changelog](CHANGELOG.md)

## Author

- **Pete Maan** - [pspete](https://github.com/pspete)

## License

This project is [licensed under the MIT License](LICENSE).

## Contributing

Any and all contributions to this project are appreciated.

See the [CONTRIBUTING.md](CONTRIBUTING.md) for a few more details.

## Support

_DRJones_ is neither developed nor supported by CyberArk/Palo Alto; any official support channels offered by the vendor are not appropriate for seeking help with the _DRJones_ module.

Help and support should be sought by [opening an issue][new-issue].

[new-issue]: https://github.com/pspete/DRJones/issues/new

Priority support could be considered for <a href="https://github.com/sponsors/pspete">sponsors of @pspete</a>, <a href="mailto:pspete@pspete.dev">contact us</a> to discuss options.
