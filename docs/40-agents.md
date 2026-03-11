# Agent Tooling

## Flowise

Flowise is the main graph-based agent/workflow tool in the stack.

- URL: `https://flowise.llmstack.lan/`
- backend model URL inside Docker: `http://ollama-gateway:11434`
- data volume: `flowise_data`
- PDF bind mount: `data/pdfs -> /data/pdfs`

Flowise is part of `llm-core`, not `llm-lab`.

## OpenHands

OpenHands is optional lab tooling for agentic coding.

- URL: `https://openhands.llmstack.lan/`
- layer: `llm-lab`
- persistent state: `openhands_data`
- workspace bind mount: `data/openhands-workspace`

The standalone OpenHands compose no longer mounts `docker.sock` by default. Use the override only if you intentionally want Docker access from OpenHands.

## OpenClaw

OpenClaw is optional experimental agent tooling.

- URL: `https://openclaw.llmstack.lan/`
- layer: `llm-lab`

## Console

The stack now includes an authenticated browser console:

- URL: `https://llmstack.lan/console/`
- backend: `ttyd`
- session model: persistent `tmux` session named `llmstack`

This console is behind Authelia and should be treated as high-trust access.
