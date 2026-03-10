# PDF Ingestion Flow

## Purpose

This stack supports two ingestion entry methods:

- Human upload from the landing page (`/pdf-dropzone.html`)
- Automation drop into `data/pdfs/ingest-dropzone/`

Both methods converge on the same filesystem entrypoint:

- `data/pdfs/ingest-dropzone/`

## Architecture

1. Landing page uploads PDFs to `POST /pdf-api/pdf/upload`.
2. Reverse proxy forwards `/pdf-api/*` to `python-toolbox:8000`.
3. The upload API stores files in `data/pdfs/ingest-dropzone/`.
4. The PDF ingest watcher (inside `python-toolbox`) scans the folder.
5. For each PDF, it extracts text, chunks content, generates embeddings via Ollama, and upserts vectors into Qdrant.

## Folder lifecycle

```text
data/pdfs/
  ingest-dropzone/
  processed/
    original/
    rawtext/
    json/
    chunk/
  failed/
```

- New files arrive in `ingest-dropzone/`.
- On success:
  - original PDF -> `processed/original/`
  - extracted text -> `processed/rawtext/`
  - metadata -> `processed/json/`
  - chunk files -> `processed/chunk/`
  - embeddings -> Qdrant collection (`RAG_COLLECTION`)
- On failure:
  - original PDF -> `failed/`
  - error log -> `failed/*.error.log`

## Duplicate handling

Uploads and worker outputs never overwrite existing files.

When a name collision occurs, a suffix is appended:

- timestamp + short UUID

Example:

- `document.pdf`
- `document_20260310_013015_a1b2c3.pdf`

## Configuration

Relevant env vars:

- `PDF_INGEST_WATCHER_ENABLED` (default `true`)
- `PDF_INGEST_WATCH_INTERVAL` (default `3`)
- `OLLAMA_BASE_URL`
- `QDRANT_URL`
- `RAG_COLLECTION`
- `RAG_EMBED_MODEL`
- `RAG_CHUNK_SIZE`
- `RAG_CHUNK_OVERLAP`

## Operational notes

- The landing page only handles upload to dropzone.
- Vector indexing is performed only by the worker.
- Future automation can ingest by dropping PDFs into `data/pdfs/ingest-dropzone/`.
