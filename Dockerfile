FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements/ requirements/

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements/prod.txt || \
    pip install --no-cache-dir -r requirements/requirements.txt || \
    pip install --no-cache-dir django gunicorn psycopg2-binary

# Copy application source
COPY . .

EXPOSE 8080

# Run with gunicorn on PORT 8080
CMD exec gunicorn --bind 0.0.0.0:${PORT} --workers 2 --timeout 120 zproject.wsgi:application
