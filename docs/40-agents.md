# Agents

## Flowise

Flowise provides a visual agent builder. It is configured to talk to Ollama on the internal Docker network.

Access it through the reverse proxy at:

- `http://localhost/flowise/`

You can optionally set `FLOWISE_USERNAME` and `FLOWISE_PASSWORD` in `.env` to enable basic auth.

## OpenHands

OpenHands provides an agentic coding workspace. It is only reachable through the reverse proxy by default.

Access it at:

- `http://localhost/openhands/`
