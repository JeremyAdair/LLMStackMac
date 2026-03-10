import sys
from pathlib import Path

import psycopg2
import redis
from loguru import logger
from qdrant_client import QdrantClient

SCRIPT_DIR = Path(__file__).resolve().parent
APP_ROOT = SCRIPT_DIR.parent.parent
sys.path.append(str(APP_ROOT))

from libs.common.config import load_service_config
from libs.common.logging import configure_logging


def check_redis(url: str) -> bool:
    client = redis.Redis.from_url(url)
    return client.ping()


def check_postgres(url: str) -> bool:
    conn = psycopg2.connect(url)
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
        return True
    finally:
        conn.close()


def check_qdrant(url: str) -> bool:
    client = QdrantClient(url=url)
    client.get_collections()
    return True


def run_checks() -> dict:
    cfg = load_service_config()
    results: dict[str, object] = {"redis": False, "postgres": None, "qdrant": False}

    try:
        results["redis"] = check_redis(cfg.redis_url)
    except Exception as exc:
        results["redis_error"] = str(exc)

    if cfg.database_url:
        try:
            results["postgres"] = check_postgres(cfg.database_url)
        except Exception as exc:
            results["postgres_error"] = str(exc)
    else:
        results["postgres"] = None

    try:
        results["qdrant"] = check_qdrant(cfg.qdrant_url)
    except Exception as exc:
        results["qdrant_error"] = str(exc)

    return results


def main() -> int:
    configure_logging()
    results = run_checks()
    for name, value in results.items():
        logger.info("Health check", service=name, result=value)

    failed = False
    if results.get("redis") is not True:
        failed = True
    if results.get("postgres") is False:
        failed = True
    if results.get("qdrant") is not True:
        failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
