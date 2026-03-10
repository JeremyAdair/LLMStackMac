import os
import signal
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import psycopg2
import redis
import yaml
from loguru import logger

SCRIPT_DIR = Path(__file__).resolve().parent
APP_ROOT = SCRIPT_DIR.parent.parent
sys.path.append(str(APP_ROOT))

from libs.common.config import load_plc_config
from libs.common.logging import configure_logging
from libs.common.timing import sleep_until
from libs.plc.ab import poll_tags


def load_tagset(path: Path, default_ip: str, default_slot: int) -> tuple[str, int, list[str]]:
    data = yaml.safe_load(path.read_text())
    plcs = data.get("plcs", []) if isinstance(data, dict) else []
    if not plcs:
        return default_ip, default_slot, []
    entry = plcs[0]
    ip = entry.get("ip", default_ip)
    slot = int(entry.get("slot", default_slot))
    tags = [str(tag) for tag in entry.get("tags", [])]
    return ip, slot, tags


def ensure_table(cursor) -> None:
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS plc_readings (
            plc_ip TEXT NOT NULL,
            tag TEXT NOT NULL,
            value TEXT,
            updated_at TIMESTAMPTZ NOT NULL,
            PRIMARY KEY (plc_ip, tag)
        )
        """
    )


def upsert_postgres(cursor, plc_ip: str, values: dict[str, object]) -> None:
    now = datetime.now(timezone.utc)
    for tag, value in values.items():
        cursor.execute(
            """
            INSERT INTO plc_readings (plc_ip, tag, value, updated_at)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (plc_ip, tag)
            DO UPDATE SET value = EXCLUDED.value, updated_at = EXCLUDED.updated_at
            """,
            (plc_ip, tag, str(value), now),
        )


def main() -> int:
    configure_logging()
    cfg = load_plc_config()

    tagset_path = Path(cfg.tagset_path)
    if not tagset_path.exists():
        logger.error("Tagset file not found", path=str(tagset_path))
        return 1

    plc_ip, plc_slot, tags = load_tagset(tagset_path, cfg.ip, cfg.slot)
    if not tags:
        logger.warning("No tags found in tagset", path=str(tagset_path))

    redis_client = redis.Redis.from_url(cfg.redis_url)
    postgres_conn = None
    postgres_cursor = None
    if cfg.database_url:
        postgres_conn = psycopg2.connect(cfg.database_url)
        postgres_conn.autocommit = True
        postgres_cursor = postgres_conn.cursor()
        ensure_table(postgres_cursor)

    stop = False

    def handle_signal(_signum, _frame) -> None:
        nonlocal stop
        stop = True

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    interval_s = max(cfg.poll_interval_ms, 100) / 1000.0
    next_run = time.monotonic()

    while not stop:
        sleep_until(next_run, lambda: stop)
        run_started = time.monotonic()
        values = poll_tags(plc_ip, plc_slot, cfg.timeout, tags)
        timestamp = datetime.now(timezone.utc).isoformat()

        key = f"plc:{plc_ip}"
        redis_client.hset(key, mapping={tag: str(value) for tag, value in values.items()})
        redis_client.hset(key, mapping={"_updated_at": timestamp})

        if postgres_cursor:
            upsert_postgres(postgres_cursor, plc_ip, values)

        elapsed = time.monotonic() - run_started
        logger.info(
            "Poll cycle complete",
            plc_ip=plc_ip,
            tags=len(tags),
            elapsed_s=round(elapsed, 3),
        )
        next_run += interval_s

    if postgres_cursor:
        postgres_cursor.close()
    if postgres_conn:
        postgres_conn.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
