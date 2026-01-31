FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
  && rm -rf /var/lib/apt/lists/*

COPY requirements-base.txt /app/requirements-base.txt
COPY requirements-ot.txt /app/requirements-ot.txt
COPY requirements-rag.txt /app/requirements-rag.txt
COPY requirements-dev.txt /app/requirements-dev.txt

RUN pip install --no-cache-dir -r /app/requirements-base.txt \
  && pip install --no-cache-dir -r /app/requirements-ot.txt \
  && pip install --no-cache-dir -r /app/requirements-rag.txt \
  && pip install --no-cache-dir -r /app/requirements-dev.txt

COPY app /app

CMD ["sleep", "infinity"]
