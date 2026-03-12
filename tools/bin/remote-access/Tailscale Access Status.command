#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./status
echo
read -r -p "Press Enter to close..."
