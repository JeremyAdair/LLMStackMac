#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"

echo "[llmstack] Stopping llm-observability-host"
compose_project llm-observability-host observability-host down "$@" || true

echo "[llmstack] Host observability mode down"
