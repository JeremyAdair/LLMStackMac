FROM python:3.11-slim

WORKDIR /app

COPY compose/python-runner/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY compose/python-runner/app /app

ENTRYPOINT ["python", "/app/main.py"]
