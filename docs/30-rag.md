# Retrieval-Augmented Generation (RAG)

This stack ships with a simple ingestion pipeline that turns markdown into embeddings using Ollama and stores vectors in Qdrant. It also supports Flowise-driven PDF auto-ingest from a local bind mount.

## Storage layout

Use a single PDF pipeline path in the repository root (gitignored):

- `data/pdfs/` for incoming PDFs
- `data/pdfs/ingest-dropzone/` for manual PDF-to-markdown conversion input
- `data/pdfs/processed/` for converted markdown and successful ingest outputs
- `data/pdfs/failed/` for failed ingest files

## PDF ingestion

Convert PDFs into markdown text:

```bash
mkdir -p data/pdfs/ingest-dropzone data/pdfs/processed data/pdfs/failed
cp ~/Documents/example.pdf data/pdfs/ingest-dropzone/
./bin/llm-up

docker compose \
  -f compose/lab/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```

The output markdown files land in `data/pdfs/processed/`.

## Flowise PDF auto-ingest

Flowise can ingest PDFs by watching a host folder directly (no `docker cp`):

- Host path: `./data/pdfs`
- Container path: `/data/pdfs`

Set these values in `.env.mac`:

```env
FLOWISE_URL=http://flowise:3000
FLOWISE_INGEST_CHATFLOW_ID=<your_ingestion_chatflow_id>
FLOWISE_INGEST_STOP_NODE_ID=qdrant_0
```

Start Flowise + watcher:

```bash
docker compose \
  -f compose/lab/ollama/docker-compose.yml \
  -f compose/core/flowise/docker-compose.yml \
  up -d flowise pdf-auto-ingest
```

Drop PDFs into `./data/pdfs`. The watcher uploads them to Flowise vector upsert and logs progress via:

```bash
docker logs -f llm-lab-pdf-auto-ingest-1
```

## RAG pipeline ingestion

Run the ingestion job after PDF conversion:

```bash
docker compose \
  -f compose/lab/ollama/docker-compose.yml \
  -f compose/data/qdrant/docker-compose.yml \
  -f compose/lab/rag-pipeline/docker-compose.yml \
  run --rm rag-pipeline
```

By default, embeddings are generated through Ollama and stored in the `documents` collection in Qdrant. The pipeline reads markdown from `data/pdfs/processed/` and can be configured via `RAG_SOURCE_DIRS`. Adjust settings in `.env` to tune chunk sizes, vector size, or collection names.
