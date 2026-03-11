# Node-RED

Node-RED is optional lab automation. It is not part of the default core stack.

## Start it

```bash
./tools/bin/cli-handler/llm up lab node-red
```

## URL

- `https://nodered.llmstack.lan/`

It is fronted by the reverse proxy and protected by Authelia.

## Persistent state

- `nodered_data`

## Useful internal endpoints

- `http://python-toolbox:8000`
- `http://flowise:3000`
- `http://qdrant:6333`

Node-RED should not talk directly to `host.docker.internal:11434`. If it needs models, use the internal `ollama-gateway` path and add it intentionally to the Ollama access network first.
