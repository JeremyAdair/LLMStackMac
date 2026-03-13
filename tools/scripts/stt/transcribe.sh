#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: llm stt transcribe <filename.wav>" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
input_name="$1"
input_path="${repo_root}/data/audio/ingest_dropzone/${input_name}"
base_name="${input_name%.*}"
processed_root="${repo_root}/data/audio/processed"
rawtext_base="${processed_root}/rawtext/${base_name}"
original_path="${processed_root}/original/${input_name}"
json_path="${processed_root}/json/${base_name}.json"
chunk_path="${processed_root}/chunk/${base_name}.txt"
failed_path="${repo_root}/data/audio/failed/${input_name}"

if [[ ! -f "$input_path" ]]; then
  echo "Input file not found: $input_path" >&2
  exit 1
fi

mkdir -p "${repo_root}/data/audio/failed"
mkdir -p "${repo_root}/data/audio/ingest_dropzone"
mkdir -p "${processed_root}/rawtext" "${processed_root}/original" "${processed_root}/json" "${processed_root}/chunk"

env_file="${repo_root}/.env.mac"
if [[ ! -f "${env_file}" && -f "${repo_root}/.env" ]]; then
  env_file="${repo_root}/.env"
fi

if docker compose --env-file "${env_file}" -p llm-lab -f "${repo_root}/compose/lab.yml" run --rm stt \
  ./main -m "${STT_MODEL_PATH:-/models/ggml-base.en.bin}" \
  -f "/data/audio/ingest_dropzone/${input_name}" \
  -otxt -of "/data/audio/processed/rawtext/${base_name}"; then
  mv -f "$input_path" "$original_path"
  printf '{\n  "source": "%s",\n  "transcript": "%s.txt"\n}\n' "$input_name" "${base_name}" > "$json_path"
  if [[ -f "${rawtext_base}.txt" ]]; then
    cp -f "${rawtext_base}.txt" "$chunk_path"
  fi
else
  mv -f "$input_path" "$failed_path"
  echo "Transcription failed. Moved input to ${failed_path}" >&2
  exit 1
fi

if [[ -f "${rawtext_base}.txt" ]]; then
  echo "Transcript written to ${rawtext_base}.txt"
fi
