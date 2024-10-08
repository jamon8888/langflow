# syntax=docker/dockerfile:1
# Keep this syntax directive! It's used to enable Docker BuildKit

################################
# BUILDER-BASE
# Used to build deps + create our virtual environment
################################

# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

# Set the working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    build-essential \
    gcc \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install project dependencies including networkx
COPY src/backend/base/pyproject.toml src/backend/base/pyproject.toml
COPY src/backend/base/uv.lock src/backend/base/uv.lock
RUN --mount=type=cache,target=/root/.cache/uv \
    pip install networkx==3.1 \
    && cd src/backend/base && uv sync --frozen --no-install-project --no-dev --no-editable

# Copy application source code
ADD ./src /app/src

# Build frontend assets
COPY src/frontend /tmp/src/frontend
WORKDIR /tmp/src/frontend
RUN npm install \
    && npm run build \
    && cp -r build /app/src/backend/base/langflow/frontend \
    && rm -rf /tmp/src/frontend

# Finalize dependencies
WORKDIR /app/src/backend/base
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable

################################
# RUNTIME
# Setup user, utilities, and copy the virtual environment only
################################
FROM python:3.12.3-slim AS runtime

# Create a non-root user
RUN useradd user -u 1000 -g 0 --no-create-home --home-dir /app/data

# Copy the virtual environment from the builder
COPY --from=builder --chown=1000 /app/src/backend/base/.venv /app/src/backend/base/.venv

# Place executables in the environment at the front of the path
ENV PATH="/app/src/backend/base/.venv/bin:$PATH"

# Set metadata labels
LABEL org.opencontainers.image.title=langflow
LABEL org.opencontainers.image.authors='Langflow'
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.url=https://github.com/langflow-ai/langflow
LABEL org.opencontainers.image.source=https://github.com/langflow-ai/langflow

# Set the user and working directory
USER user
WORKDIR /app

# Define environment variables for the application
ENV LANGFLOW_HOST=0.0.0.0
ENV LANGFLOW_PORT=7860

# Command to run the application
CMD ["langflow-base", "run"]
