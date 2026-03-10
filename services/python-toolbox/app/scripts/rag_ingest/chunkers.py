from dataclasses import dataclass


@dataclass
class ChunkerConfig:
    chunk_size: int = 500
    overlap: int = 50


def chunk_text(text: str, config: ChunkerConfig) -> list[str]:
    chunks: list[str] = []
    start = 0
    text_length = len(text)

    while start < text_length:
        end = min(start + config.chunk_size, text_length)
        chunk = text[start:end].strip()
        if chunk:
            chunks.append(chunk)
        start = end - config.overlap
        if start < 0:
            start = 0
        if start >= text_length:
            break

    return chunks
