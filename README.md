# LLMStack

LLMStack is a self-hosted local LLM stack built around Docker Compose. It provides a modular setup for running models, a web UI, vector search, RAG ingestion, and optional agent tooling.

## Recent updates

- Forgejo is now routed through the reverse proxy at `https://forgejo.llmstack.lan/`.
- Authelia is configured as the SSO gateway for the stack so you don't have to manage separate passwords per app.
- Flowise supports PDF drop-in via bind mount: `./data/pdfs` -> `/data/pdfs`.
- Added `pdf-auto-ingest` watcher service to auto-upsert dropped PDFs through Flowise.
- Rebuilt Flowise PDF ingestion and retrieval chatflows with current node wiring for latest Flowise compatibility.
- OpenWebUI API proxy auth handling was adjusted to prevent chat timeout/500 issues.

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

## Service layers

Use this as a quick reference for what each service does, grouped by operational layer.

### 1) Core runtime layer

This is the stuff that makes AI actually run.

| Service | Purpose | Typical need |
|---|---|---|
| `open-webui` | Main chat interface and user-facing AI workspace. | Core |
| `ollama` | Local model inference backend. | Core |
| `postgres` | Structured app state and relational data storage. | Core |
| `qdrant` | Vector index and similarity retrieval for RAG. | Core for RAG |

### 2) Platform services layer

This is the stuff that supports the runtime.

| Service | Purpose | Typical need |
|---|---|---|
| `reverse-proxy` | Single web entrypoint on 80/443 and routing for all UIs. | Core |
| `auth` (Authelia) | Login and access control in front of protected routes. | Core |
| `redis` | Cache/queue support for supporting services and workflows. | Optional |
| `python-api` | FastAPI endpoints for stack automation jobs. | Optional |
| `python-toolbox` | Script runtime container for maintenance/one-off jobs. | Optional |
| `landing` | Landing page and navigation for stack services. | Optional |
| `forgejo` | Self-hosted Git service for local repos/collaboration. | Optional |

### 3) Observability layer

This is how you inspect and understand the system.

| Service | Purpose | Typical need |
|---|---|---|
| `prometheus` | Metrics scraping and storage. | Optional |
| `grafana` | Metrics dashboards and alert visualization. | Optional |
| `pgadmin` | Postgres inspection and query administration. | Optional |
| `redisinsight` | Redis inspection and operational troubleshooting. | Optional |

### 4) Automation and tooling layer

This is where the stack starts doing useful work beyond just chatting.

| Service | Purpose | Typical need |
|---|---|---|
| `flowise` | Visual workflow/agent builder and API flows. | Optional |
| `node-red` | Low-code automation and orchestration. | Optional |
| `pdf-auto-ingest` | Watches PDF folder and auto-upserts to Flowise/RAG. | Optional |

### 5) Experimental layer

This is the stuff you are testing, learning, or may remove later.

| Service | Purpose | Typical need |
|---|---|---|
| `openclaw` | Agent gateway/runtime UI for advanced local workflows. | Optional |
| `openhands` | Agentic coding workspace service. | Optional |

Job-style services are run on demand rather than left up all the time (RAG pipeline, PDF ingest jobs, STT, TTS, OCR).

## Quick start

1) Copy the macOS environment example.

```bash
cp .env.mac.example .env.mac
cp config/auth/users_database.example.yml config/auth/users_database.yml
```

2) Start the full stack.

```bash
./bin/llm-up
```

On macOS, `./bin/llm-up` also starts host (bare-metal) Ollama when installed locally,
and `./bin/llm-down` stops it. Set `LLMSTACK_MANAGE_HOST_OLLAMA=0` to disable this behavior.

macOS first-run shortcut:

```bash
./bin/first-run-mac
./bin/llm-up
./bin/llm-check-core
```

Cutover day runbook:

- `MAC-CUTOVER-CHECKLIST.md`
- `docs/AI-HANDOFF.md`

3) Open the UI via the reverse proxy.

Add these entries to your hosts file first:

```
127.0.0.1  llmstack.lan
127.0.0.1  openwebui.llmstack.lan
127.0.0.1  flowise.llmstack.lan
127.0.0.1  openhands.llmstack.lan
127.0.0.1  openclaw.llmstack.lan
127.0.0.1  grafana.llmstack.lan
127.0.0.1  nodered.llmstack.lan
127.0.0.1  forgejo.llmstack.lan
```

Generate this block automatically:

```bash
./bin/hosts-entries
```

macOS hosts file path: `/etc/hosts`

```bash
sudo nano /etc/hosts
```

After saving on macOS, flush DNS cache:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Then open:

- Landing page: https://llmstack.lan/
- Authelia login: https://llmstack.lan/authelia/
- Open WebUI: https://openwebui.llmstack.lan/
- Flowise: https://flowise.llmstack.lan/
- OpenHands: https://openhands.llmstack.lan/
- OpenClaw: https://openclaw.llmstack.lan/
- Grafana: https://grafana.llmstack.lan/
- Node-RED: https://nodered.llmstack.lan/
- Forgejo: https://forgejo.llmstack.lan/

You will be prompted to log in via Authelia. The first visit to each subdomain will
also show a browser TLS warning because a self-signed cert is used for local HTTPS.

## Access and ports

