#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"

"${repo_root}/tools/scripts/up/core.sh"
"${repo_root}/tools/scripts/up/observability.sh"
"${repo_root}/tools/scripts/up/admin.sh"
"${repo_root}/tools/scripts/up/lab.sh"

echo "[llmstack] Full stack up (core + data + observability + admin + lab)"
