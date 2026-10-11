# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Initial release.
- `Set-ARKConfiguration` / `Get-ARKConfiguration`: set and read the utility folders and default recovery key folder.
- `Backup-ARKVault`: back up the Vault with `PAReplicate.exe`, incremental or full.
- `Register-ARKBackupTask`: schedule weekly incremental and full `PAReplicate.exe` backups.
- `Restore-ARKVaultSafe`: restore a Safe from backup into a new Safe with `PARestore.exe`.
- `Restore-ARKRecordingSafe`: restore a recordings Safe with `PARestore.exe`.
- `Restore-ARKVault`: copy full Vault backup files to the Vault with `PARestore.exe`.
- `Restore-ARKFile`: decrypt Vault data files with `Recover.exe`.
- `Restore-ARKSafe`: decrypt Safe contents with `SafeRecover.exe`.
- `Repair-ARKVaultBackup`: recover full Vault backup files with `CAVaultManager.exe`.
- `Restore-ARKVaultDatabase`: restore the Vault database with `CAVaultManager.exe`.
- `Sync-ARKVaultDatabase`: synchronize the Vault database with `CAVaultManager.exe`.
- `Get-ARKVaultDatabaseReport`: run a Vault database diagnostic report with `CAVaultManager.exe`.
- `Get-ARKVaultParameter` / `Set-ARKVaultParameter`: read and change Vault parameter files such as `DBParm.ini` and `Vault.ini`.
