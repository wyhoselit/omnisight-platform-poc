# Documentation & Specifications — backend-tests

# Documentation & Specifications — backend-tests

Location: `backend/tests/system/test_docs_mount.py`

## Purpose

System tests for internal documentation routes. Validates FastAPI app serves built MkDocs HTML pages at `/docs/internal/` prefix.

## Fixtures

### `client`
- **Scope**: Function
- **Type**: `starlette.testclient.TestClient`
- **Action**: Wrap `app.main.app` in context manager. Yield client for HTTP calls.

## Test Cases

### `test_docs_mount_serves_index(client)`
- **Target URL**: `/docs/internal/`
- **Checks**:
  - HTTP status 200
  - `content-type` header contains `text/html`
- **Purpose**: Verify root index page of documentation serves correctly.

### `test_docs_mount_serves_module_pages(client)`
- **Target URL**: `/docs/internal/modules/`
- **Checks**:
  - HTTP status 200
  - `content-type` header contains `text/html`
- **Purpose**: Verify generated module documentation subpath accessible.

## Execution

Run tests with `pytest`:

```bash
pytest backend/tests/system/test_docs_mount.py
```

## Integration

```
[pytest TestClient] -> GET /docs/internal/* -> [FastAPI (app.main.app)] -> [Mounted Static Directory]
```

Depends on:
- `app.main.app`: Main FastAPI application instance containing internal docs route mount.
- MkDocs output files present in mounted static directory before test execution.