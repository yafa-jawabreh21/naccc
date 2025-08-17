# Backend Dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Default port for FastAPI
ENV PORT=8080
EXPOSE 8080

# Use gunicorn with uvicorn workers in Cloud Run
CMD exec gunicorn -k uvicorn.workers.UvicornWorker -w 2 -b 0.0.0.0:${PORT} app.main:app
