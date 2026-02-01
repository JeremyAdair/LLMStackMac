from __future__ import annotations

import json
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

from fastapi import APIRouter, Body, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse, HTMLResponse

router = APIRouter(tags=["scripts"])

APP_SCRIPTS_ROOT = Path("/app/scripts")
BIN_ROOT = Path("/host-bin")
ROOTS = {
    "app": APP_SCRIPTS_ROOT,
    "bin": BIN_ROOT,
}
EXEC_ROOTS = {"app"}


def _root_for(key: str) -> Path:
    if key not in ROOTS:
        raise HTTPException(status_code=400, detail="Unknown root")
    return ROOTS[key]


def _resolve_path(root_key: str, rel_path: str | None) -> Path:
    root = _root_for(root_key).resolve()
    rel = Path(rel_path or "")
    target = (root / rel).resolve()
    if target != root and root not in target.parents:
        raise HTTPException(status_code=400, detail="Path escapes root")
    return target


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


@router.get("/ui", response_class=HTMLResponse)
def scripts_ui() -> FileResponse:
    ui_path = Path(__file__).with_name("scripts_ui.html")
    return FileResponse(ui_path)


@router.get("/scripts/roots")
def list_roots() -> dict[str, Any]:
    return {
        key: {"path": str(path), "exists": path.exists()}
        for key, path in ROOTS.items()
    }


@router.get("/scripts/list")
def list_entries(root: str, path: str | None = None) -> dict[str, Any]:
    base = _resolve_path(root, path)
    if not base.exists():
        raise HTTPException(status_code=404, detail="Path not found")
    if base.is_file():
        return {
            "path": str(base),
            "type": "file",
            "entries": [],
        }
    entries = []
    for child in sorted(base.iterdir(), key=lambda p: (p.is_file(), p.name.lower())):
        entries.append(
            {
                "name": child.name,
                "path": str(child.relative_to(_root_for(root))),
                "type": "dir" if child.is_dir() else "file",
                "size": child.stat().st_size if child.is_file() else None,
            }
        )
    return {
        "path": str(base.relative_to(_root_for(root))),
        "type": "dir",
        "entries": entries,
    }


@router.get("/scripts/view")
def view_file(root: str, path: str) -> dict[str, Any]:
    target = _resolve_path(root, path)
    if not target.exists() or not target.is_file():
        raise HTTPException(status_code=404, detail="File not found")
    content = target.read_text(encoding="utf-8", errors="replace")
    return {"path": str(target.relative_to(_root_for(root))), "content": content}


@router.put("/scripts/save")
def save_file(
    root: str = Body(...),
    path: str = Body(...),
    content: str = Body(...),
) -> dict[str, Any]:
    target = _resolve_path(root, path)
    _ensure_parent(target)
    target.write_text(content, encoding="utf-8")
    return {"ok": True, "path": str(target.relative_to(_root_for(root)))}


@router.post("/scripts/upload")
async def upload_file(
    root: str = Form(...),
    path: str | None = Form(None),
    file: UploadFile = File(...),
) -> dict[str, Any]:
    base = _resolve_path(root, path)
    base.mkdir(parents=True, exist_ok=True)
    target = _resolve_path(root, str(Path(path or "") / file.filename))
    content = await file.read()
    _ensure_parent(target)
    target.write_bytes(content)
    return {"ok": True, "path": str(target.relative_to(_root_for(root)))}


@router.post("/scripts/mkdir")
def make_dir(root: str = Body(...), path: str = Body(...)) -> dict[str, Any]:
    target = _resolve_path(root, path)
    target.mkdir(parents=True, exist_ok=True)
    return {"ok": True, "path": str(target.relative_to(_root_for(root)))}


@router.delete("/scripts/delete")
def delete_entry(root: str, path: str) -> dict[str, Any]:
    target = _resolve_path(root, path)
    root_path = _root_for(root).resolve()
    if target == root_path:
        raise HTTPException(status_code=400, detail="Refusing to delete root")
    if not target.exists():
        raise HTTPException(status_code=404, detail="Path not found")
    if target.is_dir():
        shutil.rmtree(target)
    else:
        target.unlink()
    return {"ok": True}


@router.post("/scripts/run")
def run_script(payload: dict[str, Any] = Body(...)) -> dict[str, Any]:
    root = payload.get("root")
    path = payload.get("path")
    args = payload.get("args") or []
    timeout_sec = int(payload.get("timeout_sec") or 60)

    if root not in EXEC_ROOTS:
        raise HTTPException(status_code=400, detail="Execution only allowed for app scripts")
    if not path:
        raise HTTPException(status_code=400, detail="Missing path")

    target = _resolve_path(root, path)
    if not target.exists() or not target.is_file():
        raise HTTPException(status_code=404, detail="File not found")
    if target.suffix.lower() != ".py":
        raise HTTPException(status_code=400, detail="Only .py scripts can be executed")

    cmd = [sys.executable, str(target)] + [str(a) for a in args]
    started = time.time()
    try:
        completed = subprocess.run(
            cmd,
            cwd=str(target.parent),
            capture_output=True,
            text=True,
            timeout=timeout_sec,
        )
    except subprocess.TimeoutExpired as exc:
        return {
            "ok": False,
            "timeout": True,
            "cmd": cmd,
            "stdout": exc.stdout or "",
            "stderr": exc.stderr or "",
            "duration_sec": round(time.time() - started, 2),
        }

    return {
        "ok": completed.returncode == 0,
        "cmd": cmd,
        "returncode": completed.returncode,
        "stdout": completed.stdout,
        "stderr": completed.stderr,
        "duration_sec": round(time.time() - started, 2),
    }


@router.get("/scripts/config")
def scripts_config() -> dict[str, Any]:
    return {
        "roots": {key: str(path) for key, path in ROOTS.items()},
        "exec_roots": sorted(EXEC_ROOTS),
    }


@router.post("/scripts/parse_args")
def parse_args(payload: dict[str, Any] = Body(...)) -> dict[str, Any]:
    raw = payload.get("raw", "")
    try:
        args = json.loads(raw) if raw else []
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Args must be JSON array")
    if not isinstance(args, list):
        raise HTTPException(status_code=400, detail="Args must be JSON array")
    return {"args": args}
