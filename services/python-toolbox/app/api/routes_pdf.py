from fastapi import APIRouter, File, UploadFile
from fastapi.responses import HTMLResponse

router = APIRouter()

@router.get("/status")
def pdf_status() -> dict:
    return {"message": "PDF status"}

@router.post("/upload")
async def upload_pdfs(files: list[UploadFile] = File(...)) -> dict:
    return {"message": "Files uploaded successfully"}
