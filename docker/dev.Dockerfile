# Base image
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Set timezone
ENV TZ=UTC

# Set the working directory inside the container
WORKDIR /app

# Copy uv.lock file from the root directory to /app inside the container
COPY ./uv.lock /app/

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy all other contents from the current context (docker folder and below)
# You can adjust this if you want to include only project files, excluding Docker-specific scripts.
COPY . /app/

# Cache uv installation directories for faster builds on dependencies update
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# Expose necessary ports
EXPOSE 7860
EXPOSE 3000

# Define the default entrypoint command to start your app
CMD ["./docker/dev.start.sh"]