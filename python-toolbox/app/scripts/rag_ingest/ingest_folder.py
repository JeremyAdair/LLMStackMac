import hashlib
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import psycopg2
from loguru import logger
from qdrant_client.http import models

SCRIPT_DIR = Path(__file__).resolve().parent
APP_ROOT = SCRIPT_DIR.parent.parent
sys.path.append(str(APP_ROOT))

from libs.common.config import load_rag_config
from libs.common.logging import configure_logging
from libs.rag.embeddings import Embedder
from libs.rag.loaders import load_pdf_text, load_text_file
from libs.rag.qdrant import ensure_collection, get_client, upsert_points
from scripts.rag_ingest.chunkers import ChunkerConfig, chunk_text


def file_hash(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def ensure_tables(cursor) -> None:
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS rag_documents (
            content_hash TEXT PRIMARY KEY,
            source_path TEXT NOT NULL,
            updated_at TIMESTAMPTZ NOT NULL,
            metadata JSONB
        )
        """
    )


def upsert_metadata(cursor, content_hash: str, source_path: str, metadata: dict) -> None:
    cursor.execute(
        """
        INSERT INTO rag_documents (content_hash, source_path, updated_at, metadata)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (content_hash)
        DO UPDATE SET updated_at = EXCLUDED.updated_at, metadata = EXCLUDED.metadata
        """,
        (
            content_hash,
            source_path,
            datetime.now(timezone.utc),
            metadata,
        ),
    )


def ingest_once() -> dict:
    cfg = load_rag_config()
    ingest_path = Path(cfg.ingest_path)
    ingest_path.mkdir(parents=True, exist_ok=True)

    postgres_conn = None
    postgres_cursor = None
    if cfg.database_url:
        postgres_conn = psycopg2.connect(cfg.database_url)
        postgres_conn.autocommit = True
        postgres_cursor = postgres_conn.cursor()
        ensure_tables(postgres_cursor)

    client = get_client(cfg.qdrant_url)
    embedder = Embedder(cfg.embed_model)

    files = list(ingest_path.glob("**/*"))
    files = [path for path in files if path.is_file()]

    total_chunks = 0
    processed_files = 0
    skipped_files = 0

    for path in files:
        if path.suffix.lower() in {".pdf"}:
            text = load_pdf_text(path)
        else:
            text = load_text_file(path)

        content_hash = file_hash(path)
        collections = {c.name for c in client.get_collections().collections}
        if cfg.qdrant_collection in collections:
            existing = client.retrieve(
                collection_name=cfg.qdrant_collection,
                ids=[f\"{content_hash}:0\"],
            )
            if existing:
                skipped_files += 1
                continue
        if postgres_cursor:
            postgres_cursor.execute(
                "SELECT content_hash FROM rag_documents WHERE content_hash = %s",
                (content_hash,),
            )
            if postgres_cursor.fetchone():
                skipped_files += 1
                continue

        chunks = chunk_text(text, ChunkerConfig())
        if not chunks:
            skipped_files += 1
            continue

        vectors = embedder.embed(chunks)
        ensure_collection(client, cfg.qdrant_collection, len(vectors[0]))

        payload = {
            "source_path": str(path),
            "content_hash": content_hash,
        }
        points = []
        for idx, vector in enumerate(vectors):
            point_id = f"{content_hash}:{idx}"
            points.append(
                models.PointStruct(
                    id=point_id,
                    vector=vector,
                    payload={**payload, "chunk_index": idx, "text": chunks[idx]},
                )
            )

        upsert_points(client, cfg.qdrant_collection, points)
        total_chunks += len(points)
        processed_files += 1

        if postgres_cursor:
            upsert_metadata(
                postgres_cursor,
                content_hash,
                str(path),
                {"chunks": len(points)},
            )

    if postgres_cursor:
        postgres_cursor.close()
    if postgres_conn:
        postgres_conn.close()

    return {
        "processed_files": processed_files,
        "skipped_files": skipped_files,
        "total_chunks": total_chunks,
    }


def main() -> int:
    configure_logging()
    logger.info("Starting ingest loop")
    while True:
        result = ingest_once()
        logger.info("Ingest run complete", **result)
        time.sleep(float(os.getenv("INGEST_INTERVAL", "60")))


if __name__ == "__main__":
    raise SystemExit(main())
