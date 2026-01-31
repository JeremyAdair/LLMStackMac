# Python toolbox

This directory provides a Dockerized Python toolbox for CLI scripts and an optional
FastAPI surface for job triggers from Node-RED or Flowise.

## Build and run

From the repo root:

```bash
docker compose -f compose/docker-compose.yml build python-toolbox
```

Start the toolbox container:

```bash
docker compose -f compose/docker-compose.yml up -d python-toolbox
```

Start the API container:

```bash
docker compose -f compose/docker-compose.yml up -d python-api
```

## Exec into the toolbox and run scripts

```bash
docker compose -f compose/docker-compose.yml exec python-toolbox bash
```

Example script runs:

```bash
python /app/scripts/plc_poll/poll_plc.py
python /app/scripts/rag_ingest/ingest_folder.py
python /app/scripts/db_tools/healthcheck.py
```

## Environment variables

Common variables:

- `REDIS_URL` default: `redis://redis:6379/0`
- `DATABASE_URL` optional, for Postgres writes
- `QDRANT_URL` default: `http://qdrant:6333`
- `QDRANT_COLLECTION` default: `documents`

PLC polling:

- `PLC_IP` default: `127.0.0.1`
- `PLC_SLOT` default: `0`
- `PLC_TIMEOUT` default: `1.0`
- `POLL_INTERVAL_MS` default: `1000`
- `PLC_TAGSET_PATH` default: `/app/scripts/plc_poll/tagsets.example.yaml`

RAG ingestion:

- `INGEST_PATH` default: `/app/ingest`
- `EMBED_MODEL` default: `all-MiniLM-L6-v2`
- `INGEST_INTERVAL` default: `60` seconds

## Example compose usage

The repo-level compose file already includes the services. The key pieces are:

```yaml
python-toolbox:
  build:
    context: ../python-toolbox
    dockerfile: Dockerfile
  command: ["sleep", "infinity"]
  volumes:
    - ../python-toolbox/app:/app

python-api:
  image: llmstack/python-toolbox:local
  command: ["uvicorn", "api.app:app", "--host", "0.0.0.0", "--port", "8000"]
  ports:
    - "8000:8000"
  volumes:
    - ../python-toolbox/app:/app
```

## PLC polling best practices

- Run a single polling loop per PLC. Multiple pollers cause noisy data and extra load.
- Use Redis as a shared cache for current values.
- If you enable Postgres writes, ensure indexes match your query patterns.
