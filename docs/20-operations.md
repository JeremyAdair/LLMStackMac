# Operations Quickstart

This file is superseded by `docs/stack-modes.md` for day-to-day stack lifecycle in the layered compose architecture.

This guide covers daily operations: start, stop, status, logs, updates, and backups.

## Start the stack

```bash
./bin/llm-up
```

This starts the default core services only.

## Start observability

```bash
./bin/llm-up observability
```

Add deep probe/database exporters when needed:

```bash
./bin/llm-up observability
```

## Start admin tools

```bash
./bin/llm-up admin
```

## Start lab services

```bash
./bin/llm-up lab
```

On macOS, this also starts host (bare-metal) Ollama if `ollama` is installed locally.
Disable with `LLMSTACK_MANAGE_HOST_OLLAMA=0`.

## Start full lab stack

```bash
./bin/llm-up full
```

## Stop the stack

```bash
./bin/llm-down
```

On macOS, this also stops host (bare-metal) Ollama unless disabled via
`LLMSTACK_MANAGE_HOST_OLLAMA=0`.

## Status

```bash
./bin/llm-status
```

## Logs

All logs (tail):

```bash
./bin/llm-logs reverse-proxy auth
```

Service-specific logs:

```bash
SINCE=2h ./bin/llm-logs flowise
```

## Restart a service

```bash
./bin/llm-up core
```

## Update images safely

```bash
./bin/llm-down core
./bin/llm-up core
```

## Backups

### What to back up

- `data/ollama/` or the Ollama model volume
- `data/qdrant/`
- `data/postgres/`
- `data/redis/` (if used)
- `data/node-red/`
- `config/` and `.env`

### Simple backup approach

Stop the stack, then archive data directories:

```bash
./bin/llm-down

tar -czf backups/llmstack-data-$(date +%F).tar.gz data config .env
```

## Restore overview

Extract the archive back to the repo root, then start the stack:

```bash
tar -xzf backups/llmstack-data-YYYY-MM-DD.tar.gz
./bin/llm-up
```

## Add a new service module

1) Create `compose/<service>/docker-compose.yml`.
2) Add any config under `config/<service>/`.
3) Add persistent data under `data/<service>/` (gitignored).
4) Add the compose file to `bin/llm-up`, `bin/llm-down`, and `bin/llm-status`.
5) Assign service profile (`core` unprofiled, or `observability`, `observability-plus`, `admin`, `lab`).
6) Document the service in `docs/`.
