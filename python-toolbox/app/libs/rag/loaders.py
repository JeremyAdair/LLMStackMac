from pathlib import Path

import fitz
from loguru import logger
from pdfminer.high_level import extract_text


def load_pdf_text(path: Path) -> str:
    try:
        doc = fitz.open(path)
        text_parts = []
        for page in doc:
            text_parts.append(page.get_text())
        return "\n".join(text_parts)
    except Exception as exc:
        logger.warning("PyMuPDF failed, falling back to pdfminer", error=str(exc))
        return extract_text(str(path))


def load_text_file(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")
