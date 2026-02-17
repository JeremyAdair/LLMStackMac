# Agents

## Flowise

Flowise provides a visual agent builder. It is configured to talk to Ollama on the internal Docker network.

Access it through the reverse proxy at:

- `http://localhost/flowise/`

You can optionally set `FLOWISE_USERNAME` and `FLOWISE_PASSWORD` in `.env` to enable basic auth.

For PDF auto-ingest with Docker Desktop on Windows, configure:

- Host folder: `C:\llm-stack\pdfs`
- Container path: `/data/pdfs`
- `.env`:
  - `FLOWISE_URL=http://flowise:3000`
  - `FLOWISE_INGEST_CHATFLOW_ID=<your_ingestion_chatflow_id>`
  - `FLOWISE_INGEST_STOP_NODE_ID=qdrant_0`

## OpenHands

OpenHands provides an agentic coding workspace. It is only reachable through the reverse proxy by default.

Access it at:

- `http://localhost/openhands/`
