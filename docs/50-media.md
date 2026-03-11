# Media Utilities

The media helpers live in `llm-lab` and are mostly job-style utilities.

## OCR

Run OCR with the lab service:

```bash
./tools/bin/cli-handler/llm up lab ocr
./tools/bin/cli-handler/llm ocr run <filename>
```

Input and output paths:

- input: `data/ocr/ingest-dropzone/`
- output text: `data/ocr/processed/rawtext/`
- output metadata: `data/ocr/processed/json/`
- failures: `data/ocr/failed/`

## STT

Speech-to-text uses `whisper.cpp`.

```bash
./tools/bin/cli-handler/llm stt transcribe <file.wav>
```

Assets live under:

- `data/stt/models/`

## TTS

Text-to-speech uses Piper.

```bash
./tools/bin/cli-handler/llm tts speak "hello world"
```

Assets live under:

- `data/tts/voices/`

## Ollama models

Host Ollama models are not stored in the repo. On this Mac they can be pointed at external storage with:

```bash
./tools/bin/cli-handler/llm ollama-models-path /Volumes/LLM_DATA/ollama/models
```

The repo may contain local-only symlinks for operator convenience, but those should stay ignored and uncommitted.
