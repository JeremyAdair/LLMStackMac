import os
from pathlib import Path

import fitz


def main():
    input_dir = Path(os.getenv("INGEST_INPUT_DIR", "/workspace/ingest"))
    output_dir = Path(os.getenv("INGEST_OUTPUT_DIR", "/workspace/processed"))
    output_dir.mkdir(parents=True, exist_ok=True)

    for path in sorted(input_dir.glob("*")):
        if path.suffix.lower() == ".pdf":
            doc = fitz.open(path)
            text = "\n".join(page.get_text() for page in doc)
            output_path = output_dir / f"{path.stem}.md"
            output_path.write_text(text, encoding="utf-8")
        elif path.suffix.lower() in {".md", ".txt"}:
            output_path = output_dir / path.name
            output_path.write_text(path.read_text(encoding="utf-8"), encoding="utf-8")


if __name__ == "__main__":
    main()
