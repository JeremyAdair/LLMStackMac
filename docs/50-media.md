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
- `data/audio/in/` (place `.wav` files here)

Outputs:
- `data/audio/out/` (transcripts are written here)

Example:

```bash
mkdir -p data/audio/in data/audio/out
cp /path/to/sample.wav data/audio/in/
./bin/stt-transcribe sample.wav
```

Expected output:

- `data/audio/out/sample.txt`

Smoke test:

```bash
test -f data/audio/out/sample.txt
```

## TTS (Piper)

Purpose: Convert text into speech audio.

Inputs:
- `data/audio/tts_in.txt` (text input)

Outputs:
- `data/audio/out/tts_output.wav`

Example:

```bash
mkdir -p data/audio/out
./bin/tts-speak "hello world"
```

Smoke test:

```bash
test -f data/audio/out/tts_output.wav
```

## OCR (Tesseract)

Purpose: Extract text from images or scanned documents.

Inputs:
- `data/ocr/ingest-dropzone/` (place `.png`, `.jpg`, or `.pdf` images here)

Outputs:
- `data/ocr/processed/text/` (OCR text output)
- `data/ocr/processed/json/` (OCR metadata per file)
- `data/ocr/processed/chunk/` (line-chunked OCR text files)
- `data/ocr/failed/` (inputs copied here if OCR fails)

Example:

```bash
mkdir -p data/ocr/ingest-dropzone data/ocr/processed/text data/ocr/processed/json data/ocr/processed/chunk data/ocr/failed
cp /path/to/sample.png data/ocr/ingest-dropzone/
./bin/ocr-run sample.png
```

Expected output:

- `data/ocr/processed/text/sample.txt`
- `data/ocr/processed/json/sample.json`

Smoke test:

```bash
test -f data/ocr/processed/text/sample.txt
```

## Python toolbox jobs

Purpose: Run one-off scripts and pipelines inside a controlled container.

Example commands:

```bash
docker compose \
  run --rm python-toolbox python /app/scripts/db_tools/healthcheck.py

docker compose \
  run --rm python-toolbox python /app/scripts/rag_ingest/ingest_folder.py
```

Smoke test:

```bash
docker compose \
  run --rm python-toolbox python /app/scripts/db_tools/healthcheck.py
```
