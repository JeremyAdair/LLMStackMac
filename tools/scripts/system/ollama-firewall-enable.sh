#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "${script_dir}/../../.." && pwd)"

anchor_name="llmstack/ollama"
anchor_file="/etc/pf.anchors/llmstack_ollama"
pf_conf="/etc/pf.conf"
source_rules="${repo_root}/config/firewall/ollama-pf.conf"
tmp_pf="$(mktemp)"
cleanup() {
  rm -f "${tmp_pf}"
}
trap cleanup EXIT

if [[ ! -f "${source_rules}" ]]; then
  echo "Error: missing rules file ${source_rules}" >&2
  exit 1
fi

cp "${pf_conf}" "${tmp_pf}"

if ! grep -q 'anchor "llmstack/\*"' "${tmp_pf}"; then
  printf '\nanchor "llmstack/*"\n' >> "${tmp_pf}"
fi

if ! grep -q 'load anchor "llmstack/ollama" from "/etc/pf.anchors/llmstack_ollama"' "${tmp_pf}"; then
  printf 'load anchor "llmstack/ollama" from "/etc/pf.anchors/llmstack_ollama"\n' >> "${tmp_pf}"
fi

echo "[llmstack] Validating candidate pf.conf"
sudo pfctl -nf "${tmp_pf}"

echo "[llmstack] Installing Ollama anchor rules"
sudo install -m 600 "${source_rules}" "${anchor_file}"

echo "[llmstack] Updating pf.conf anchor wiring"
sudo cp "${tmp_pf}" "${pf_conf}"

echo "[llmstack] Validating active pf.conf"
sudo pfctl -nf "${pf_conf}"

echo "[llmstack] Loading anchor ${anchor_name}"
sudo pfctl -a "${anchor_name}" -f "${anchor_file}"

if ! sudo pfctl -s info >/dev/null 2>&1; then
  echo "[llmstack] Enabling pf"
  sudo pfctl -e
else
  # pfctl -e exits non-zero when already enabled; the info call above avoids that path.
  :
fi

echo "[llmstack] Ollama firewall enabled"
echo "Allowed: localhost -> 127.0.0.1:11434"
echo "Blocked: non-loopback TCP access to port 11434"
