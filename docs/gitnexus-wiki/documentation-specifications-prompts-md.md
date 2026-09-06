# Documentation & Specifications — prompts.md

# Documentation & Specifications — prompts.md

## Purpose

prompts.md centralizes feature proposals, architectural decisions, and implementation tasks for the vue-python-demo project. It documents the roadmap across frontend (Vue 3 + Vuetify), backend (FastAPI), testing, and infrastructure. Each proposal follows a consistent structure: objective, current state, items to implement, and requirements. The module serves as both planning document and execution checklist, ensuring proposed changes are tracked, verified, and archived systematically.

## Structure

The file contains proposals organized by feature area:

- **Proposal 1**: Project skeleton setup (Monorepo structure, FastAPI + Vue 3 + Vuetify, Docker, .env.example, README.md)
- **Proposal 2**: Backend core configuration (Pydantic Settings, SQLAlchemy, JWT stub, API routers with versioning, CORS, global exception handling, Alembic initialization)
- **Proposal 3**: Add tests for all features (pytest for FastAPI, Vitest + Vue Test Utils for frontend, test DB for backend, mock for frontend)
- **Proposal 4**: Enhance Vuetify frontend with tests (MD3 theme, DefaultLayout, Pinia stores, Dashboard page, Vitest configuration)
- **Proposal**: fix-alembic-configuration (alembic.ini url, env.py imports, Dockerfile copy, docker-compose service name)
- **Proposal**: add-user-authentication-with-jwt-and-cookies (User model, register/login endpoints, AuthContext/Pinia, HttpOnly cookie, route protection)
- **Proposal**: improve-auth-error-handling-and-logging (structured logging, custom exceptions, unified error response format)
- **Proposal**: fix-login-register-ref-and-404 (ref import fix, router routes, AuthLayout usage)
- **Proposal**: enhance-dashboard-with-real-api-data (dashboard/stats and users endpoints, Dashboard.vue API calls, loading/error states)
- **Proposal**: restructure-to-module-architecture (frontend/src/modules/, backend/app/modules/, tests/modules/ reorganization)
- **Proposal**: create-admin-system-status-page-with-roles (Role model, default admin user, admin API endpoints, AdminStatus.vue, permission guard)
- **Proposal**: fix-auto-migration-on-startup (User model verification, migration generation, automatic upgrade head on container start)
- **Proposal**: enforce-project-venv (.venv usage, uv as sole Python tool, gitignore updates, venv check script)

## Key Components

### Proposal Format

Each proposal follows this structure:

```
**目標**: Clear objective statement
**目前狀態**: Current project state relevant to the proposal
**這次要新增/優化的項目**: Specific items to implement
**要求**: Quality and compatibility requirements
```

### Code References

Proposals reference actual code patterns and file paths:

- `app/main.py` — FastAPI main application
- `app/core/config.py` — Pydantic Settings configuration (DATABASE_URL, SECRET_KEY, DEBUG)
- `app/core/database.py` — SQLAlchemy engine setup
- `app/core/security.py` — JWT security stub
- `app/api/v1/endpoints/health.py` — Health endpoint
- `app/api/v1/endpoints/__init__.py` — Endpoints package init
- `app/api/v1/__init__.py` — V1 API package init
- `app/api/v1/router/` — Router configuration
- `alembic/env.py` — Alembic configuration (imports settings.DATABASE_URL)
- `alembic.ini` — Alembic initialization (sqlalchemy.url, script_location)
- `backend/requirements.txt` — Dependencies (fastapi, uvicorn, pydantic-settings, sqlalchemy, alembic, psycopg2-binary, python-jose[cryptography], passlib[bcrypt])
- `frontend/package.json` — Node dependencies (vue, vite, @vitejs/plugin-vue, vuetify, pinia, axios)
- `frontend/src/App.vue` — Root Vue component
- `frontend/src/router/index.ts` — Vue Router configuration
- `frontend/src/services/api.ts` — Axios instance (withCredentials flag)
- `frontend/src/stores/theme.ts` — Pinia theme store
- `frontend/src/stores/auth.ts` — Pinia auth store
- `docker-compose.yml` — Backend + frontend service orchestration
- `Dockerfile` — Backend and frontend build instructions
- `.env.example` — Environment variable examples

