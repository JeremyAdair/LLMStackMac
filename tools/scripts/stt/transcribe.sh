#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: llm stt transcribe <filename.wav>" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
input_name="$1"
input_path="${repo_root}/data/audio/in/${input_name}"
output_base="${repo_root}/data/audio/out/${input_name%.*}"

if [[ ! -f "$input_path" ]]; then
  echo "Input file not found: $input_path" >&2
  exit 1
fi

mkdir -p "${repo_root}/data/audio/out"

env_file="${repo_root}/.env.mac"
if [[ ! -f "${env_file}" && -f "${repo_root}/.env" ]]; then
  env_file="${repo_root}/.env"
fi

docker compose --env-file "${env_file}" -p llm-lab -f "${repo_root}/compose/lab.yml" run --rm stt \
  ./main -m "${STT_MODEL_PATH:-/models/ggml-base.en.bin}" \
  -f "/data/audio/in/${input_name}" \
  -otxt -of "/data/audio/out/${input_name%.*}"

if [[ -f "${output_base}.txt" ]]; then
  echo "Transcript written to ${output_base}.txt"
fi
