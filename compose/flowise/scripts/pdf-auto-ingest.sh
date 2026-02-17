#!/bin/sh
set -eu

FLOWISE_URL="${FLOWISE_URL:-http://flowise:3000}"
FLOWISE_INGEST_CHATFLOW_ID="${FLOWISE_INGEST_CHATFLOW_ID:-}"
FLOWISE_INGEST_STOP_NODE_ID="${FLOWISE_INGEST_STOP_NODE_ID:-qdrant_0}"
PDF_WATCH_DIR="${PDF_WATCH_DIR:-/data/pdfs}"

if [ -z "$FLOWISE_INGEST_CHATFLOW_ID" ]; then
  echo "pdf-auto-ingest: FLOWISE_INGEST_CHATFLOW_ID is empty; watcher will not start"
  exit 1
fi

apk add --no-cache inotify-tools curl >/dev/null
mkdir -p "$PDF_WATCH_DIR/processed" "$PDF_WATCH_DIR/failed"

INGEST_URL="$FLOWISE_URL/api/v1/vector/internal-upsert/$FLOWISE_INGEST_CHATFLOW_ID"

ingest_file() {
  file="$1"
  [ -f "$file" ] || return 0

  base="$(basename "$file")"
  case "$base" in
    *.pdf|*.PDF) ;;
    *) return 0 ;;
  esac

  # Small delay so copy operations complete before upload.
  sleep 1
  if [ ! -s "$file" ]; then
    echo "pdf-auto-ingest: skip empty file $base"
    return 0
  fi

  metadata="{\"filename\":\"$base\"}"
  echo "pdf-auto-ingest: ingesting $base -> $INGEST_URL"

  if curl -fsS -X POST "$INGEST_URL" \
      -F "files=@$file;type=application/pdf" \
      -F "stopNodeId=$FLOWISE_INGEST_STOP_NODE_ID" \
      -F "metadata=$metadata" >/dev/null; then
    echo "pdf-auto-ingest: success $base"
    mv "$file" "$PDF_WATCH_DIR/processed/$base"
  else
    echo "pdf-auto-ingest: failed $base"
    mv "$file" "$PDF_WATCH_DIR/failed/$base"
  fi
}

echo "pdf-auto-ingest: watching $PDF_WATCH_DIR for new PDFs"

# Ingest any existing PDFs first.
for f in "$PDF_WATCH_DIR"/*.pdf "$PDF_WATCH_DIR"/*.PDF; do
  [ -e "$f" ] || continue
  ingest_file "$f"
done

# Watch for new PDFs.
inotifywait -m -e close_write,create,moved_to --format '%w%f' "$PDF_WATCH_DIR" | while read -r path; do
  ingest_file "$path"
done
