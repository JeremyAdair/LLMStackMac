# PostgreSQL Migrations

This stack uses SQL migration files in `db/migrations/` and a runner script:

- `bin/db-migrate`

## How persistence works

Postgres data is persisted in the named Docker volume `postgres_data` (or the value of `POSTGRES_DATA_MOUNT`).

This means schema and data survive:

- host reboot
- container restart
- `docker compose up/down` (without `-v`)

Data is deleted only if you explicitly remove volumes (`down -v` or `docker volume rm`).

## Apply migrations

```bash
./bin/db-migrate
```

The runner creates/uses `public.schema_migrations` and applies each `db/migrations/*.sql` exactly once.

## Current phases

1. `001_phase1_core.sql`
2. `002_phase2_foundation.sql`
3. `003_phase3_agents_tools_memory.sql`
