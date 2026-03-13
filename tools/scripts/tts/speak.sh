#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: llm tts speak \"text to speak\"" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
text="$*"
ts="$(date +%Y%m%d_%H%M%S)"
base_name="tts_output_${ts}"

mkdir -p "${repo_root}/data/audio/failed"
mkdir -p "${repo_root}/data/audio/ingest_dropzone"
mkdir -p "${repo_root}/data/audio/processed/original"
mkdir -p "${repo_root}/data/audio/processed/rawtext"
mkdir -p "${repo_root}/data/audio/processed/json"
mkdir -p "${repo_root}/data/audio/processed/chunk"

echo "$text" > "${repo_root}/data/audio/processed/rawtext/${base_name}.txt"

env_file="${repo_root}/.env.mac"
if [[ ! -f "${env_file}" && -f "${repo_root}/.env" ]]; then
  env_file="${repo_root}/.env"
fi

output_path="/data/audio/processed/original/${base_name}.wav"

cat "${repo_root}/data/audio/processed/rawtext/${base_name}.txt" | \
  docker compose --env-file "${env_file}" -p llm-lab -f "${repo_root}/compose/lab.yml" run --rm -T tts \
  --model "${TTS_VOICE_MODEL:-/voices/en_US-amy-low.onnx}" \
  --output_file "$output_path"

printf '{\n  "text_file": "%s.txt",\n  "audio_file": "%s.wav"\n}\n' "${base_name}" "${base_name}" > "${repo_root}/data/audio/processed/json/${base_name}.json"
cp -f "${repo_root}/data/audio/processed/rawtext/${base_name}.txt" "${repo_root}/data/audio/processed/chunk/${base_name}.txt"

echo "Audio written to ${repo_root}/data/audio/processed/original/${base_name}.wav"
