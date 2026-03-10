from typing import Iterable

from loguru import logger
from pylogix import PLC


def poll_tags(ip: str, slot: int, timeout: float, tags: Iterable[str]) -> dict:
    results: dict[str, object] = {}
    with PLC() as comm:
        comm.IPAddress = ip
        comm.ProcessorSlot = slot
        comm.Timeout = timeout
        for tag in tags:
            if not tag:
                continue
            try:
                response = comm.Read(tag)
                if response is None:
                    results[tag] = None
                elif response.Status == "Success":
                    results[tag] = response.Value
                else:
                    results[tag] = None
                    logger.warning("Tag read failed", tag=tag, status=response.Status)
            except Exception as exc:
                logger.error("Tag read error", tag=tag, error=str(exc))
                results[tag] = None
    return results
