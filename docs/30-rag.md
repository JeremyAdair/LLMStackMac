# Retrieval-Augmented Generation (RAG)

This stack ships with a simple ingestion pipeline that turns markdown into embeddings using Ollama and stores vectors in Qdrant. It also supports Flowise-driven PDF auto-ingest from a Windows bind mount.

## Workspace layout

Create the following folders in the repository root (they are gitignored):

- `workspace/ingest/` for PDFs or markdown you want to ingest.
- `workspace/processed/` for cleaned markdown output.
- `workspace/indexed/` for optional markers or logs.

## PDF ingestion

Convert PDFs into markdown text:

```bash
mkdir -p workspace/ingest workspace/processed
cp ~/Documents/example.pdf workspace/ingest/
./bin/llm-up

docker compose \
  -f compose/docker-compose.yml \
  -f compose/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```

The output markdown files will land in `workspace/processed/`.

## Flowise PDF auto-ingest (Windows bind mount)

Flowise can ingest PDFs by watching a host folder directly (no `docker cp`):

- Host path: `C:\llm-stack\pdfs`
- Container path: `/data/pdfs`

Set these values in `.env`:

```env
FLOWISE_URL=http://flowise:3000
FLOWISE_INGEST_CHATFLOW_ID=<your_ingestion_chatflow_id>
FLOWISE_INGEST_STOP_NODE_ID=qdrant_0
```

Start Flowise + watcher:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/flowise/docker-compose.yml \
  up -d flowise pdf-auto-ingest
```

Drop PDFs into `C:\llm-stack\pdfs`. The watcher uploads them to Flowise vector upsert and logs progress via:

```bash
docker logs -f llm-stack-pdf-auto-ingest-1
```

## RAG pipeline ingestion

Run the ingestion job after PDF conversion:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  -f compose/rag-pipeline/docker-compose.yml \
  run --rm rag-pipeline
```

By default, embeddings are generated through Ollama and stored in the `documents` collection in Qdrant. The pipeline reads markdown from `workspace/processed/` and `workspace/ingest/` and can be configured via `RAG_SOURCE_DIRS`. Adjust settings in `.env` to tune chunk sizes, vector size, or collection names.
