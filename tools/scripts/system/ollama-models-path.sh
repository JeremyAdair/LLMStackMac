#!/usr/bin/env bash
set -euo pipefail

target_path="${1:-${OLLAMA_MODELS_PATH:-/Volumes/LLM_DATA/ollama/models}}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This command only supports macOS host Ollama." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required to manage the host Ollama service." >&2
  exit 1
fi

formula="$(brew list --formula 2>/dev/null | grep -E '^ollama(@[0-9.]+)?$' | head -n1 || true)"
if [[ -z "${formula}" ]]; then
  echo "No Homebrew Ollama formula is installed." >&2
  exit 1
fi

mkdir -p "${target_path}"

probe_file="${target_path}/.llmstack-write-test-$$"
touch "${probe_file}"
rm -f "${probe_file}"

echo "Configuring ${formula} to use OLLAMA_MODELS=${target_path}"
launchctl setenv OLLAMA_MODELS "${target_path}"
brew services restart "${formula}"

for _ in {1..30}; do
  if curl -fsS http://127.0.0.1:11434/api/version >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "launchctl OLLAMA_MODELS=$(launchctl getenv OLLAMA_MODELS || true)"
echo "ollama tags:"
curl -fsS http://127.0.0.1:11434/api/tags
