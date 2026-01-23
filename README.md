# LLMStack

LLMStack is a self-hosted local LLM stack built around Docker Compose. It provides a modular setup for running models, a web UI, vector search, RAG ingestion, and optional agent tooling.

# Future Hopes
## Normal chat (no RAG)
```
[Browser]
(trigger: user types message)
        ↓
[Reverse Proxy + Auth Gateway]
(always-on)
        ↓
[Open WebUI]
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
## Ask questions over your docs (RAG query-time)
```
[Browser]
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
## Drop a PDF, automatically OCR it, index it, then it’s searchable (RAG ingestion)
```
[You drop PDF]
into workspace/ingest/
      |
      v
[Node-RED]  (automation: detects file)
      |
      | trigger OCR
      v
[OCR Service] -----------------------> workspace/processed/
      |
      | trigger indexing job
      v
[Python RAG Job]  (chunk + embed + upsert)
      |             |
      | embed        | upsert
      v             v
   [Ollama] ------> [Qdrant]
      |
      | optional metadata
      v
   [Postgres]  (doc index status, logs, etc.)
```   
## Voice note → transcript → (optional) answer → spoken reply
```
[Audio file]
workspace/audio/in/
      |
      v
[Node-RED]  (trigger + routing)
      |
      | STT
      v
[STT Service (Whisper)] --------> workspace/audio/out/transcript.txt
      |
      | optional "think about it"
      v
[Flowise] -----> [Qdrant] (optional retrieve)
   |
   v
[Ollama]  (LLM generates response)
      |
      | TTS
      v
[TTS Service] -----------------> workspace/audio/out/reply.wav
```
## “If something breaks, tell me” (alerts + dashboards)
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
## OpenHands for repo work (guarded, not exposed)
```
[Browser]
   |
   v
[Reverse Proxy] ---> [Auth Gateway]
   |
   v
[OpenHands UI]
   |
   v
[Workspace mount / repo files]
   |
   | (optional calls)
   v
[Ollama]  (local model)  and/or  [Flowise API] (agent logic)
```

## Audio file drop pipeline
```
┌───────────────────────────┐
│ 1) LOAD AUDIO              │
│ You drop file into:        │
│ workspace/audio/in/        │
│ ex: meeting.wav            │
└───────────────┬───────────┘
                │ (file created event)
                v
┌───────────────────────────┐
│ 2) NODE-RED (ORCHESTRATE)  │
│ - detects new audio file   │
│ - creates job id           │
│ - routes file path         │
└───────────────┬───────────┘
                │ (call STT)
                v
┌───────────────────────────┐
│ 3) STT SERVICE (WHISPER)   │
│ Input: meeting.wav         │
│ Output: transcript.txt     │
│ Writes to:                 │
│ workspace/audio/out/       │
└───────────────┬───────────┘
                │ (transcript ready)
                v
┌───────────────────────────┐
│ 4) SUMMARIZE (FLOWISE)     │
│ Flowise receives transcript│
│ - optional: RAG lookup     │
│ - calls Ollama to summarize│
└───────────────┬───────────┘
                │ (LLM call)
                v
┌───────────────────────────┐
│ 5) OLLAMA (LLM)            │
│ Generates: summary, topics,│
│ action items, etc.         │
└───────────────┬───────────┘
                │ (summary JSON)
                v
┌───────────────────────────┐
│ 6) STORE                   │
│ Postgres:                  │
│ - job id, filename         │
│ - transcript, summary      │
│ Qdrant (optional):         │
│ - embeddings of transcript │
│ - embeddings of summary    │
└───────────────┬───────────┘
                │
                v
┌───────────────────────────┐
│ 7) OUTPUT ARTIFACTS        │
│ workspace/audio/out/       │
│ - meeting.transcript.txt   │
│ - meeting.summary.md       │
│ - meeting.summary.json     │
└───────────────────────────┘
```
## Audio File API Pipeline
```
┌───────────────────────────┐
│ 1) LOAD AUDIO              │
│ Browser upload / API post  │
└───────────────┬───────────┘
                │
                v
┌───────────────────────────┐
│ Reverse Proxy + Auth       │
│ (protects upload endpoint) │
└───────────────┬───────────┘
                │
                v
┌───────────────────────────┐
│ Node-RED Webhook Endpoint  │
│ - receives upload          │
│ - saves to workspace/audio │
│ - creates job id           │
└───────────────┬───────────┘
                │
                v
┌───────────────────────────┐
│ STT (Whisper)              │
│ -> transcript              │
└───────────────┬───────────┘
                │
                v
┌───────────────────────────┐
│ Flowise + Ollama           │
│ -> summary + structure     │
└───────────────┬───────────┘
                │
                v
┌───────────────────────────┐
│ Store (Postgres/Qdrant)    │
│ + return status to browser │
└───────────────────────────┘
```
### Output Schema
```
{
  "title": "Meeting summary",
  "summary": "...",
  "topics": ["...","..."],
  "action_items": [
    {"owner":"", "task":"", "due_date":""}
  ],
  "key_quotes": ["..."],
  "tags": ["work", "controls", "project-x"]
}
```
## Scheduled RAG quality evaluation
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
## Knowledge distillation (compress old data)
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
## Log ingestion → anomaly explanation
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

You will be prompted to log in via the authentication gateway.

## Access and ports

All web access goes through the reverse proxy on port 80. Use the URLs above to configure each service after logging in. Internal services and databases are not exposed on host ports by default.

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
- `docs/60-auth.md`
- `docs/runbooks/bringup.md`
