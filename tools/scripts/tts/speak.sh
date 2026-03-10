#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: llm tts speak \"text to speak\"" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
text="$*"

mkdir -p "${repo_root}/data/audio"
mkdir -p "${repo_root}/data/audio/out"

echo "$text" > "${repo_root}/data/audio/tts_in.txt"

env_file="${repo_root}/.env.mac"
if [[ ! -f "${env_file}" && -f "${repo_root}/.env" ]]; then
  env_file="${repo_root}/.env"
fi

output_path="/data/audio/out/tts_output.wav"

cat "${repo_root}/data/audio/tts_in.txt" | \
  docker compose --env-file "${env_file}" -p llm-lab -f "${repo_root}/compose/lab.yml" run --rm -T tts \
  --model "${TTS_VOICE_MODEL:-/voices/en_US-amy-low.onnx}" \
  --output_file "$output_path"

echo "Audio written to ${repo_root}/data/audio/out/tts_output.wav"
