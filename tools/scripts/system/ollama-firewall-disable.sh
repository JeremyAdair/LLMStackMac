#!/usr/bin/env bash
set -euo pipefail

anchor_name="llmstack/ollama"
anchor_file="/etc/pf.anchors/llmstack_ollama"
pf_conf="/etc/pf.conf"
tmp_pf="$(mktemp)"
cleanup() {
  rm -f "${tmp_pf}"
}
trap cleanup EXIT

cp "${pf_conf}" "${tmp_pf}"

python3 - <<'PY' "${tmp_pf}"
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text().splitlines()
filtered = [
    line for line in lines
    if line.strip() not in {
        'anchor "llmstack/*"',
        'load anchor "llmstack/ollama" from "/etc/pf.anchors/llmstack_ollama"',
    }
]
path.write_text("\n".join(filtered) + "\n")
PY

echo "[llmstack] Validating candidate pf.conf"
sudo pfctl -nf "${tmp_pf}"

echo "[llmstack] Flushing anchor ${anchor_name}"
sudo pfctl -a "${anchor_name}" -F all || true

echo "[llmstack] Restoring pf.conf without Ollama anchor wiring"
sudo cp "${tmp_pf}" "${pf_conf}"
sudo pfctl -nf "${pf_conf}"
sudo pfctl -f "${pf_conf}"

if [[ -f "${anchor_file}" ]]; then
  echo "[llmstack] Removing ${anchor_file}"
  sudo rm -f "${anchor_file}"
fi

echo "[llmstack] Ollama firewall disabled"
