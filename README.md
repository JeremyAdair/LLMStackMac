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
- Authelia authentication gateway for protected web access.

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
- Grafana: http://localhost/grafana/
- Node-RED: http://localhost/nodered/

You will be prompted to log in via the authentication gateway.

## Access and ports

All web access goes through the reverse proxy on port 80. Use the URLs above to configure each service after logging in. Internal services and databases are not exposed on host ports by default.

The following components are job-style services, not web UIs:

- RAG pipeline: run on demand to index content.
- PDF ingestion: run on demand to convert PDFs to markdown.
- Python runner: run one-off scripts and maintenance tasks.
- STT, TTS, OCR: run on demand using the helper scripts.

If you want a single page with links to the UIs, bookmark this README or create your own landing page. The authentication gateway only handles login and redirects; it does not provide a menu of services.

### Ports you may need to change

These services publish host ports for local access. Change the host side of the
mapping if the port is already in use.

- Reverse proxy: `80` for all web UIs via the gateway.
- Forgejo web UI: `3000` for the local git server.
- Forgejo SSH: `2222` for git over SSH.
- Qdrant: `6333` for local debugging.
- Postgres: `5432` for local admin tools.
- Redis: `6379` for local debugging.

### Persistent data and reset behavior

Named volumes store service data across restarts. Removing a volume deletes that
service data. Bind mounts under `workspace/` and `workspaces/` are local folders and
can be cleaned by deleting their contents.

- Named volumes include `ollama_data`, `openwebui_data`, `qdrant_data`,
  `postgres_data`, `redis_data`, `flowise_data`, `openhands_data`, `prometheus_data`,
  `grafana_data`, and `forgejo_data`.
- `docker compose down` keeps named volumes.
- `docker compose down -v` removes named volumes, which wipes stored data.
- The `workspaces/` folder is safe to delete when you want a clean OpenHands workspace.

If you run Ollama on bare metal, keep port `11434` available on the host and point
`OLLAMA_BASE_URL` to `http://localhost:11434` in `.env`. The Ollama container does not
publish a host port by default. If you need to expose the container port, add a ports
mapping in `compose/ollama/docker-compose.yml`.

## Local Git

This stack includes an optional Forgejo service for local git hosting. Forgejo is a
lightweight, self-contained server that works well in homelab and air-gapped setups.

- Web UI: http://localhost:3000
- SSH: port 2222

If these ports are in use, update the port mappings in
`compose/forgejo/docker-compose.yml`.

Start it with:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/forgejo/docker-compose.yml \
  up -d
```

See `docs/git-local.md` for setup and backup details.

## OpenHands Workspace

The workspace container provides a safe play area for OpenHands and CLI tools. It
mounts `./workspaces` to `/workspace` and runs as a non-root user.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/workspace/docker-compose.yml \
  up -d
```

See `docs/workspace-container.md` for guardrails and reset guidance.

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

Run a Python one-off job:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/python-runner/docker-compose.yml \
  run --rm python-runner python /app/main.py
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
- `docs/60-auth.md`
- `docs/70-nodered.md`
- `docs/git-local.md`
- `docs/workspace-container.md`
- `docs/runbooks/bringup.md`

## Future hopes

The following items are planned but not complete yet. Each has a placeholder folder under `roadmap/` to track work.

| Item | Status | Notes |
| --- | --- | --- |
| Landing page | Work in progress | Simple UI that links to all protected web apps. |
| Backups | Work in progress | Backup and restore guidance for persistent data. |
| CI tests | Work in progress | Automated compose validation and lint checks. |

### Normal chat (no RAG)

```
[Browser]
   |
   v
[Reverse Proxy] ---> [Auth Gateway]
   |                    |
   |<---- session -------|
   v
(trigger: user types message)
        ↓
[Reverse Proxy + Auth Gateway]
(always-on)
        ↓
[Open WebUI]
   |
   v
[Ollama]  (LLM inference)
(always-on UI)
        ↓
[Ollama]
(always-on LLM inference)
        ↓
[Open WebUI]
(response rendered)
        ↓
[Browser]
```

### Ask questions over your docs (RAG query-time)

```
[Browser]
   |
   v
[Reverse Proxy] ---> [Auth Gateway]
   |
   v
[Flowise UI / Flowise API]  (reasoning graph)
   |
   | 1) retrieve context
   v
[Qdrant]  (vectors + payload)
   |
   | 2) generate answer with context
   v
[Ollama]  (LLM)
   |
   v
[Flowise returns answer]
   |
   v
(trigger: user asks question)
        ↓
[Reverse Proxy + Auth Gateway]
(always-on)
        ↓
[Flowise UI / API]
(always-on reasoning graph)
        ↓ retrieve context
[Qdrant]
(always-on vector store)
        ↓ context + question
[Ollama]
(always-on LLM)
        ↓ answer
[Flowise]
(reasoning output)
        ↓
[Browser]
```

