import os
from datetime import datetime
from pathlib import Path

import requests
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams, PointStruct


def chunk_text(text, chunk_size, chunk_overlap):
    words = text.split()
    chunks = []
    start = 0
    while start < len(words):
        end = start + chunk_size
        chunk = " ".join(words[start:end])
        if chunk:
            chunks.append(chunk)
        start = end - chunk_overlap
        if start < 0:
            start = 0
    return chunks


def embed_text(base_url, model, text):
    response = requests.post(
        f"{base_url}/api/embeddings",
        json={"model": model, "prompt": text},
        timeout=60,
    )
    response.raise_for_status()
    return response.json()["embedding"]


def main():
    source_dirs_value = os.getenv("RAG_SOURCE_DIRS")
    if source_dirs_value:
        source_dirs = [Path(path.strip()) for path in source_dirs_value.split(",") if path.strip()]
    else:
        source_dirs = [Path(os.getenv("RAG_SOURCE_DIR", "/workspace/processed"))]
    collection = os.getenv("RAG_COLLECTION", "documents")
    embed_model = os.getenv("RAG_EMBED_MODEL", "nomic-embed-text")
    vector_size = int(os.getenv("RAG_VECTOR_SIZE", "768"))
    chunk_size = int(os.getenv("RAG_CHUNK_SIZE", "400"))
    chunk_overlap = int(os.getenv("RAG_CHUNK_OVERLAP", "50"))
    ollama_base_url = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
    qdrant_url = os.getenv("QDRANT_URL", "http://qdrant:6333")

    qdrant = QdrantClient(url=qdrant_url)
    qdrant.recreate_collection(
        collection_name=collection,
        vectors_config=VectorParams(size=vector_size, distance=Distance.COSINE),
    )

    points = []
    point_id = 1
    for source_dir in source_dirs:
        for path in sorted(source_dir.glob("*.md")):
            text = path.read_text(encoding="utf-8")
            for idx, chunk in enumerate(chunk_text(text, chunk_size, chunk_overlap)):
                vector = embed_text(ollama_base_url, embed_model, chunk)
                payload = {
                    "filename": path.name,
                    "chunk_index": idx,
                    "ingested_at": datetime.utcnow().isoformat(),
                }
                points.append(PointStruct(id=point_id, vector=vector, payload=payload))
                point_id += 1

    if points:
        qdrant.upsert(collection_name=collection, points=points)


if __name__ == "__main__":
    main()
