# Documentation & Specifications — README.md

# README.md — Project Documentation & Specifications

## Purpose

`README.md` serves as the **primary entry point and specification document** for the Full-Stack Demo project. It defines:

- Project scope and goals
- Technology stack and architecture
- Development methodology (modular TDD)
- Setup, build, and deployment instructions
- Observability and DevOps practices
- Mapping of demonstrated competencies to job requirements

This file is the **single source of truth** for developers, reviewers, and stakeholders evaluating the project.

---

## How It Works

`README.md` is a static Markdown file rendered by GitHub (or any Markdown viewer). It does not execute code. Its role is **documentation-as-specification**:

1. **Describes** the project’s purpose, features, and architecture.
2. **Instructs** developers on how to set up, run, test, and deploy the application.
3. **Links** to other specification files (`OBSERVABILITY_SPEC.md`, `docker-compose.observability.yml`, `kubernetes/`, `.github/workflows/`).
4. **Maps** project components to job requirement competencies (DevOps, AI Platform, Backend, Frontend, etc.).

It is **not** generated from code. It is hand-maintained and updated alongside major project changes.

---

## Key Components

### 1. Project Goal & Key Features

Defines the project as a **full-stack demo** integrating:

- **Frontend**: Vue 3 + Vuetify
- **Backend**: FastAPI (Python)
- **AI/LLM**: OpenAI, Anthropic, Local LLMs, RAG, streaming chat
- **Auth**: JWT access/refresh tokens
- **DB**: PostgreSQL + SQLAlchemy + Alembic
- **Async**: Dramatiq workers
- **Testing**: Pytest (backend), Vitest (frontend)
- **DevOps**: Docker, GitHub Actions, Kubernetes, OpenTelemetry stack

### 2. Competency Mapping

Maps project features to **Senior Software Engineer job requirements**, including:

- DevOps (CI/CD, IaC)
- System Maintenance (observability stack)
- Container Usage (Docker Compose, entrypoint migrations)
- Cloud Deployment (Azure/GCP via GitHub Actions)
- System Architecture (modular backend/frontend)
- Backend/Frontend Development
- AI Platform Development
- API Design & Documentation
- Software Quality (linting, typing, testing)

### 3. Development Methodology

Documents the **modular, domain-driven TDD approach**:

- **Backend modules**: `backend/app/modules/` (e.g., `ai`, `auth`, `system`)
- **Frontend modules**: `frontend/src/modules/`
- Each module encapsulates endpoints, services, models, and tests.
- TDD workflow: write failing test → implement → refactor.

### 4. Observability & Monitoring

Specifies the **OpenTelemetry-based observability stack**:

- **OpenTelemetry Collector**: telemetry aggregation
- **Prometheus**: metrics
- **Loki**: logs
- **Tempo**: traces
- **Grafana**: dashboards

Links to:
- `OBSERVABILITY_SPEC.md`
- `docker-compose.observability.yml`
- `kubernetes/`

### 5. Project Structure

Provides a **tree view** of the repository:

```
.
├── backend/
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── modules/
│   │   └── main.py
│   ├── alembic/
│   ├── Dockerfile
│   └── tests/
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── composables/
│   │   ├── layouts/
│   │   ├── modules/
│   │   ├── router/
│   │   ├── services/
│   │   ├── stores/
│   │   └── views/
│   ├── Dockerfile
│   └── src/__tests__/
├── docker-compose.yml
└── .env.example
```

### 6. Setup & Run Instructions

#### Backend

```bash
cd backend
uv sync
uv run uvicorn app.main:app --reload
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

#### Docker

```bash
cp .env.example .env
docker compose up
```

#### Podman

```bash
cp .env.example .env
podman compose up
```

### 7. API Endpoints

Documents key endpoints:

- `GET /api/v1/health`
- `GET /api/v1/dashboard/stats`
- `GET /api/v1/users`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `GET /api/v1/users/me`

### 8. Testing

- **Backend**: `cd backend && uv run pytest`
- **Frontend**: `cd frontend && npm run test`

### 9. Kubernetes / GCP Deployment

Links to `deploy-k8s.sh` and `kubernetes/` directory.

### 10. Frontend Layout Architecture

Documents the **layout component pattern**:

- `src/layouts/DefaultLayout.vue` — main layout
- `App.vue` must use `<DefaultLayout />`
- Pre-commit hook enforces layout usage

---

## Connections to Codebase

`README.md` is the **top-level document** that references and contextualizes all other modules:

| Component | Referenced In |
|----------|---------------|
| `backend/app/` | Project Structure, Setup, API Endpoints |
| `frontend/src/` | Project Structure, Setup, Layout Architecture |
| `docker-compose.yml` | Docker, Podman |
| `OBSERVABILITY_SPEC.md` | Observability & Monitoring |
| `kubernetes/` | Kubernetes / GCP Deployment |
| `.github/workflows/` | CI/CD (implied) |
| `deploy-k8s.sh` | Kubernetes / GCP Deployment |
| `backend/alembic/` | Alembic Migrations |
| `backend/tests/`, `frontend/src/__tests__/` | Testing |

---

## Maintenance Notes

- Update `README.md` when adding new endpoints, changing setup steps, or modifying project structure.
- Keep competency mapping aligned with evolving job requirements.
- Ensure links to `OBSERVABILITY_SPEC.md`, `kubernetes/`, and `.github/workflows/` remain valid.
- Pre-commit hook for frontend layout enforcement is documented but not implemented in this file — see `frontend/` for hook config.