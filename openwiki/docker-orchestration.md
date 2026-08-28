---
type: Infrastructure
title: Docker Orchestration
description: Docker Compose configuration for running the backend and frontend services in a unified development environment, built with uv package manager.
tags: [docker, docker-compose, uv, orchestration, development, containerization]
---

# Docker Orchestration

This project uses Docker Compose to define and run the multi-container Docker application for local development. It sets up both the backend and frontend services, managing their build, networking, and dependencies. The backend is built with Python uv for fast dependency installation.

## Key Features

-   **Unified Environment**: Easily spin up both services with a single command.
-   **Service Isolation**: Each service runs in its own container, ensuring consistent environments.
-   **Volume Mounting**: Source code is mounted into containers for live reloading during development.

## Architecture

The `docker-compose.yml` file defines two services:

-   **`backend`**:
    -   Builds from `backend/Dockerfile` (Python 3.11-slim with `uv` package manager).
    -   Exposes port `8000`.
    -   Mounts `./backend/app` as a volume for development.
    -   Uses `.env` file for environment variables.
    -   Supports `RUN_MIGRATIONS=true` to auto-run Alembic migrations on startup via `docker-entrypoint.sh`.
    -   Automatically builds MkDocs documentation during Docker build.
-   **`frontend`**:
    -   Builds from `frontend/Dockerfile`.
    -   Exposes port `5173`.
    -   Depends on the `backend` service.

## Getting Started (Docker Compose)

To start the entire application using Docker Compose:

1.  **Copy the example environment file:**
    ```bash
    cp .env.example .env
    ```
2.  **Bring up the services:**
    ```bash
    docker compose up
    ```
    (Use `docker compose up -d` to run in detached mode.)

Once up, the services will be available at:

-   **Frontend**: `http://localhost:5173`
-   **Backend**: `http://localhost:8000`
-   **Backend Health Check**: `http://localhost:8000/health`

## Source References

-   Docker Compose configuration: `docker-compose.yml`
-   Backend Dockerfile: `backend/Dockerfile`
-   Frontend Dockerfile: `frontend/Dockerfile`
