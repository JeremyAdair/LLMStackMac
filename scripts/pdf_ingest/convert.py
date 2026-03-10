import json
import os
import shutil
from pathlib import Path

import fitz


def write_chunks(text: str, chunk_dir: Path, stem: str, lines_per_chunk: int = 120) -> int:
    lines = text.splitlines()
    if not lines:
        lines = [""]
    count = 0
    for i in range(0, len(lines), lines_per_chunk):
        count += 1
        chunk_path = chunk_dir / f"{stem}-{count:04d}.md"
        chunk_path.write_text("\n".join(lines[i : i + lines_per_chunk]), encoding="utf-8")
    return count


def main():
    input_dir = Path(os.getenv("INGEST_INPUT_DIR", "/data/pdfs/ingest-dropzone"))
    output_dir = Path(os.getenv("INGEST_OUTPUT_DIR", "/data/pdfs/processed"))
    failed_dir = Path(os.getenv("INGEST_FAILED_DIR", "/data/pdfs/failed"))

    original_dir = output_dir / "original"
    rawtext_dir = output_dir / "rawtext"
    json_dir = output_dir / "json"
    chunk_dir = output_dir / "chunk"

    for directory in [original_dir, rawtext_dir, json_dir, chunk_dir, failed_dir]:
        directory.mkdir(parents=True, exist_ok=True)

    for path in sorted(input_dir.glob("*")):
        if not path.is_file():
            continue

        suffix = path.suffix.lower()
        if suffix not in {".pdf", ".md", ".txt"}:
            continue

        try:
            stem = path.stem

            if suffix == ".pdf":
                with fitz.open(path) as doc:
                    text = "\n".join(page.get_text() for page in doc)
            else:
                text = path.read_text(encoding="utf-8")

            text_path = rawtext_dir / f"{stem}.md"
            text_path.write_text(text, encoding="utf-8")
            chunk_count = write_chunks(text, chunk_dir, stem)

            metadata = {
                "input_file": path.name,
                "source_format": suffix.lstrip("."),
                "text_output": f"{text_path.name}",
                "chunk_pattern": f"{stem}-*.md",
                "chunk_count": chunk_count,
                "status": "processed",
            }
            (json_dir / f"{stem}.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
            shutil.move(str(path), str(original_dir / path.name))
        except Exception:
            if path.exists():
                shutil.move(str(path), str(failed_dir / path.name))


if __name__ == "__main__":
    main()
