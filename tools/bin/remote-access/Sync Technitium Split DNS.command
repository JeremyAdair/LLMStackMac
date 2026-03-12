#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./split-dns-sync
echo
read -r -p "Press Enter to close..."
