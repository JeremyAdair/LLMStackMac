from __future__ import annotations

from pathlib import Path

from loguru import logger

from libs.common.config import load_rag_config
from scripts.rag_ingest.ingest_folder import ingest_once


def run_ingest_once() -> dict:
    cfg = load_rag_config()
    ingest_path = Path(cfg.ingest_path)
    if not ingest_path.exists():
        logger.warning("Ingest path does not exist, creating", path=str(ingest_path))
        ingest_path.mkdir(parents=True, exist_ok=True)
    return ingest_once()
