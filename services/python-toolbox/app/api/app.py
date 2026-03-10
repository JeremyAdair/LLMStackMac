from contextlib import asynccontextmanager

from fastapi import FastAPI

from api.routes_pdf import router as pdf_router
from api.routes_plc import router as plc_router
from api.routes_rag import router as rag_router
from api.routes_scripts import router as scripts_router
from libs.pdf_ingest_worker.service import get_pdf_ingest_service
from scripts.db_tools.healthcheck import run_checks


@asynccontextmanager
async def lifespan(app: FastAPI):
    service = get_pdf_ingest_service()
    service.start()
    try:
        yield
    finally:
        service.stop()


app = FastAPI(title="Python Toolbox API", lifespan=lifespan)

app.include_router(plc_router)
app.include_router(rag_router)
app.include_router(scripts_router)
app.include_router(pdf_router)


@app.get("/health")
def health() -> dict:
    return run_checks()
