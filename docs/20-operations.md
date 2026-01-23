# Operations Quickstart

This guide covers daily operations: start, stop, status, logs, updates, and backups.

## Start the stack

```bash
./bin/llm-up
```

## Start landing page and proxy only

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/reverse-proxy/docker-compose.yml \
  -f compose/auth/docker-compose.yml \
  -f compose/landing/docker-compose.yml \
  up -d
```

## Stop the stack

```bash
./bin/llm-down
```

## Status

```bash
./bin/llm-status
```

## Logs

All logs (tail):

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/reverse-proxy/docker-compose.yml \
  -f compose/auth/docker-compose.yml \
  logs -f
```

Service-specific logs:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  logs -f ollama
```

## Restart a service

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/open-webui/docker-compose.yml \
  restart open-webui
```

## Update images safely

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/open-webui/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  pull

docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/open-webui/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
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
5) Document the service in `docs/`.
