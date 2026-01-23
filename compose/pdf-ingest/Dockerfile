# Slim Python base keeps the image small.
FROM python:3.11-slim

# All app files live in /app inside the container.
WORKDIR /app

# Install only the minimal dependencies needed for PDF conversion.
COPY scripts/pdf_ingest/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the conversion script into the image.
COPY scripts/pdf_ingest/convert.py /app/convert.py

# Run the converter when the container starts.
ENTRYPOINT ["python", "/app/convert.py"]
