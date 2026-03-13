# Install Ollama And Models (Mac Mini + External NVMe)

Use this prompt when you need an AI agent to reinstall Ollama on macOS and restore the same model set stored on external NVMe at `LLM_DATA`.

## Role
You are a security-conscious infrastructure automation agent working on a Docker-based macOS homelab.

## Goal
1. Install and configure Ollama on macOS (Apple Silicon).
2. Set Ollama model storage to external NVMe at `/Volumes/LLM_DATA/ollama/models`.
3. Start Ollama as a persistent service on login/startup.
4. Install (or verify installed) the full approved model set listed below.
5. Produce a final verification report.

## Safety Constraints
- Do not disable host security tools (LuLu, Santa, osquery).
- Do not expose Docker socket to AI agents.
- Do not run AI-generated code directly on the host.
- Do not delete existing model blobs unless explicitly asked.

## Environment
- Host: macOS on Apple Silicon.
- Project root: `~/llmstackmac`.
- External NVMe mount: `/Volumes/LLM_DATA`.
- Ollama models path target: `/Volumes/LLM_DATA/ollama/models`.

## Execution Plan

### 1. Preflight checks
Run:

```bash
set -euo pipefail

uname -a
sw_vers

ls -ld /Volumes/LLM_DATA /Volumes/LLM_DATA/ollama /Volumes/LLM_DATA/ollama/models
mkdir -p /Volumes/LLM_DATA/ollama/models

# Basic write check
TMP_FILE="/Volumes/LLM_DATA/ollama/models/.write-test-$$"
touch "$TMP_FILE"
rm -f "$TMP_FILE"
```

### 2. Install/update Homebrew and Ollama
Run:

```bash
# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew install ollama || brew upgrade ollama
```

### 3. Configure Ollama to use external NVMe models path
Run:

```bash
# Find installed Ollama formula (supports versioned formula names too)
OLLAMA_FORMULA="$(brew list --formula | grep -E '^ollama(@[0-9.]+)?$' | head -n1)"
if [[ -z "$OLLAMA_FORMULA" ]]; then
  echo "No Ollama Homebrew formula found after install." >&2
  exit 1
fi

echo "Using formula: $OLLAMA_FORMULA"

# Configure persistent env var used by brew service
launchctl setenv OLLAMA_MODELS /Volumes/LLM_DATA/ollama/models

# Start/restart service
brew services restart "$OLLAMA_FORMULA"

# Wait for API
for i in {1..30}; do
  if curl -fsS http://127.0.0.1:11434/api/version >/dev/null; then
    break
  fi
  sleep 2
done

curl -fsS http://127.0.0.1:11434/api/version
```

### 4. Restore model set
First, capture the source-of-truth model list from manifests (dynamic):

```bash
find /Volumes/LLM_DATA/ollama/models/manifests/registry.ollama.ai/library -type f \
  | sed 's#^/Volumes/LLM_DATA/ollama/models/manifests/registry.ollama.ai/library/##' \
  | awk -F/ 'NF==2 {print $1":"$2}' \
  | sort -u
```

Then ensure all required models are present:

```bash
models=(
  "codellama:13b-instruct"
  "codellama:34b-instruct"
  "codellama:70b-instruct"
  "codestral:22b"
  "deepseek-coder:1.3b-instruct"
  "deepseek-coder:33b-instruct"
  "deepseek-coder:6.7b-instruct"
  "deepseek-r1:1.5b"
  "deepseek-r1:14b"
  "deepseek-r1:32b"
  "deepseek-r1:7b"
  "deepseek-r1:8b"
  "dolphin-llama3:8b"
  "dolphin-mistral:7b"
  "dolphin-mixtral:latest"
  "gemma:2b-instruct"
  "gemma:7b-instruct"
  "llama3:70b"
  "llama3:8b"
  "llava:latest"
  "mistral:7b-instruct"
  "mixtral:8x7b"
  "neural-chat:7b"
  "nous-hermes2:latest"
  "openchat:7b"
  "phi3:latest"
  "qwen2.5-coder:14b-instruct"
  "qwen2.5-coder:32b-instruct"
  "qwen2.5-coder:7b-instruct"
  "qwen2.5:0.5b"
  "qwen2.5:0.5b-instruct"
  "qwen2.5:1.5b-instruct"
  "qwen2.5:14b-instruct"
  "qwen2.5:32b-instruct"
  "qwen2.5:3b-instruct"
  "qwen2.5:7b-instruct"
  "starcoder2:latest"
  "vicuna:13b"
  "wizardcoder:latest"
  "yi:34b-chat"
  "yi:6b-chat"
  "zephyr:7b-beta"
)

for m in "${models[@]}"; do
  echo "Ensuring model: $m"
  ollama pull "$m"
done
```

### 5. Verification and reporting
Run:

```bash
echo "--- Ollama version ---"
ollama --version

echo "--- Service status ---"
brew services list | grep -E 'Name|ollama'

echo "--- API health ---"
curl -fsS http://127.0.0.1:11434/api/version

echo "--- Installed models ---"
ollama list

echo "--- Models directory usage ---"
du -sh /Volumes/LLM_DATA/ollama/models
```

Report:
- Whether Ollama is installed and running.
- Whether `OLLAMA_MODELS` points to `/Volumes/LLM_DATA/ollama/models`.
- Which models were newly downloaded vs already present.
- Any failed pulls.

## Notes
- Keep all operations idempotent: safe to rerun.
- If a model pull fails, continue to next model and summarize failures at end.
- Do not remove existing models unless explicitly instructed.
