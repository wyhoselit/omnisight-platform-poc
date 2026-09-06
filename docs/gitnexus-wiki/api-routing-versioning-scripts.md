# API Routing & Versioning — scripts

# OpenAPI Schema Generator

CLI script exports OpenAPI schema from FastAPI application instance to static JSON file.

## Purpose

Extract static OpenAPI specification from code. Target: `docs/openapi/openapi.json`. 
Use for:
- API documentation hosting
- Frontend client/type generation
- CI contract testing and diff detection

## Flow

```mermaid
flowchart LR
    A[app.main:app] -->|app.openapi| B[Schema Dict]
    B -->|json.dumps| C[docs/openapi/openapi.json]
```

1. Import `app` instance from `app.main`.
2. Generate schema dict with `app.openapi()`.
3. Create target directory `docs/openapi/` if missing.
4. Serialize JSON (indent=2, UTF-8, trailing newline).
5. Write to `docs/openapi/openapi.json`.

## Components

### `backend/scripts/update_openapi.py`

- `main() -> None`: Orchestrates extraction and file write.

| Input | Output Target | Encoding | Format |
|---|---|---|---|
| `app.main.app` | `docs/openapi/openapi.json` | UTF-8 | JSON (indent=2) |

## Usage

Run from backend root:

```bash
python scripts/update_openapi.py
```

Run as module from project root:

```bash
python -m backend.scripts.update_openapi
```

## Integration

- Depends on `app.main:app`. Needs all API routers, models, metadata registered on app instance before execution.
- Relies on relative execution path matching project root structure (`docs/openapi/` directory relative to current working directory).