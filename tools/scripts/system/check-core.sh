#!/usr/bin/env bash
set -euo pipefail

checks=(
  "https://llmstack.lan/"
  "https://openwebui.llmstack.lan/"
  "https://flowise.llmstack.lan/"
  "https://grafana.llmstack.lan/"
  "https://prometheus.llmstack.lan/"
  "https://pgadmin.llmstack.lan/"
  "https://qdrant.llmstack.lan/dashboard"
  "https://redisinsight.llmstack.lan/"
  "https://nodered.llmstack.lan/"
  "https://forgejo.llmstack.lan/"
)

for url in "${checks[@]}"; do
  if [[ "$url" == https://* ]]; then
    code=$(curl -k -s -o /dev/null -w "%{http_code}" "$url" || true)
  else
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || true)
  fi
  printf "%-45s %s\n" "$url" "$code"
done
