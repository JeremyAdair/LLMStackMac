# Overview

LLMStackMac is a layered Docker Compose homelab stack for local AI workflows on macOS. The current design assumes:

- Docker Desktop runs the containerized services.
- Ollama runs natively on the Mac for best Apple Silicon performance.
- Containers reach native Ollama through an internal `ollama-gateway`.
- Browser-facing apps are reached through the Nginx reverse proxy and protected by Authelia where appropriate.

## Layers

- `llm-data`: Postgres, Redis, Qdrant
- `llm-core`: reverse proxy, landing page, Authelia, Open WebUI, Flowise, `ollama-gateway`
- `llm-observability`: Prometheus, Grafana, exporters
- `llm-observability-host`: optional host-mounted exporters with higher trust
- `llm-admin`: Forgejo, pgAdmin, RedisInsight
- `llm-lab`: console, Node-RED, OpenHands, OpenClaw, python-toolbox, RAG/media jobs

## Current traffic model

- Host ports `80`, `443`, and `2222` bind to `127.0.0.1` by default through `HOST_BIND_IP`.
- Internal container traffic uses `llm-shared`.
- Only intended Ollama clients join `llm-ollama-access`.
- Native Ollama remains a trusted internal backend. Authelia is not an auth gateway for the Ollama API.

## Main URLs

- `https://llmstack.lan/`
- `https://openwebui.llmstack.lan/`
- `https://flowise.llmstack.lan/`
- `https://forgejo.llmstack.lan/`
- `https://grafana.llmstack.lan/grafana/`
- `https://llmstack.lan/console/`

## Read next

- [Install](10-install.md)
- [Operations](20-operations.md)
- [Architecture](architecture.md)
- [Service Map](service-map.md)
