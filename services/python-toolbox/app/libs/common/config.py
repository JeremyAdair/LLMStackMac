import os
from dataclasses import dataclass


def get_env(name: str, default: str) -> str:
    value = os.getenv(name)
    if value is None or value == "":
        return default
    return value


@dataclass
class PlcConfig:
    ip: str
    slot: int
    timeout: float
    poll_interval_ms: int
    redis_url: str
    database_url: str | None
    tagset_path: str


@dataclass
class RagConfig:
    ingest_path: str
    embed_model: str
    qdrant_url: str
    qdrant_collection: str
    database_url: str | None
    redis_url: str


@dataclass
class ServiceConfig:
    redis_url: str
    database_url: str | None
    qdrant_url: str


def load_plc_config() -> PlcConfig:
    return PlcConfig(
        ip=get_env("PLC_IP", "127.0.0.1"),
        slot=int(get_env("PLC_SLOT", "0")),
        timeout=float(get_env("PLC_TIMEOUT", "1.0")),
        poll_interval_ms=int(get_env("POLL_INTERVAL_MS", "1000")),
        redis_url=get_env("REDIS_URL", "redis://redis:6379/0"),
        database_url=os.getenv("DATABASE_URL"),
        tagset_path=get_env(
            "PLC_TAGSET_PATH",
            "/app/scripts/plc_poll/tagsets.example.yaml",
        ),
    )


def load_rag_config() -> RagConfig:
    return RagConfig(
        ingest_path=get_env("INGEST_PATH", "/app/ingest"),
        embed_model=get_env("EMBED_MODEL", "all-MiniLM-L6-v2"),
        qdrant_url=get_env("QDRANT_URL", "http://qdrant:6333"),
        qdrant_collection=get_env("QDRANT_COLLECTION", "documents"),
        database_url=os.getenv("DATABASE_URL"),
        redis_url=get_env("REDIS_URL", "redis://redis:6379/0"),
    )


def load_service_config() -> ServiceConfig:
    return ServiceConfig(
        redis_url=get_env("REDIS_URL", "redis://redis:6379/0"),
        database_url=os.getenv("DATABASE_URL"),
        qdrant_url=get_env("QDRANT_URL", "http://qdrant:6333"),
    )
