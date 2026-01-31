from fastapi import FastAPI

from api.routes_plc import router as plc_router
from api.routes_rag import router as rag_router
from scripts.db_tools.healthcheck import run_checks

app = FastAPI(title="Python Toolbox API")

app.include_router(plc_router)
app.include_router(rag_router)


@app.get("/health")
def health() -> dict:
    return run_checks()
