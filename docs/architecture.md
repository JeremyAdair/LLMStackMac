# Architecture

## Compose projects

- `llm-data`
- `llm-core`
- `llm-observability`
- `llm-observability-host`
- `llm-admin`
- `llm-lab`

Each project has its own top-level compose file under `compose/`.

## Networks

`llm-shared`

- external shared network across all layers
- standard cross-service DNS

`llm-ollama-access`

- external restricted network
- intended only for services that need Ollama inference
- created as `--internal` by the stack helper when newly created

## Ollama boundary

Current design:

- Ollama runs natively on the Mac
- containers never use `host.docker.internal:11434` directly
- containers use `http://ollama-gateway:11434`
- `ollama-gateway` is the only stack service that knows `OLLAMA_UPSTREAM_URL`

This keeps the trust boundary cleaner without containerizing Ollama on Apple Silicon.

## Web ingress

Nginx is the single host ingress.

- `80` and `443` are published
- they bind to loopback by default
- TLS is terminated at Nginx
- Authelia handles the browser-facing auth flow

## Higher-trust exceptions

These are intentionally not in the default startup:

- `cadvisor`
- `node-exporter`
- any OpenHands runtime override that mounts `docker.sock`

That split exists to keep the default stack lower trust.
