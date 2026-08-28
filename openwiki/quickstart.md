---
type: Project
title: Full-Stack Demo (Vuetify + FastAPI)
description: Monorepo demonstrating full-stack development with Vue 3 + Vuetify frontend and FastAPI backend, featuring AI/LLM integration, RAG pipeline, Docker orchestration, and Kubernetes deployment readiness.
tags: [monorepo, vue3, fastapi, vuetify, docker, typescript, ai, llm, rag]
---

# Full-Stack Demo

A monorepo demo application with a Vue 3 + Vuetify frontend and FastAPI backend, designed as a clean starting point for full-stack development.

## Architecture Overview

This project follows a monorepo structure with clear separation between frontend and backend services:

```
demo/
├── backend/          # FastAPI Python backend
├── frontend/         # Vue 3 + Vuetify TypeScript frontend
├── docker/           # Docker configuration assets
├── openspec/         # OpenSpec change management
└── openwiki/         # Project documentation
```

**Key Components:**
- **Backend**: FastAPI application with health check endpoint, running on port 8000
- **Frontend**: Vue 3 + Vite + Vuetify 3 SPA, running on port 5173
- **Orchestration**: Docker Compose for unified development environment

## Getting Started

### Prerequisites

- Python 3.10+
- Node.js 18+
- Docker & Docker Compose (optional, for containerized development)

### Quick Start (Docker)

```bash
cp .env.example .env
docker compose up
```

- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- Health check: http://localhost:8000/health

### Local Development

**Backend:**
```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

## Project Sections

- [Backend Service](/openwiki/backend-service.md) - FastAPI backend with health and AI endpoints
- [Frontend App](/openwiki/frontend-app.md) - Vue 3 + Vuetify frontend application with chat capabilities
- [RAG Pipeline](/openwiki/rag/overview.md) - Retrieval-Augmented Generation with ChromaDB and PGVector
- [Docker Orchestration](/openwiki/docker-orchestration.md) - Container configuration and deployment
- [Kubernetes Deployment](/openwiki/kubernetes/overview.md) - Kubernetes deployment manifests and GKE deployment script
- [Observability](/openwiki/observability.md) - OpenTelemetry, metrics, tracing, logging, and Grafana dashboards
- [Internal Docs](/docs/internal) - Auto-generated API reference (MkDocs) mounted in FastAPI

## Development Workflow

This project uses OpenSpec for spec-driven development:

- `/opsx-propose` - Create a new change proposal
- `/opsx-apply` - Apply a change to the codebase
- `/opsx-update` - Update an existing change
- `/opsx-archive` - Archive a completed change

See `.agent/workflows/` for workflow definitions.

## Key Decisions

1. **Monorepo structure** - Simple, standard pattern for full-stack projects
2. **FastAPI with minimal dependencies** - Async support, automatic OpenAPI docs
3. **Vue 3 + TypeScript + Vite** - Type safety and fast HMR
4. **Vuetify 3** - Material Design components with Vue 3 Composition API support
5. **Docker Compose** - One-command startup for development environment

## Non-Goals (Current Scope)

- Authentication or authorization
- Production-grade security hardening

## Running Tests

### Backend Tests

```bash
cd backend
pip install pytest httpx pytest-asyncio
pytest
```

Tests include:
- Health endpoint tests (`/health`, `/api/v1/health`)
- Configuration validation tests
- Database connection and session tests
- CORS and error handling tests

### Frontend Tests

```bash
cd frontend
npm run test
```

Tests include:
- Component rendering tests (App.vue)
- Pinia store tests (theme store)
- API service tests
- Router tests

### Docker Test Execution

```bash
# Backend tests in container
docker compose exec backend pytest

# Frontend tests in container
docker compose exec frontend npm run test
```

## Source References

- Backend entrypoint: `backend/app/main.py`
- Frontend entrypoint: `frontend/src/main.ts`
- Docker Compose: `docker-compose.yml`
- Environment template: `.env.example`
