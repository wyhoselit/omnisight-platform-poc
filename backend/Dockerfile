FROM python:3.11-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Copy pyproject.toml and uv.lock
COPY pyproject.toml uv.lock ./

# Create virtual environment and install dependencies with uv
RUN uv venv && uv pip install .

COPY alembic/ ./alembic/
COPY alembic.ini .
COPY app/ ./app/
COPY pytest.ini .
COPY init_db.py .
COPY docs/ ./docs/
COPY mkdocs.yml .

# Build documentation
RUN uv run mkdocs build --site-dir site

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]