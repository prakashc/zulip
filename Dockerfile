FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    gettext \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python dependency files
COPY requirements/ requirements/

# Install Python dependencies (use prod requirements if available, else fall back to common)
RUN pip install --no-cache-dir --upgrade pip && \
    if [ -f requirements/prod.txt ]; then \
        pip install --no-cache-dir -r requirements/prod.txt; \
    elif [ -f requirements/common.txt ]; then \
        pip install --no-cache-dir -r requirements/common.txt; \
    fi

# Copy application source
COPY . .

# Expose Cloud Run port
ENV PORT=8080
EXPOSE 8080

# Start a simple HTTP server as a placeholder;
# Zulip normally requires a full infrastructure stack (PostgreSQL, Redis, RabbitMQ, etc.)
# For a standalone Cloud Run preview, we serve the static/docs content.
CMD ["python", "-m", "http.server", "8080"]
