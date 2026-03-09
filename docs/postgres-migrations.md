# PostgreSQL Architecture and Migrations

This document is the source of truth for what Postgres is currently doing in this stack.

## Scope

Postgres is used for structured application state. It stores:

- user and identity records for app-level ownership (`auth`)
- chat threads and message history (`chat`)
- reusable prompts and prompt versions (`prompting`)
- document metadata, chunk records, and vector references (`knowledge`)
- background job orchestration state (`jobs`)
- model catalog metadata (`models`)
- inference event telemetry summaries (`observability`)
- workflow and tool metadata (`agents`, `tools`)
- structured long-term memory records (`memory`)

It does **not** store:

- embeddings (kept in Qdrant)
- model files (kept in Ollama/model storage)
- large binary file payloads (kept on filesystem/object storage)

## Persistence Model

Postgres data is persisted in the Docker named volume:

- `llm-stack_postgres_data` (from compose volume `postgres_data`)

Mounted path inside container:

- `/var/lib/postgresql/data`

This survives:

- host reboot
- container restart/recreate
- normal `docker compose up/down` (without `-v`)

This is destroyed only by explicit destructive operations such as:

- `docker compose down -v`
- `docker volume rm llm-stack_postgres_data`

## Security/Auth Defaults

Current Postgres auth posture:

- host auth is SCRAM-based (`scram-sha-256`)
- explicit credentials are required in `.env.mac`:
  - `POSTGRES_USER`
  - `POSTGRES_PASSWORD`
  - `POSTGRES_DB`

## Migration System

Migration files live in:

- `db/migrations/`

Migration runner:

- `bin/db-migrate`

Runner behavior:

1. loads Postgres credentials from `.env.mac`/`.env`
2. ensures migration tracking table exists:
   - `public.schema_migrations`
3. applies each `db/migrations/*.sql` in lexical order
4. records applied file names to prevent re-running the same migration

## Current Migration Phases

1. `001_phase1_core.sql`
2. `002_phase2_foundation.sql`
3. `003_phase3_agents_tools_memory.sql`

## Tables Created by Phase

### Phase 1 (Core Backbone)

- `auth.users`
- `chat.conversations`
- `chat.messages`
- `prompting.prompt_templates`
- `knowledge.documents`
- `jobs.jobs`

### Phase 2 (Knowledge + Model + Observability Foundation)

- `chat.message_metadata`
- `chat.conversation_summaries`
- `prompting.prompt_versions`
- `models.model_registry`
- `knowledge.document_collections`
- `knowledge.chunks`
- `knowledge.chunk_vector_refs`
- `observability.inference_events`

### Phase 3 (Agents / Tools / Memory)

- `tools.tools`
- `tools.tool_permissions`
- `agents.workflows`
- `agents.workflow_runs`
- `memory.memory_entries`

## Runtime Notes and Operational Behavior

### Search Path

The DB role is configured with schema search path so custom schemas are visible by default:

- `auth, chat, prompting, knowledge, jobs, models, observability, agents, tools, memory, public`

Without this, pgAdmin users often only see `public` and assume tables are missing.

### pgAdmin Visibility

If pgAdmin does not show expected objects:

1. verify you are connected to database `llmstack` (not another DB)
2. reconnect server in pgAdmin
3. expand `Schemas` and ensure non-public schemas are visible

### Identity Sync Clarification

`auth.users` is an app data table, not Authelia's internal user DB.
It does not auto-sync from Authelia by default unless explicit sync logic is added.

Current known rows were synced manually/upserted for:

- `admin`
- `jeremyadair87`
- `sso_test`

## Commands

Apply migrations:

```bash
./bin/db-migrate
```

Show applied migrations:

```bash
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" llm-stack-postgres-1 \
  psql -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -c "select * from public.schema_migrations order by name;"
```

Quick table check for managed schemas:

```bash
docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" llm-stack-postgres-1 \
  psql -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -c "select table_schema, table_name from information_schema.tables
      where table_schema in ('auth','chat','prompting','knowledge','jobs','models','observability','agents','tools','memory')
      order by table_schema, table_name;"
```
