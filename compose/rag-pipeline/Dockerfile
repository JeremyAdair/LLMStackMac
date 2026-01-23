FROM python:3.11-slim

WORKDIR /app

COPY scripts/rag_pipeline/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY scripts/rag_pipeline/ingest.py /app/ingest.py

ENTRYPOINT ["python", "/app/ingest.py"]
