# CLI Reference

Primary entrypoints:

- `llm`
- `llmstack` (alias to `llm`)

## Stack Control

- `llm up core`
- `llm up admin`
- `llm up observability`
- `llm up lab [service...]`
- `llm up full`
- `llm down core`
- `llm down all`
- `llm status`
- `llm logs <service...>`

## Models

- `llm models pull`

## Health / Debug

- `llm doctor`
- `llm check-core`
- `llm debug-bundle`
- `llm version`
- `llm self-test`

## Backup

- `llm backup [--output-dir DIR] [--keep-days N]`
- `llm restore-check <backup-dir>`

## Ingestion / Media Helpers

- `llm ingest pdf [args...]`
- `llm ocr run <filename>`
- `llm stt transcribe <file.wav>`
- `llm tts speak "text"`

## Help

- `llm --help`
- `llm -help`
