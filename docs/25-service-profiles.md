# Service Layers

This repo no longer uses a single compose file with runtime profiles as the main operator model. It uses separate compose projects.

## Default daily-use path

`llm up core` starts:

- `llm-data`
- `llm-core`

That gives you:

- Postgres
- Redis
- Qdrant
- Authelia
- landing page
- reverse proxy
- Open WebUI
- Flowise
- `ollama-gateway`

## Optional layers

`llm up observability`:

- Prometheus
- Grafana
- postgres-exporter
- blackbox-exporter

`llm up observability-host`:

- node-exporter
- cadvisor

`llm up admin`:

- DefectDojo
- Forgejo
- pgAdmin
- RedisInsight

`llm up lab`:

- python-toolbox
- Node-RED
- console
- OpenClaw
- OpenHands
- rag-pipeline
- pdf-ingest
- ocr

The lab script does not start every lab service by default. `pdf-auto-ingest`, `stt`, and `tts` are available but not in the default `up lab` service list.

## Network trust

- `llm-shared`: normal cross-service traffic
- `llm-ollama-access`: restricted network for intended Ollama clients

Current intended Ollama clients:

- `open-webui`
- `flowise`
- `python-toolbox`
- `rag-pipeline`

Native Ollama is reached only through `ollama-gateway`.
