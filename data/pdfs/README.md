# PDF Ingestion Workspace

This folder is the canonical PDF ingestion path for this stack.

## What this folder is for

- Drop incoming PDF files into `data/pdfs/`.
- Converted markdown and successful ingest outputs go to `data/pdfs/processed/`.
- Failed auto-ingest files go to `data/pdfs/failed/`.

## Pipeline flow

1. Place PDF files in `data/pdfs/`.
2. Run conversion job:
   - `docker compose --env-file .env.mac -p llm-lab -f compose/lab.yml run --rm pdf-ingest`
3. Run embedding/indexing job:
   - `docker compose --env-file .env.mac -p llm-lab -f compose/lab.yml run --rm rag-pipeline`
4. Optional watcher (`pdf-auto-ingest`) can upload PDFs directly through Flowise.

## Notes

- This path replaced the older split flow that used `workspace/ingest` and `workspace/processed` for PDFs.
- Keep this directory in place; services and docs assume this location.
