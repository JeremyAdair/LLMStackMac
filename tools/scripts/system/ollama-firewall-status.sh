#!/usr/bin/env bash
set -euo pipefail

anchor_name="llmstack/ollama"
anchor_file="/etc/pf.anchors/llmstack_ollama"

echo "== Ollama Firewall =="

if sudo pfctl -s info >/dev/null 2>&1; then
  echo "pf: enabled"
else
  echo "pf: disabled"
fi

if [[ -f "${anchor_file}" ]]; then
  echo "anchor file: ${anchor_file}"
else
  echo "anchor file: missing"
fi

echo
echo "Anchor rules:"
sudo pfctl -a "${anchor_name}" -s rules 2>/dev/null || echo "(anchor not loaded)"
