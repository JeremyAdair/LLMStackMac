from __future__ import annotations

import json
import os
import threading
import time
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import fitz
import requests
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, PointStruct, VectorParams


def _bool_env(name: str, default: bool) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _slug_name(filename: str) -> str:
    cleaned = Path(filename).name
    return cleaned.replace("/", "_").replace("\\", "_")


def unique_path(directory: Path, filename: str) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    candidate = directory / _slug_name(filename)
    if not candidate.exists():
        return candidate
    stem = candidate.stem
    suffix = candidate.suffix
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    short = uuid.uuid4().hex[:6]
    return directory / f"{stem}_{timestamp}_{short}{suffix}"


def chunk_text(text: str, chunk_size: int, chunk_overlap: int) -> list[str]:
    words = text.split()
    chunks: list[str] = []
    if not words:
        return chunks
    start = 0
    while start < len(words):
        end = start + chunk_size
        chunk = " ".join(words[start:end]).strip()
        if chunk:
            chunks.append(chunk)
        start = max(end - chunk_overlap, start + 1)
    return chunks


@dataclass
class PdfIngestConfig:
    ingest_dir: Path = Path("/data/pdfs/ingest-dropzone")
    processed_dir: Path = Path("/data/pdfs/processed")
    failed_dir: Path = Path("/data/pdfs/failed")
    ollama_base_url: str = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
    qdrant_url: str = os.getenv("QDRANT_URL", "http://qdrant:6333")
    collection: str = os.getenv("RAG_COLLECTION", "documents")
    embed_model: str = os.getenv("RAG_EMBED_MODEL", "nomic-embed-text")
    chunk_size: int = int(os.getenv("RAG_CHUNK_SIZE", "400"))
    chunk_overlap: int = int(os.getenv("RAG_CHUNK_OVERLAP", "50"))
    watch_interval: float = float(os.getenv("PDF_INGEST_WATCH_INTERVAL", "3"))
    enabled: bool = _bool_env("PDF_INGEST_WATCHER_ENABLED", True)


