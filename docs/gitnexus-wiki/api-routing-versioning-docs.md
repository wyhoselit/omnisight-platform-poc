# API Routing & Versioning — docs

API routing and versioning enforces strict versioned endpoints under `/api/v1` and `/api/v2`. All routes are auto-generated from FastAPI decorators. No manual routing code exists.

`/api/health` (root) is deprecated. Use `/api/v1/health` or `/api/v2/health`. All other endpoints are versioned. V1 and V2 share identical schemas and behavior. V2 is reserved for breaking changes.

Authentication: Bearer token required for all non-`/health` and non-`/metrics` endpoints. Admin routes (`/admin/*`) enforce admin role via dependency.

Error format: `{"detail": "...", "error_code": "ERROR_CODE"}`. Consistent across all endpoints.

Rate limiting: Applied to `/ai/*` endpoints. Configured in FastAPI middleware. No config exposed in docs.

Interactive docs: `/docs` (Swagger), `/redoc` (ReDoc). Auto-generated from OpenAPI spec. Spec updated on merge via `scripts/update_openapi.py`. Do not edit `openapi.json` manually.

Admin endpoints: `/admin/system-info`, `/admin/logs` require admin role. Logs accept `tail=N` query param.

Metrics: `/metrics` serves Prometheus metrics. No auth. Exposed for monitoring.

Schemas: Reused between v1/v2. `ChatRequest`, `RAGQueryRequest`, `EmbeddingRequest`, `UserOut`, `DashboardStats`, `RealtimeDataPoint` defined in OpenAPI. No code duplication.

Mermaid:

```mermaid
graph LR
  Client -->|GET/POST| api_v1_health["/api/v1/health"]
  Client -->|GET/POST| api_v2_health["/api/v2/health"]
  Client -->|Bearer Token| api_v1_auth["/api/v1/auth/"]*
  Client -->|Bearer Token| api_v2_auth["/api/v2/auth/"]*
  Client -->|Bearer Token| api_v1_ai["/api/v1/ai/"]*
  Client -->|Bearer Token| api_v2_ai["/api/v2/ai/"]*
  Client -->|Bearer Token + Admin| api_v1_admin["/api/v1/admin/"]*
  Client -->|Bearer Token + Admin| api_v2_admin["/api/v2/admin/"]*
  Client -->|GET| metrics["/metrics"]
  Client -->|GET| docs["/docs"]
  Client -->|GET| redoc["/redoc"]
  api_v1["/api/v1/"]* --> FastAPI[FastAPI Router]
  api_v2["/api/v2/"]* --> FastAPI
  FastAPI --> OpenAPI[OpenAPI Spec]
  OpenAPI --> docs["/docs"]
  OpenAPI --> redoc["/redoc"]
```

`ponytail:` V3 will require code changes. Current versioning is string-based. No migration path for clients. Add when breaking changes are needed.