### Drop a PDF, automatically OCR it, index it, then it’s searchable (RAG ingestion)

```
[You drop PDF]
into workspace/ingest/
      |
      | OCR
      v
[OCR Service]  (text extraction)
      |
      | write markdown
      v
workspace/processed/
      |
      | chunk + embed
      v
[RAG Pipeline]
      |
      | optional metadata
      v
[Postgres]  (doc index status, logs, etc.)
```

### Voice note → transcript → (optional) answer → spoken reply

```
[Audio file]
workspace/audio/in/
      |
      | STT
      v
[STT Service]  -------------> workspace/audio/out/transcript.txt
      |
      | optional RAG query
      v
[Flowise]
      |
      | TTS
      v
[TTS Service] -----------------> workspace/audio/out/reply.wav
```

### If something breaks, tell me (alerts + dashboards)

```
[All services/jobs emit metrics]
        |
        v
   [Prometheus]  (scrapes /metrics)
        |
        v
    [Grafana]  (dashboards)
        ^
        |
[Node-RED] (job status + alerts)
        |
        +----> [Discord webhook]  (notify)
```

```
[Job success / failure]
(trigger: event)
        ↓
[Node-RED]
(always-on)
        ↓
[Discord / Webhook]
(notification)
        ↓
[Prometheus]
(metrics)
        ↓+----> [Discord webhook]  (notify)
[Grafana]
(dashboard)
```

### OpenHands for repo work (guarded, not exposed)

```
[Browser]
   |
   v
[Reverse Proxy] ---> [Auth Gateway]
   |
   v
[OpenHands]
   |
   v
[Workspace]
   |
   | (optional calls)
   v
[Ollama]  (local model)  and/or  [Flowise API] (agent logic)
```

### Audio file drop pipeline

```
┌───────────────────────────┐
│ 1) LOAD AUDIO              │
│ You drop file into:        │
│ workspace/audio/in/        │
└───────────────────────────┘
        |
        v
┌───────────────────────────┐
│ 2) TRANSCRIBE              │
│ STT writes transcript to:  │
│ workspace/audio/out/       │
└───────────────────────────┘
        |
        v
┌───────────────────────────┐
│ 3) OPTIONAL RAG            │
│ Flowise queries Qdrant and │
│ Ollama for an answer       │
└───────────────────────────┘
        |
        v
┌───────────────────────────┐
│ 4) SUMMARIZE               │
│ Outputs:                   │
│ - meeting.summary.md       │
│ - meeting.summary.json     │
└───────────────────────────┘
```

### Audio File API Pipeline

```
┌───────────────────────────┐
│ 1) LOAD AUDIO              │
│ Browser upload / API post  │
└───────────────────────────┘
        |
        v
┌───────────────────────────┐
│ 2) TRANSCRIBE              │
│ STT + diarization          │
└───────────────────────────┘
        |
        v
┌───────────────────────────┐
│ 3) ENRICH                  │
│ Summarize + extract tasks  │
└───────────────────────────┘
        |
        v
┌───────────────────────────┐
│ 4) STORE                   │
│ Store (Postgres/Qdrant)    │
│ + return status to browser │
└───────────────────────────┘
```

#### Output schema

```
{
  "title": "Meeting summary",
  "summary": "...",
  "action_items": ["..."],
  "key_quotes": ["..."],
  "tags": ["work", "controls", "project-x"]
}
```

### Scheduled RAG quality evaluation

```
[Scheduled trigger]
(cron / timer)
        ↓
[Node-RED]
(always-on scheduler)
        ↓
[Python Evaluation Job]
(on-demand batch)
        ↓ test queries
[Flowise]
(reasoning with RAG)
        ↓
[Ollama]
(LLM answers)
        ↓ metrics
[Postgres]
        ↓
[Prometheus]
        ↓
[Grafana]
```

### Knowledge distillation (compress old data)

```
[Scheduled trigger]
        ↓
[Node-RED]
        ↓ select old content
[Python Job]
(chunk + select)
        ↓
[Flowise]
(distill concepts)
        ↓
[Ollama]
        ↓ summaries
[Qdrant]
(store distilled vectors)
```

### Log ingestion → anomaly explanation

```
[System logs]
(trigger: file append)
        ↓
[Node-RED]
        ↓
[Python Log Parser]
        ↓
[Flowise]
(anomaly reasoning)
        ↓
[Ollama]
(explanation)
        ↓
[Postgres + Grafana]
```
