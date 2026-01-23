# Speech and OCR Services

This document explains how to use the local STT (speech-to-text), TTS (text-to-speech), OCR, and the Python job runner.

## Model storage and why it is gitignored

Models and voices are large binary files. They are stored under `data/` and gitignored to keep the repository small and avoid committing artifacts.

- STT models: `data/stt/models/`
- TTS voices: `data/tts/voices/`

The `bin/models-pull` script downloads the exact model and voice files listed in `models/models.yml`.

## Install models and voices

```bash
./bin/models-pull
```

Smoke test:

```bash
ls -1 data/stt/models data/tts/voices
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

## Python job runner

Purpose: Run one-off scripts and pipelines inside a controlled container.

Example commands:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/python-runner/docker-compose.yml \
  run --rm python-runner python /app/main.py

docker compose \
  -f compose/docker-compose.yml \
  -f compose/python-runner/docker-compose.yml \
  run --rm python-runner python /scripts/rag_pipeline/ingest.py
```

Smoke test:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/python-runner/docker-compose.yml \
  run --rm python-runner python /app/main.py
```
