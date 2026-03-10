# Retrieval-Augmented Generation (RAG)

This stack ships with a simple ingestion pipeline that turns markdown into embeddings using Ollama and stores vectors in Qdrant. It also supports Flowise-driven PDF auto-ingest from a local bind mount.

## Storage layout

Use a single PDF pipeline path in the repository root (gitignored):

- `data/pdfs/` for incoming PDFs
- `data/pdfs/ingest-dropzone/` for manual PDF-to-markdown conversion input
- `data/pdfs/processed/original/` for original source files after successful processing
- `data/pdfs/processed/rawtext/` for extracted markdown text
- `data/pdfs/processed/json/` for per-file processing metadata
- `data/pdfs/processed/chunk/` for chunked markdown artifacts
- `data/pdfs/failed/` for failed ingest files

## PDF ingestion

Convert PDFs into markdown text:

```bash
mkdir -p data/pdfs/ingest-dropzone data/pdfs/processed/{original,rawtext,json,chunk} data/pdfs/failed
cp ~/Documents/example.pdf data/pdfs/ingest-dropzone/
./tools/bin/llm up full

docker compose \
  -f compose/lab/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```

The output markdown files land in `data/pdfs/processed/rawtext/`.

## Landing page PDF upload (human interface)

Use the landing page button:

- `https://llmstack.lan/` -> **PDF** -> `pdf-dropzone.html`

The page uploads PDFs to the backend API:

- `POST /pdf-api/pdf/upload`

The API stores uploads in:

- `data/pdfs/ingest-dropzone/`

It never writes directly to Qdrant from the UI layer.

## Autoscan worker (processing + indexing)

The `python-toolbox` service now includes a background watcher that monitors:

- `data/pdfs/ingest-dropzone/`

For each new PDF, it:

1. extracts raw text
2. writes raw text to `data/pdfs/processed/rawtext/`
3. writes metadata JSON to `data/pdfs/processed/json/`
4. writes chunk files to `data/pdfs/processed/chunk/`
5. generates embeddings through Ollama
6. upserts vectors into Qdrant
7. moves original PDF to `data/pdfs/processed/original/` on success
8. moves original PDF to `data/pdfs/failed/` on failure and writes an error log

Duplicate filenames are handled with suffixing (timestamp + short UUID) so existing files are never overwritten.

## Flowise PDF auto-ingest

This is optional/legacy for Flowise-native vector upserts and is no longer part of the default `llm up lab` start list.

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

Drop PDFs into `./data/pdfs/ingest-dropzone`. The watcher uploads them to Flowise vector upsert and logs progress via:

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

By default, embeddings are generated through Ollama and stored in the `documents` collection in Qdrant. The pipeline reads markdown from `data/pdfs/processed/rawtext/` and can be configured via `RAG_SOURCE_DIRS`. Adjust settings in `.env` to tune chunk sizes, vector size, or collection names.
