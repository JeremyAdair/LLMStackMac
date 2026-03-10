#!/usr/bin/env bash

############################################
# SECTION: File Overview
#
# What this part of the program does:
# Implements an automation/helper script used by the LLMStack tooling layer.
# This script performs a focused operational task in a repeatable way.
#
# Why it exists:
# Automating this workflow reduces manual commands, avoids common mistakes,
# and keeps stack operations consistent for beginner users.
#
# What happens next:
# The script below parses context/inputs, runs the operational steps,
# and reports success or failure to the caller.
############################################

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
host_root="${LLMSTACK_HOST_ROOT:-/Volumes/LLM_DATA}"
log="${LOG_FILE:-${repo_root}/salvage-copy-$(date +%Y%m%d-%H%M%S).log}"

copy_one() {
  local vol="$1"
  local dst="$2"
  echo "=== $vol -> $dst ==="
  mkdir -p "$dst"
  local before after
  before=$(find "$dst" -type f 2>/dev/null | wc -l || true)
  docker run --rm -v "$vol:/src:ro" -v "$dst:/dst" alpine:3.20 sh -c "cp -an /src/. /dst/"
  after=$(find "$dst" -type f 2>/dev/null | wc -l || true)
  echo "files_before=$before files_after=$after added=$((after-before))"
}

{
  echo "Starting salvage copy $(date)"
  copy_one llm-stack_flowise_data "${host_root}/flowise/data"
  copy_one llm-stack_forgejo_data "${host_root}/forgejo/data"
  copy_one llm-stack_grafana_data "${host_root}/grafana/data"
  copy_one llm-stack_postgres_data "${host_root}/postgres/data"
  copy_one llm-stack_prometheus_data "${host_root}/prometheus/data"
  copy_one llm-stack_qdrant_data "${host_root}/qdrant/data"
  echo "Finished salvage copy $(date)"
} | tee "$log"

echo "$log"
