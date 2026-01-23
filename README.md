# LLMStack

LLMStack is a self-hosted local LLM stack built around Docker Compose. It provides a modular setup for running models, a web UI, vector search, RAG ingestion, and optional agent tooling.

## What is included

- Ollama for running local models.
- Open WebUI for a browser-based chat interface.
- Qdrant for vector search.
- Postgres and Redis as optional supporting services.
- Flowise for visual agent graphs.
- OpenHands for an agentic coding workspace.
- PDF ingestion and a simple RAG pipeline for indexing documents.
- Local speech-to-text, text-to-speech, and OCR utilities.

## Quick start

1) Copy the environment example.

```bash
cp .env.example .env
```

2) Start the full stack.

```bash
./bin/llm-up
```

3) Open the UI via the reverse proxy.

- Open WebUI: http://localhost/
- Flowise: http://localhost/flowise/
- OpenHands: http://localhost/openhands/

## Workspace convention

The ingestion pipeline uses a shared workspace directory in the repo root:

- `workspace/ingest/` for PDFs or markdown you want to ingest.
- `workspace/processed/` for cleaned markdown output.
- `workspace/indexed/` for markers or logs.

These folders are gitignored. Create them when needed:

```bash
mkdir -p workspace/ingest workspace/processed workspace/indexed
```

## Common tasks

Run PDF ingestion:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```

Run the RAG pipeline (Ollama + Qdrant + ingestion job):

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

Start only Flowise:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/flowise/docker-compose.yml \
  up -d
```

Install speech and OCR models:

```bash
./bin/models-pull
```

Run a speech-to-text example:

```bash
./bin/stt-transcribe sample.wav
```

Place `sample.wav` in `workspace/audio/in/` before running the command.

## Documentation

See the docs for details:

- `docs/10-install.md`
- `docs/30-rag.md`
- `docs/40-agents.md`
- `docs/50-media.md`
- `docs/runbooks/bringup.md`