All web access goes through the reverse proxy on ports 80/443. Use the URLs above to
reach each service after logging in. Internal services and databases are not exposed
on host ports by default.

The following components are job-style services, not web UIs:

- RAG pipeline: run on demand to index content.
- PDF ingestion: run on demand to convert PDFs to markdown.
- Flowise PDF auto-ingest: optional watcher for PDFs dropped into a bind-mounted host folder.
- Python toolbox: run one-off scripts and maintenance tasks.
- STT, TTS, OCR: run on demand using the helper scripts.

The landing page at https://llmstack.lan/ provides links to the protected UIs after
you authenticate. Authelia only handles login and redirects; it does not provide a
service menu.

## Python toolbox

The python-toolbox container is a CLI-first environment for running scripts under
`python-toolbox/app`. The python-api container uses the same image but serves a
FastAPI surface on port 8000 for Node-RED or Flowise triggers.

Build the image:

```bash
docker compose -f compose/docker-compose.yml build python-toolbox
```

Start the toolbox container and exec into it:

```bash
docker compose -f compose/docker-compose.yml up -d python-toolbox
docker compose -f compose/docker-compose.yml exec python-toolbox bash
```

Start the API container:

```bash
docker compose -f compose/docker-compose.yml up -d python-api
```

Example script runs:

```bash
python /app/scripts/plc_poll/poll_plc.py
python /app/scripts/rag_ingest/ingest_folder.py
python /app/scripts/db_tools/healthcheck.py
```

See `python-toolbox/README.md` for environment variables and usage notes.

### Ports you may need to change

These services publish host ports for local access. Change the host side of the
mapping if the port is already in use.

- Reverse proxy: `80` for all web UIs via the gateway.
- Forgejo web UI: `https://forgejo.llmstack.lan/` through reverse proxy (container still listens on `3000`).
- Forgejo SSH: `2222` for git over SSH.
- Python API: `8000` for FastAPI triggers.
- Qdrant: `6333` for local debugging.
- Postgres: `5432` for local admin tools.
- Redis: `6379` for local debugging.

### Persistent data and reset behavior

Named volumes store service data across restarts. Removing a volume deletes that
service data. Bind mounts under `workspace/` are local folders and can be cleaned
by deleting their contents.

- Named volumes include `ollama_data`, `openwebui_data`, `qdrant_data`,
  `postgres_data`, `redis_data`, `flowise_data`, `openhands_data`, `prometheus_data`,
  `grafana_data`, and `forgejo_data`.
- `docker compose down` keeps named volumes.
- `docker compose down -v` removes named volumes, which wipes stored data.
- The `workspace/` folder is safe to clean when you want a fresh OpenHands workspace.
- Flowise PDF drop folder uses a local bind mount: `./data/pdfs` -> `/data/pdfs`.

If you run Ollama on bare metal, keep port `11434` available on the host and point
`OLLAMA_BASE_URL` to `http://localhost:11434` in `.env`. The Ollama container does not
publish a host port by default. If you need to expose the container port, add a ports
mapping in `compose/ollama/docker-compose.yml`.

## Local Git

This stack includes a Forgejo service for local git hosting. Forgejo is a
lightweight, self-contained server that works well in homelab and air-gapped setups.

- Web UI: https://forgejo.llmstack.lan/
- SSH: port 2222

If these ports are in use, update the port mappings in
`compose/forgejo/docker-compose.yml`.

`./bin/llm-up` starts Forgejo with the rest of the stack. To start only Forgejo:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/forgejo/docker-compose.yml \
  up -d forgejo
```

See `docs/git-local.md` for setup and backup details.

## OpenHands Workspace

The workspace container provides a safe play area for OpenHands and CLI tools. It
mounts `./workspace` to `/workspace` and runs as a non-root user.

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

Flowise auto-ingest uses a separate host bind mount path:

- Host (macOS repo): `./data/pdfs`
- Container path: `/data/pdfs`

These folders are gitignored. Create them when needed:

```bash
mkdir -p workspace/ingest workspace/processed workspace/indexed
```

Create the Flowise PDF drop-in folder:

```bash
mkdir -p data/pdfs
```

## Common tasks

Live logs for real debugging:

```bash
SINCE=2h ./bin/llm-logs reverse-proxy auth open-webui flowise
```

Incident bundle (snapshot everything useful):

```bash
./bin/llm-debug-bundle
```

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
  run --rm python-toolbox python /app/scripts/db_tools/healthcheck.py
```

Start only Flowise:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/flowise/docker-compose.yml \
  up -d
```

Configure Flowise auto-ingest watcher in `.env.mac`:

```env
FLOWISE_URL=http://flowise:3000
FLOWISE_INGEST_CHATFLOW_ID=<your_ingestion_chatflow_id>
FLOWISE_INGEST_STOP_NODE_ID=qdrant_0
```

When configured, PDFs dropped into `./data/pdfs` are picked up automatically,
sent to Flowise vector upsert, and logged to stdout by `pdf-auto-ingest`.

If Flowise opens a blank screen after updates, hard refresh (`Ctrl+F5`) or open
Flowise in an incognito window once to clear stale frontend state.

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

Regenerate landing-page README mirrors:

```bash
powershell -ExecutionPolicy Bypass -File scripts/generate-landing-readmes.ps1
```

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
