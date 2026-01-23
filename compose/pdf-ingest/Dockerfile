FROM python:3.11-slim

WORKDIR /app

COPY scripts/pdf_ingest/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY scripts/pdf_ingest/convert.py /app/convert.py

ENTRYPOINT ["python", "/app/convert.py"]
