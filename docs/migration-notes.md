# Migration Notes (Layered Compose Refactor)

## What changed

- Added layered compose entrypoints:
  - `compose/core.yml`
  - `compose/data.yml`
  - `compose/observability.yml`
  - `compose/admin.yml`
  - `compose/lab.yml`
- Added operator scripts in `scripts/` for per-layer lifecycle.
- Updated `bin/llm-up`, `bin/llm-down`, and `bin/llm-status` to use layered scripts.
- Switched from one project (`llm-stack`) to multiple project names:
  - `llm-core`, `llm-data`, `llm-observability`, `llm-admin`, `llm-lab`.

## What was preserved

- Existing env var names.
- Existing bind mount paths.
- Existing named volume identities via explicit volume names (for example `llm-stack_postgres_data`).
- Existing reverse-proxy config and hostnames.

## Important behavior differences

- Services are now separated into multiple Docker Desktop groups.
- Optional services no longer run unless their layer is started.
- `bin/llm-up` now defaults to `full` for compatibility with your request to "open everything".

## Merge/defer decisions

- Deferred merge: `landing` into `reverse-proxy` (possible, but not done in this safety pass).
- Deferred merge: `python-toolbox` into `python-api` (overlap exists, but both retained for now).
- Kept `blackbox-exporter` and `postgres-exporter` in observability as optional layer members.

## Security note

- `openhands` `docker.sock` mount removed by default in lab compose for safer posture.
