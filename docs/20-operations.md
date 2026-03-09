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
./bin/llm-up --profile observability
```

Add deep probe/database exporters when needed:

```bash
./bin/llm-up --profile observability --profile observability-plus
```

## Start admin tools

```bash
./bin/llm-up --profile admin
```

## Start lab services

```bash
./bin/llm-up --profile lab
```

On macOS, this also starts host (bare-metal) Ollama if `ollama` is installed locally.
Disable with `LLMSTACK_MANAGE_HOST_OLLAMA=0`.

## Start full lab stack

```bash
./bin/llm-up --profile admin --profile observability --profile observability-plus --profile lab
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
docker compose \
  -f compose/docker-compose.yml \
  -f compose/core/reverse-proxy/docker-compose.yml \
  -f compose/core/auth/docker-compose.yml \
  logs -f
```

Service-specific logs:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/lab/ollama/docker-compose.yml \
  logs -f ollama
```

## Restart a service

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/core/open-webui/docker-compose.yml \
  restart open-webui
```

## Update images safely

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/lab/ollama/docker-compose.yml \
  -f compose/core/open-webui/docker-compose.yml \
  -f compose/data/qdrant/docker-compose.yml \
  pull

docker compose \
  -f compose/docker-compose.yml \
  -f compose/lab/ollama/docker-compose.yml \
  -f compose/core/open-webui/docker-compose.yml \
  -f compose/data/qdrant/docker-compose.yml \
  up -d
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