class PdfIngestService:
    def __init__(self, cfg: PdfIngestConfig):
        self.cfg = cfg
        self._stop_event = threading.Event()
        self._thread: threading.Thread | None = None
        self._lock = threading.Lock()
        self._active = False
        self._last_error: str | None = None
        self._processed_count = 0
        self._failed_count = 0

        self.processed_original = self.cfg.processed_dir / "original"
        self.processed_rawtext = self.cfg.processed_dir / "rawtext"
        self.processed_json = self.cfg.processed_dir / "json"
        self.processed_chunk = self.cfg.processed_dir / "chunk"

        for directory in [
            self.cfg.ingest_dir,
            self.cfg.failed_dir,
            self.processed_original,
            self.processed_rawtext,
            self.processed_json,
            self.processed_chunk,
        ]:
            directory.mkdir(parents=True, exist_ok=True)

    def status(self) -> dict[str, Any]:
        with self._lock:
            return {
                "enabled": self.cfg.enabled,
                "active": self._active,
                "last_error": self._last_error,
                "processed_count": self._processed_count,
                "failed_count": self._failed_count,
                "ingest_dir": str(self.cfg.ingest_dir),
                "processed_dir": str(self.cfg.processed_dir),
                "failed_dir": str(self.cfg.failed_dir),
            }

    def start(self) -> None:
        if not self.cfg.enabled:
            return
        if self._thread and self._thread.is_alive():
            return
        self._stop_event.clear()
        self._thread = threading.Thread(target=self._watch_loop, name="pdf-ingest-watcher", daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread:
            self._thread.join(timeout=5)

    def _watch_loop(self) -> None:
        with self._lock:
            self._active = True
            self._last_error = None
        try:
            while not self._stop_event.is_set():
                for path in sorted(self.cfg.ingest_dir.iterdir()):
                    if not path.is_file():
                        continue
                    if path.suffix.lower() != ".pdf":
                        continue
                    self._process_file(path)
                self._stop_event.wait(self.cfg.watch_interval)
        except Exception as exc:  # pragma: no cover
            with self._lock:
                self._last_error = str(exc)
        finally:
            with self._lock:
                self._active = False

    def _embed(self, text: str) -> list[float]:
        response = requests.post(
            f"{self.cfg.ollama_base_url}/api/embeddings",
            json={"model": self.cfg.embed_model, "prompt": text},
            timeout=60,
        )
        response.raise_for_status()
        return response.json()["embedding"]

    def _ensure_collection(self, client: QdrantClient, vector_size: int) -> None:
        try:
            client.get_collection(self.cfg.collection)
        except Exception:
            client.create_collection(
                collection_name=self.cfg.collection,
                vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE),
            )

    def _process_file(self, source_pdf: Path) -> None:
        chunk_files: list[Path] = []
        rawtext_path: Path | None = None
        json_path: Path | None = None
        original_target: Path | None = None
        try:
            text = self._extract_text(source_pdf)
            if not text.strip():
                raise ValueError("extracted text is empty")

            original_target = unique_path(self.processed_original, source_pdf.name)
            stem = original_target.stem

            rawtext_path = unique_path(self.processed_rawtext, f"{stem}.txt")
            rawtext_path.write_text(text, encoding="utf-8")

            chunks = chunk_text(text, self.cfg.chunk_size, self.cfg.chunk_overlap)
            if not chunks:
                raise ValueError("no chunks generated from extracted text")

            client = QdrantClient(url=self.cfg.qdrant_url)
            points: list[PointStruct] = []
            for idx, chunk in enumerate(chunks, start=1):
                vector = self._embed(chunk)
                self._ensure_collection(client, len(vector))
                chunk_path = unique_path(self.processed_chunk, f"{stem}-{idx:04d}.txt")
                chunk_path.write_text(chunk, encoding="utf-8")
                chunk_files.append(chunk_path)
                points.append(
                    PointStruct(
                        id=str(uuid.uuid4()),
                        vector=vector,
                        payload={
                            "source_file": original_target.name,
                            "chunk_file": chunk_path.name,
                            "chunk_index": idx,
                            "ingested_at": datetime.now(timezone.utc).isoformat(),
                        },
                    )
                )

            client.upsert(collection_name=self.cfg.collection, points=points)

            json_path = unique_path(self.processed_json, f"{stem}.json")
            json_path.write_text(
                json.dumps(
                    {
                        "source_file": source_pdf.name,
                        "stored_original": original_target.name,
                        "rawtext_file": rawtext_path.name,
                        "chunk_files": [p.name for p in chunk_files],
                        "qdrant_collection": self.cfg.collection,
                        "embedding_model": self.cfg.embed_model,
                        "chunk_count": len(chunk_files),
                        "status": "processed",
                    },
                    indent=2,
                ),
                encoding="utf-8",
            )

            source_pdf.rename(original_target)
            with self._lock:
                self._processed_count += 1
                self._last_error = None
        except Exception as exc:
            failed_target = unique_path(self.cfg.failed_dir, source_pdf.name)
            if source_pdf.exists():
                source_pdf.rename(failed_target)
            error_log = unique_path(self.cfg.failed_dir, f"{failed_target.stem}.error.log")
            error_log.write_text(str(exc), encoding="utf-8")
            with self._lock:
                self._failed_count += 1
                self._last_error = str(exc)

    @staticmethod
    def _extract_text(pdf_path: Path) -> str:
        with fitz.open(pdf_path) as doc:
            return "\n".join(page.get_text() for page in doc)


_SERVICE: PdfIngestService | None = None


def get_pdf_ingest_service() -> PdfIngestService:
    global _SERVICE
    if _SERVICE is None:
        _SERVICE = PdfIngestService(PdfIngestConfig())
    return _SERVICE
