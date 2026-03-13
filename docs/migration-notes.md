# Migration Notes

## Scope

This migration reorganized the repo to a layered, operator-friendly structure while preserving runtime behavior and persistent data paths.

## What moved

- `bin/` -> `tools/bin/`
- `scripts/` -> `tools/scripts/`
- `python-toolbox/` -> `services/python-toolbox/`
- `bin/Daemon/forgejo-sync-sso-users` -> `tools/daemon/forgejo-sync-sso-users/forgejo-sync-developers`
- backup/recovery utilities moved from `bin/Backup/` to `tools/jobs/`

## Path updates completed

- CLI/docs references updated from `./bin/...` to `./tools/bin/...`
- helper references updated from `./scripts/...` to `./tools/scripts/...`
- compose build contexts updated to `../services/python-toolbox`
- compose/Dockerfile COPY paths updated to `tools/scripts/...`
- launcher/setup scripts updated to call `tools/bin` and `tools/jobs` targets

## Compatibility notes

- Compose service names and data mounts were preserved.
- Persistent data remains under `data/` with existing paths.
- Layered compose entrypoints remain in `compose/*.yml`.
- Existing `llm-*` operator commands continue to work from new path `tools/bin/`.

## Validation run

- `bash -n` passed for core `tools/bin`, `tools/scripts`, `tools/daemon`, and `tools/jobs` scripts.
- `python3 -m py_compile` passed for moved Python pipeline/API files.
- `docker compose config` passed for:
  - `compose/data.yml`
  - `compose/core.yml`
  - `compose/observability.yml`
  - `compose/admin.yml`
  - `compose/lab.yml`
  - `compose/core.yml + compose/data.yml`

## Follow-up recommendations

1. If you want old muscle-memory compatibility, add tiny stubs in legacy paths that print the new path and exec the new command.
2. Keep all new tooling under `tools/` going forward to prevent top-level sprawl.
3. Review per-service READMEs over time to ensure command examples stay aligned with `tools/bin` paths.
