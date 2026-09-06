# API Routing & Versioning — site

# API Documentation & Routing Reference

Static API documentation module generated via MkDocs Material and Redoc. Serves human-readable endpoint catalog, interactive OpenAPI 3.1.0 specification, and schema definitions.

## Route Architecture & Versioning

Routes split across unversioned root utilities, `/api/v1`, and `/api/v2` prefixes.

```mermaid
graph TD
    Root[App Root] --> Base[Base Routes]
    Root --> V1[/api/v1]
    Root --> V2[/api/v2]

    Base --> R_Health[/health]
    Base --> R_Metrics[/metrics]

    V1 --> V1_Sys[system, auth, admin, dashboard, users, ai]
    V2 --> V2_Sys[health, auth, admin, dashboard, users, ai]
```

### Global Conventions

- **Auth**: Bearer token via HTTP Header: `Authorization: Bearer <access_token>`
- **Error format**:
```json
{
  "detail": "Error description",
  "error_code": "ERROR_CODE"
}
```

---

## Endpoint Catalog

### System & Health

| Method | Path | Version | Operation ID | Description |
|---|---|---|---|---|
| `GET` | `/health` | Root | `health_check_health_get` | Basic service health check |
| `GET` | `/metrics` | Root | `metrics_metrics_get` | Prometheus metrics scrape target |
| `GET` | `/api/v1/health` | v1 | `health_check_api_v1_health_get` | Versioned v1 health check |
| `GET` | `/api/v2/health` | v2 | `health_check_api_v2_health_get` | Versioned v2 health check |
| `GET` | `/api/v1/system/config/` | v1 | `get_all_configs_api_v1_system_config__get` | List all system configuration entries |
| `GET` | `/api/v1/system/config/{key}` | v1 | `get_config_api_v1_system_config__key__get` | Get config value by key name |
| `PUT` | `/api/v1/system/config/{key}` | v1 | `update_config_api_v1_system_config__key__put` | Update config value by key name |

### Authentication & Users

| Method | Path | Versions | Operation IDs |
|---|---|---|---|
| `POST` | `/api/{ver}/auth/register` | v1, v2 | `register_api_{ver}_auth_register_post` |
| `POST` | `/api/{ver}/auth/login` | v1, v2 | `login_api_{ver}_auth_login_post` |
| `GET` | `/api/{ver}/users/me` | v1, v2 | `get_me_api_{ver}_users_me_get` |
| `GET` | `/api/{ver}/users` | v1, v2 | `get_users_api_{ver}_users_get` |

### Administration & Metrics

| Method | Path | Versions | Operation IDs | Description |
|---|---|---|---|---|
| `GET` | `/api/{ver}/admin/system-info` | v1, v2 | `get_admin_system_info_api_{ver}_admin_system_info_get` | Host OS, backend version, DB status |
| `GET` | `/api/{ver}/admin/logs` | v1, v2 | `get_tracing_logs_api_{ver}_admin_logs_get` | Redacted log stream (query param: `tail`, default 100) |
| `GET` | `/api/{ver}/dashboard/stats` | v1, v2 | `get_dashboard_stats_api_{ver}_dashboard_stats_get` | User counts, sessions, 24h call volumes |
| `GET` | `/api/{ver}/dashboard/realtime` | v1, v2 | `get_dashboard_realtime_api_{ver}_dashboard_realtime_get` | Latency series and HTTP status breakdowns |

### AI Services

Rate-limited endpoints for LLM interactions.

| Method | Path | Versions | Payload Schema | Operation IDs |
|---|---|---|---|---|
| `POST` | `/api/{ver}/ai/chat` | v1, v2 | `ChatRequest` | `chat_completion_api_{ver}_ai_chat_post` |
| `POST` | `/api/{ver}/ai/rag_chat` | v1, v2 | `RAGQueryRequest` | `rag_chat_completion_api_{ver}_ai_rag_chat_post` |
| `POST` | `/api/{ver}/ai/embeddings` | v1, v2 | `EmbeddingRequest` | `embeddings_api_{ver}_ai_embeddings_post` |

---

## Core Data Schemas

Defined in `openapi.json`:

```json
{
  "ChatRequest": {
    "required": ["messages", "model"],
    "properties": {
      "messages": { "type": "array", "items": { "type": "object" } },
      "model": { "type": "string" },
      "temperature": { "type": "number", "default": 0.7 },
      "max_tokens": { "type": "integer", "default": 1000 },
      "stream": { "type": "boolean", "default": false }
    }
  },
  "RAGQueryRequest": {
    "required": ["query", "model"],
    "properties": {
      "query": { "type": "string" },
      "model": { "type": "string" },
      "n_results": { "type": "integer", "default": 5 },
      "temperature": { "type": "number", "default": 0.7 },
      "max_tokens": { "type": "integer", "default": 1000 },
      "stream": { "type": "boolean", "default": false }
    }
  },
  "EmbeddingRequest": {
    "required": ["text", "model"],
    "properties": {
      "text": { "type": "string" },
      "model": { "type": "string" }
    }
  },
  "DashboardStats": {
    "required": ["total_users", "active_sessions", "api_calls_24h"],
    "properties": {
      "total_users": { "type": "integer" },
      "active_sessions": { "type": "integer" },
      "api_calls_24h": { "type": "integer" }
    }
  },
  "UserOut": {
    "required": ["id", "email"],
    "properties": {
      "id": { "type": "integer" },
      "email": { "type": "string" },
      "roles": { "type": "array", "items": { "type": "string" }, "default": [] }
    }
  }
}
```

---

## Static Assets & Maintenance

- `backend/site/api/index.html`: Landing page for API reference.
- `backend/site/api/openapi/index.html`: ReDoc container binding `openapi.json` to standalone UI renderer.
- `backend/site/openapi/openapi.json`: Target schema definition file.

Regenerate schema after router modifications:
```bash
python scripts/update_openapi.py
```