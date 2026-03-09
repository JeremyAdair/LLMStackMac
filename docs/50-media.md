# Speech and OCR Services

This document explains how to use the local STT (speech-to-text), TTS (text-to-speech), OCR, and the Python toolbox.

## Model storage and why it is gitignored

Models and voices are large binary files. They are stored under `data/` and gitignored to keep the repository small and avoid committing artifacts.

For Ollama, pull the project model set with `bin/llm-models-pull`. The model list is sourced from `prompts/system/install-ollama-and-models.md`.

## Pull Ollama models

```bash
./bin/llm-models-pull
```

Note: STT/TTS model assets are optional and are not bootstrapped by `llm-models-pull`.
If you enable STT/TTS later, initialize those assets as part of STT/TTS setup.

Ollama smoke test:

```bash
ollama list
```

## STT (Whisper)

Purpose: Convert audio files into text transcripts.

Inputs:
- `workspace/audio/in/` (place `.wav` files here)

Outputs:
- `workspace/audio/out/` (transcripts are written here)

Example:

```bash
mkdir -p workspace/audio/in workspace/audio/out
cp /path/to/sample.wav workspace/audio/in/
./bin/stt-transcribe sample.wav
```

Expected output:

- `workspace/audio/out/sample.txt`

Smoke test:

```bash
test -f workspace/audio/out/sample.txt
```

## TTS (Piper)

Purpose: Convert text into speech audio.

Inputs:
- `workspace/audio/tts_in.txt` (text input)

Outputs:
- `workspace/audio/out/tts_output.wav`

Example:

```bash
mkdir -p workspace/audio/out
./bin/tts-speak "hello world"
```

Smoke test:

```bash
test -f workspace/audio/out/tts_output.wav
```

## OCR (Tesseract)

Purpose: Extract text from images or scanned documents.

Inputs:
- `workspace/ocr/in/` (place `.png`, `.jpg`, or `.pdf` images here)

Outputs:
- `workspace/ocr/out/` (OCR text output)

Example:

```bash
mkdir -p workspace/ocr/in workspace/ocr/out
cp /path/to/sample.png workspace/ocr/in/
./bin/ocr-run sample.png
```

Expected output:

- `workspace/ocr/out/sample.txt`

Smoke test:

```bash
test -f workspace/ocr/out/sample.txt
```

## Python toolbox jobs

Purpose: Run one-off scripts and pipelines inside a controlled container.

Example commands:

```bash
docker compose \
  -f compose/docker-compose.yml \
  run --rm python-toolbox python /app/scripts/db_tools/healthcheck.py

docker compose \
  -f compose/docker-compose.yml \
  run --rm python-toolbox python /app/scripts/rag_ingest/ingest_folder.py
```

Smoke test:

```bash
docker compose \
  -f compose/docker-compose.yml \
  run --rm python-toolbox python /app/scripts/db_tools/healthcheck.py
```
