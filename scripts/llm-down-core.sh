#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/llm-stack-lib.sh"

echo "[llmstack] Stopping core layer (llm-core)"
compose_project llm-core core down "$@"

echo "[llmstack] Stopping data layer (llm-data)"
compose_project llm-data data down "$@"

echo "[llmstack] Core mode down"
