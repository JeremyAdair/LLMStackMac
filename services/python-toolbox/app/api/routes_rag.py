from fastapi import APIRouter

from libs.rag.ingest import run_ingest_once

router = APIRouter(prefix="/rag", tags=["rag"])


@router.post("/ingest_once")
def ingest_once() -> dict:
    return run_ingest_once()
