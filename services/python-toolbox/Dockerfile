FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1

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

RUN pip install -r /app/requirements-base.txt \
  && pip install -r /app/requirements-ot.txt \
  && pip install -r /app/requirements-rag.txt \
  && pip install -r /app/requirements-dev.txt

COPY app /app

CMD ["sleep", "infinity"]
