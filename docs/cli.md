# CLI Reference

Primary wrapper:

- `./tools/bin/cli-handler/llm`

## Lifecycle

```bash
./tools/bin/cli-handler/llm up core
./tools/bin/cli-handler/llm up observability
./tools/bin/cli-handler/llm up observability-host
./tools/bin/cli-handler/llm up admin
./tools/bin/cli-handler/llm up lab [service...]
./tools/bin/cli-handler/llm up full
./tools/bin/cli-handler/llm down core
./tools/bin/cli-handler/llm down admin
./tools/bin/cli-handler/llm down lab
./tools/bin/cli-handler/llm down observability
./tools/bin/cli-handler/llm down observability-host
./tools/bin/cli-handler/llm down all
```

## Health and debug

```bash
./tools/bin/cli-handler/llm status
./tools/bin/cli-handler/llm doctor
./tools/bin/cli-handler/llm check-core
./tools/bin/cli-handler/llm debug-bundle
./tools/bin/cli-handler/llm self-test
./tools/bin/cli-handler/llm version
```

## Host Ollama helpers

```bash
./tools/bin/cli-handler/llm ollama-models-path /Volumes/LLM_DATA/ollama/models
./tools/bin/cli-handler/llm ollama-firewall-status
./tools/bin/cli-handler/llm ollama-firewall-enable
./tools/bin/cli-handler/llm ollama-firewall-disable
```

## Pipelines and media

```bash
./tools/bin/cli-handler/llm ingest pdf [args...]
./tools/bin/cli-handler/llm models pull
./tools/bin/cli-handler/llm ocr run <filename>
./tools/bin/cli-handler/llm stt transcribe <file.wav>
./tools/bin/cli-handler/llm tts speak "text"
```
