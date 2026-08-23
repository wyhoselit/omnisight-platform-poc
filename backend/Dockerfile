FROM python:3.11-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Copy pyproject.toml and uv.lock
COPY pyproject.toml uv.lock ./

# Create virtual environment and install dependencies with uv
RUN uv venv && uv pip install .
RUN uv pip install mkdocs-material "mkdocstrings[python]"

# Copy application code FIRST (needed for mkdocstrings to import modules)
COPY app/ ./app/
COPY alembic/ ./alembic/
COPY alembic.ini .
COPY init_db.py .
COPY scripts/ ./scripts/

# Copy docs and mkdocs config for building documentation
COPY mkdocs.yml ./
COPY docs/ ./docs/

# Build MkDocs static documentation
RUN uv run mkdocs build

COPY pytest.ini .
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]