### Execution Flows

Key operational sequences documented:

1. **Backend startup and verification**:
   ```
   podman-compose down
   podman-compose up -d --build
   curl http://localhost:8000/health
   curl http://localhost:8000/api/v1/health
   ```

2. **Alembic migration execution**:
   ```
   podman-compose exec backend alembic current
   podman-compose exec backend alembic upgrade head
   ```

3. **Frontend build and test**:
   ```
   cd frontend && npm run build
   cd frontend && npm run test
   ```

4. **Authentication flow** (after add-user-authentication-with-jwt-and-cookies):
   - Register: `POST /api/v1/auth/register` with JSON body {email, password, full_name}
   - Login: `POST /api/v1/auth/login` with JSON body {email, password}
   - Protected: `GET /api/v1/users/me` with HttpOnly cookie (withCredentials: true)
   - CORS: Access-Control-Allow-Origin: http://localhost:5173

5. **Module restructuring flow** (restructure-to-module-architecture):
   - Scan existing frontend, backend, tests directories
   - Reorganize into module-based structure:
     - `frontend/src/modules/<module-name>/` (components, views, api, stores, types)
     - `backend/app/modules/<module-name>/` (api, services, models, __init__.py)
     - `tests/modules/<module-name>/` (test_api.py, test_services.py, etc.)
   - Update all imports and references
   - Run verification: `cd /code/vue-python-demo; npm run test`, `cd /code/vue-python-demo/backend; uv run pytest -v`

6. **Archive flow** (after /opsx:apply):
   - Verify all tasks complete
   - Run `gitnexus analyze .`
   - Run `gitnexus wiki .`
   - Run `openwiki --update`
   - Archive with `/opsx-archive`

## Connections to Codebase

prompts.md connects to the actual codebase through:

1. **Direct code references**: Proposals specify exact files to create/modify with verbatim paths
2. **Execution commands**: Verification commands developers run after `/opsx:apply`
3. **Dependency updates**: Requirements additions to `requirements.txt` and `package.json`
4. **Configuration changes**: Dockerfile, docker-compose.yml, vite.config.ts, tsconfig.json modifications
5. **Test integration**: pytest conftest, test_database, test_api_health setups; vitest.config.ts with happy-dom
6. **Knowledge management**: `gitnexus analyze .`, `gitnexus wiki .`, `openwiki --update` after changes
7. **Architecture specs**: OpenSpec specs in `openspec/` directory updated to match implemented structure

The module ensures that every proposed change has a clear path from documentation to implementation to verification, with systematic updates to the project's knowledge graph and wiki.

## Mermaid Diagram: Proposal Workflow

```mermaid
flowchart TD
    A[Create proposal] --> B{Review proposal}
    B -->|Approve| C[Generate design + tasks]
    C --> D[/opsx:apply]
    D --> E[Verify execution]
    E --> F{All complete?}
    F -->|Yes| G[/opsx-archive]
    F -->|No| C
```

## How to Use This Document

Developers should:

1. Review proposals before implementing any feature
2. Follow the task checklist in each proposal
3. Run verification commands after `/opsx:apply`
4. Update `gitnexus analyze .`, `gitnexus wiki .`, and `openwiki --update` after changes
5. Archive completed changes with `/opsx-archive`
6. For module restructuring, scan existing directories first, then reorganize into `frontend/src/modules/`, `backend/app/modules/`, and `tests/modules/` with corresponding import updates
7. For authentication features, ensure `withCredentials: true` in `frontend/src/services/api.ts` and HttpOnly cookie handling on the frontend