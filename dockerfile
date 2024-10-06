# Base image with Python 3.12 on Debian Bookworm slim
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Set timezone (if necessary)
ENV TZ=UTC

# Set the working directory in the container to /app
WORKDIR /app

# Install base system dependencies, npm, and clean up apt cache
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository into /app inside the container
COPY . /app

# Use `uv` to sync Python dependencies with caching for faster builds
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=/app/uv.lock \
    --mount=type=bind,source=README.md,target=/app/README.md \
    --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
    --mount=type=bind,source=src/backend/base/README.md,target=/app/src/backend/base/README.md \
    --mount=type=bind,source=src/backend/base/uv.lock,target=/app/src/backend/base/uv.lock \
    --mount=type=bind,source=src/backend/base/pyproject.toml,target=/app/src/backend/base/pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# Expose ports that Langflow (and the frontend) run on
EXPOSE 7860  # Langflow backend or API
EXPOSE 3000  # Optional frontend port

# Run dev start script to start Langflow app
CMD ["./docker/dev.start.sh"]