#!/usr/bin/env bash
set -euo pipefail

log="/mnt/c/Users/jerem/LLMStack/salvage-copy-$(date +%Y%m%d-%H%M%S).log"

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
  copy_one llm-stack_flowise_data /mnt/c/llm-stack/flowise/data
  copy_one llm-stack_forgejo_data /mnt/c/llm-stack/forgejo/data
  copy_one llm-stack_grafana_data /mnt/c/llm-stack/grafana/data
  copy_one llm-stack_postgres_data /mnt/c/llm-stack/postgres/data
  copy_one llm-stack_prometheus_data /mnt/c/llm-stack/prometheus/data
  copy_one llm-stack_qdrant_data /mnt/c/llm-stack/qdrant/data
  echo "Finished salvage copy $(date)"
} | tee "$log"

echo "$log"

