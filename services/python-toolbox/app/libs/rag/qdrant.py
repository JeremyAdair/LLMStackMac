from qdrant_client import QdrantClient
from qdrant_client.http import models


def get_client(url: str) -> QdrantClient:
    return QdrantClient(url=url)


def ensure_collection(client: QdrantClient, collection: str, vector_size: int) -> None:
    collections = client.get_collections().collections
    existing = {c.name for c in collections}
    if collection in existing:
        return
    client.create_collection(
        collection_name=collection,
        vectors_config=models.VectorParams(
            size=vector_size,
            distance=models.Distance.COSINE,
        ),
    )


def upsert_points(
    client: QdrantClient,
    collection: str,
    points: list[models.PointStruct],
) -> None:
    client.upsert(collection_name=collection, points=points)
