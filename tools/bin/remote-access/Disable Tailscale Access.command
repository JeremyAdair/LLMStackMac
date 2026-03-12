#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./disable
echo
read -r -p "Press Enter to close..."
