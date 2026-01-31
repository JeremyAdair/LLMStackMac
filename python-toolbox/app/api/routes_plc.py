from pathlib import Path

from fastapi import APIRouter

from libs.common.config import load_plc_config
from libs.plc.ab import poll_tags
from scripts.plc_poll.poll_plc import load_tagset

router = APIRouter(prefix="/plc", tags=["plc"])


@router.post("/poll_once")
def poll_once() -> dict:
    cfg = load_plc_config()
    plc_ip, plc_slot, tags = load_tagset(
        Path(cfg.tagset_path),
        cfg.ip,
        cfg.slot,
    )
    values = poll_tags(plc_ip, plc_slot, cfg.timeout, tags)
    return {"plc_ip": plc_ip, "values": values}
