# Base image: Use the specified Python 3.12 image based on Debian Bookworm slim
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Set timezone to UTC (you can modify this as per your requirements)
ENV TZ=UTC

# Set the working directory inside the container
WORKDIR /app

# Copy the uv.lock file to minimize cache invalidation for dependencies
COPY ./uv.lock /app/

# Install system dependencies in one go
# Use optimization to reduce installation time and image size
RUN sed -i 's|http://deb.debian.org/debian|http://ftp.us.debian.org/debian|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy application code after system dependencies have been installed
COPY . /app/

# Expose necessary ports: adjust these if needed by your app
EXPOSE 7860
EXPOSE 3000

# Set the default entry point when starting the container
CMD ["./docker/dev.start.sh"]