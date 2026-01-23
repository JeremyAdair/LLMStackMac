# Slim Python base keeps the image small.
FROM python:3.11-slim

# All app files live in /app inside the container.
WORKDIR /app

# Install only the minimal dependencies needed for ingestion.
COPY scripts/rag_pipeline/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the ingestion script into the image.
COPY scripts/rag_pipeline/ingest.py /app/ingest.py

# Run the ingestion job when the container starts.
ENTRYPOINT ["python", "/app/ingest.py"]
