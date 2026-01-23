# Node-RED

Node-RED is the automation and integration engine for this stack. It orchestrates events and workflows but does not replace reasoning agents.

## What it is used for

- Orchestrate "when X happens, do Y" workflows.
- Glue services together (OCR → RAG → notify).
- Integrate external systems (Discord, webhooks, cron).
- Trigger Python jobs, Flowise workflows, and OpenHands tasks.

## What it is not

- Not a reasoning agent.
- Not a replacement for Flowise or OpenHands.

## Access

Node-RED is available through the reverse proxy at:

- http://localhost/nodered/

It is protected by the authentication gateway.

## Data location

Node-RED stores flows and context under:

- `data/node-red/`

This directory is gitignored to avoid committing flows or credentials.

If you build file-watching automations, use the shared workspace directories under `workspace/`.

## Example flow ideas

- File arrives → OCR → RAG → Discord notification.
- Scheduled RAG refresh → status update.
- Agent failure → alert.

## How Node-RED talks to services

Node-RED can call internal services by service name on the Docker network:

- Ollama: `http://ollama:11434`
- Python job runner: run a container via `docker compose run` (see below)
- Flowise: `http://flowise:3000`
- OpenHands: `http://openhands:3000`

## Trigger a Python job from Node-RED

Use an "exec" node to run:

```bash
docker compose -f compose/docker-compose.yml -f compose/python-runner/docker-compose.yml run --rm python-runner python /scripts/rag_pipeline/ingest.py
```

## Secrets and credentials

Do not hardcode credentials into flows. Use environment variables or external secret stores and reference them in nodes.
