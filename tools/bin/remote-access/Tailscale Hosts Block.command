#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
./hosts
echo
read -r -p "Press Enter to close..."
