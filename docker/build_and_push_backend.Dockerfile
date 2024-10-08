# syntax=docker/dockerfile:1
# Keep this syntax directive! It's used to enable Docker BuildKit

ARG LANGFLOW_IMAGE=ixinjulu/platform
FROM ${LANGFLOW_IMAGE}

# Additional backend-specific steps
RUN rm -rf /app/.venv/langflow/frontend
WORKDIR /app/backend
COPY . /app
COPY README.md /app/README.md 

CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "7860", "--backend-only"]
