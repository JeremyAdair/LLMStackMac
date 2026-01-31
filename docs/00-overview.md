# Overview

LLMStack is a local, self-hosted, modular lab stack for experimenting with large language model workflows on your own hardware. It is designed for homelab builders and engineers who want to understand the system end-to-end and control each component.

## What this project is NOT

- It is not a hosted SaaS.
- It is not cloud-first.
- It is not a turnkey product with one-click setup.

## Core components

- Ollama: runs local LLM inference.
- Open WebUI: the main chat interface.
- Flowise: a graph-based workflow builder for LLM chains.
- Node-RED: automation and integration for triggers and orchestration.
- Python jobs: on-demand scripts for ingestion and maintenance.
- Qdrant / Postgres / Redis: storage for vectors, metadata, and caching.
- Reverse proxy + auth: the single entry point and access control.
- Monitoring: Prometheus and Grafana for visibility.

## Mental model

- The reverse proxy and auth gateway decide who can access the web UIs.
- Node-RED decides when things happen (schedules, webhooks, file events).
- Flowise and Ollama decide how things think (prompting and inference).
- Qdrant and Postgres store memory (vectors and metadata).
- Python jobs handle batch work (ingest, cleanup, evaluation).

## Example workflows

- Chat locally: open the chat UI and talk to a local model without any external calls.
- Drop a document and search it later: ingest files into the vector store and query them when needed.
- Transcribe audio and summarize it: run STT, optionally run a summary workflow, and save outputs.
- Automate a task and get notified: trigger a flow, run a job, and send a notification through Node-RED.

## Who this repo is for

Good fits:
- Homelab builders who want a local AI stack.
- Engineers who want modular components they can rewire.
- Learners who want to understand how the pieces fit together.

Bad fits:
- If you want a hosted AI app, this is not for you.
- If you want a one-click installer, this is not for you.
- If you do not want to operate Docker services, this is not for you.

## How to get started

- Installation: `docs/10-install.md`
- Operations: `docs/20-operations.md`
- Architecture and workflows: `docs/30-rag.md`, `docs/40-agents.md`, `docs/70-nodered.md`

## Landing page

The landing page is served by the stack and provides links to the protected web UIs. It is available at the hostname defined in `LANDING_HOSTNAME`, for example `http://llmstack.lan/`.
