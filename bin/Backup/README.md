# Backup Scripts

This folder contains the LLMStack backup and restore-validation scripts.

## Scripts

- `llm-backup`
  - Creates a timestamped backup set under `data/backups/backup-YYYYMMDD-HHMMSS`.
  - Captures:
    - metadata (`meta/`)
    - repo config snapshot (`files/repo-config.tar.gz`)
    - repo data snapshot excluding `data/backups` (`files/repo-data.tar.gz`)
    - Postgres logical dump when `llm-data-postgres-1` is running (`db/postgres-dumpall.sql.gz`)
    - Docker volume archives for volumes named `llm-stack_*` (`volumes/*.tar.gz`)
    - checksums (`checksums.sha256`)

- `llm-restore-check`
  - Validates a backup directory before restore.
  - Checks required structure, verifies checksums, tests archive readability, and reports missing/corrupt artifacts.

## Usage

Run from repo root:

```bash
./bin/Backup/llm-backup
```

Optional retention cleanup:

```bash
./bin/Backup/llm-backup --keep-days 14
```

Validate a specific backup before restore:

```bash
./bin/Backup/llm-restore-check ./data/backups/backup-YYYYMMDD-HHMMSS
```

## Notes

- These scripts are for Docker-based LLMStack backups on this host.
- `llm-restore-check` does not restore data; it only validates backup integrity.
- Keep backups off-host or on external storage for disaster recovery.
