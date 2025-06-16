# Build stage
FROM python:3.10-slim as builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Runtime stage
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    fonts-dejavu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY video /app/video
COPY server.py /app/server.py
COPY assets /app/assets

ENV PYTHONUNBUFFERED=1

CMD ["fastapi", "run", "server.py", "--host", "0.0.0.0", "--port", "8000"]
