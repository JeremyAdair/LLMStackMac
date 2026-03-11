# RAG

The current RAG path is split into three pieces:

1. file intake under `data/pdfs/`
2. document conversion with `pdf-ingest`
3. embedding and indexing with `rag-pipeline`

## Folder layout

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

## Convert PDFs

```bash
./tools/bin/cli-handler/llm up lab pdf-ingest
docker compose --env-file .env.mac -p llm-lab -f compose/lab.yml run --rm pdf-ingest
```

The converter reads from `data/pdfs/ingest-dropzone/` and writes to `data/pdfs/processed/`.

## Index documents

```bash
./tools/bin/cli-handler/llm up core
./tools/bin/cli-handler/llm up lab rag-pipeline
docker compose --env-file .env.mac -p llm-lab -f compose/lab.yml run --rm rag-pipeline
```

By default:

- source text comes from `data/pdfs/processed/rawtext`
- embeddings go through `ollama-gateway`
- vectors land in Qdrant collection `documents`

## Landing-page upload path

The landing page exposes a PDF upload UI that posts to:

- `POST /pdf-api/...`

That route is proxied to `python-toolbox:8000`, not directly to Qdrant or Ollama.

## Flowise auto-ingest

`pdf-auto-ingest` still exists for Flowise-native ingestion, but it is not part of the default `llm up lab` service list. Use it only if you specifically want Flowise to own the upsert flow.
