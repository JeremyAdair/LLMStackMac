# Bringup Runbook

## Ports

- `80` reverse proxy (routes to Open WebUI, Flowise, OpenHands)
- `11434` Ollama (optional direct access)
- `6333` Qdrant (optional direct access)
- `5432` Postgres (optional direct access)
- `6379` Redis (optional direct access)
- `9090` Prometheus (optional direct access)
- `3001` Grafana (optional direct access)

## Bring up the full stack

```bash
./bin/llm-up
```

## Bring up a single service

Start only Flowise:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/flowise/docker-compose.yml \
  up -d
```

Start only OpenHands:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/openhands/docker-compose.yml \
  up -d
```

Start only Ollama + Qdrant + RAG pipeline (run ingestion once):

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  up -d

docker compose \
  -f compose/docker-compose.yml \
  -f compose/rag-pipeline/docker-compose.yml \
  run --rm rag-pipeline
```

Run the PDF ingestion job:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```
