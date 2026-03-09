#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

"${repo_root}/scripts/llm-up-core.sh"
"${repo_root}/scripts/llm-up-observability.sh"
"${repo_root}/scripts/llm-up-admin.sh"
"${repo_root}/scripts/llm-up-lab.sh"

echo "[llmstack] Full stack up (core + data + observability + admin + lab)"
