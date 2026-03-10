from __future__ import annotations

from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile

from libs.pdf_ingest_worker.service import get_pdf_ingest_service, unique_path

router = APIRouter(prefix="/pdf", tags=["pdf"])


@router.get("/status")
def pdf_status() -> dict:
    service = get_pdf_ingest_service()
    return service.status()


@router.post("/upload")
async def upload_pdfs(files: list[UploadFile] = File(...)) -> dict:
    if not files:
        raise HTTPException(status_code=400, detail="No files uploaded")

    service = get_pdf_ingest_service()
    saved: list[dict[str, str]] = []
    rejected: list[dict[str, str]] = []

    for file in files:
        filename = Path(file.filename or "").name
        if not filename or Path(filename).suffix.lower() != ".pdf":
            rejected.append({"name": filename or "<unnamed>", "reason": "Only .pdf files are accepted"})
            continue

        target = unique_path(service.cfg.ingest_dir, filename)
        content = await file.read()
        if not content:
            rejected.append({"name": filename, "reason": "Empty file"})
            continue

        target.write_bytes(content)
        saved.append({"original_name": filename, "stored_name": target.name})

    if not saved and rejected:
        raise HTTPException(status_code=400, detail={"saved": saved, "rejected": rejected})

    return {"ok": True, "saved": saved, "rejected": rejected}
