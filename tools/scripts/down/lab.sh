#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"

echo "[llmstack] Stopping lab layer (llm-lab)"
if [[ "$#" -gt 0 ]]; then
  compose_project llm-lab lab down "$@" || true
else
  compose_project llm-lab lab down || true
fi

echo "[llmstack] Lab mode down"
