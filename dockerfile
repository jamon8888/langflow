# Base image with Python 3.12 from uv (Universal Virtualization)
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Set timezone as UTC
ENV TZ=UTC

# Set the working directory inside the container
WORKDIR /app

# Install base system dependencies, npm, and clean up apt cache
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository (local context) to "/app" directory inside the container
COPY . /app

# Use `uv` tool to sync Python dependencies using pyproject.toml and other config files
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=/app/uv.lock \
    --mount=type=bind,source=README.md,target=/app/README.md \
    --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
    --mount=type=bind,source=src/backend/base/README.md,target=/app/src/backend/base/README.md \
    --mount=type=bind,source=src/backend/base/uv.lock,target=/app/src/backend/base/uv.lock \
    --mount=type=bind,source=src/backend/base/pyproject.toml,target=/app/src/backend/base/pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# Expose ports that Langflow will need: 7860 for the main backend, 3000 for any frontend dev work
EXPOSE 7860         # Langflow Backend API
EXPOSE 3000         # Optional frontend or other services

# Use the development entrypoint script (command to start Langflow dev environment)
CMD ["./docker/dev.start.sh"]