# API Routing & Versioning — openwiki

# API Routing & Versioning — openwiki

## Purpose

API Routing & Versioning module provides structured endpoint management with path-based versioning strategy. Enables backward compatibility, clear API evolution, and consistent request handling across versions.

## Architecture

### Versioning Strategy

Path-based versioning implemented via FastAPI routers:

```
/v1/* → APIVersion.V1
/v2/* → APIVersion.V2
```

### Core Components

**APIVersion Enum** (`backend/app/api/versioning.py`)
```python
class APIVersion(str, Enum):
    V1 = "v1"
    V2 = "v2"
```

**Router Registration**
```python
register_version(APIVersion.V1, v1_router)
register_version(APIVersion.V2, v2_router)
```

**Versioned Router Inclusion**
```python
api_router.include_router(
    get_router_for_version(APIVersion.V1), 
    prefix="/v1"
)
api_router.include_router(
    get_router_for_version(APIVersion.V2), 
    prefix="/v2"
)
```

## Key Endpoints

### Authentication
| Method | Path | Security |
|--------|------|----------|
| POST | `/v1/auth/login` | None |
| POST | `/v1/auth/logout` | JWT |
| GET | `/v1/me` | JWT |
| PUT | `/v1/me` | JWT |

### System Management
| Method | Path | Security |
|--------|------|----------|
| GET | `/v1/health` | None |
| GET | `/v1/system/config` | Admin JWT |
| PUT | `/v1/system/config` | Admin JWT |

### User Management
| Method | Path | Security |
|--------|------|----------|
| GET | `/v1/users` | Admin JWT |
| POST | `/v1/users` | Admin JWT |
| GET | `/v1/users/{id}` | Admin JWT |
| PUT | `/v1/users/{id}` | Admin JWT |
| DELETE | `/v1/users/{id}` | Admin JWT |

### AI & RAG
| Method | Path | Security |
|--------|------|----------|
| POST | `/v1/ai/chat` | JWT |
| POST | `/v1/ai/embeddings` | JWT |
| POST | `/v1/ai/ingest` | Admin JWT |

### Dashboard
| Method | Path | Security |
|--------|------|----------|
| GET | `/v1/dashboard/stats` | JWT |
| GET | `/v1/dashboard/usage` | Admin JWT |

## Integration Points

### Dependencies
- **FastAPI**: Router registration, dependency injection
- **OAuth2**: JWT token validation via `oauth2_scheme`
- **Database**: Session management via `get_db()` dependency

### Request Flow
1. Request arrives at versioned prefix (`/v1/*`)
2. Router dispatches to appropriate handler
3. Dependencies injected (auth, db session)
4. Handler processes request
5. Response returned with standardized format

## Design Patterns

### Dependency Injection
```python
async def get_current_user(token: str = Depends(oauth2_scheme)):
    # JWT validation
    return user

async def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### Error Handling
Standardized JSON responses:
```json
{
  "error": {
    "code": "AUTHENTICATION_FAILED",
    "message": "Invalid or expired token",
    "details": "Token expired at 2026-08-28T10:30:00Z"
  }
}
```

### Pagination
```json
{
  "data": [...],
  "pagination": {
    "limit": 10,
    "offset": 0,
    "total": 123,
    "next": "/v1/users?limit=10&offset=10"
  }
}
```

## Version Management

| Version | Status | Notes |
|---------|--------|-------|
| v1 | Active | Full feature set |
| v2 | Active | Streamlined endpoints |
| v3 | Planned | Future enhancements |

## Quality Assurance

- **Auto-generated docs**: `/docs` (Swagger UI), `/openapi.json`
- **Testing**: Unit + integration tests
- **Monitoring**: Latency, error rate, throughput tracking
- **SLOs**: P50/P95/P99 response times, 4xx/5xx error rates

## Evolution Policy

1. Backward compatibility maintained
2. 6-month deprecation period minimum
3. Clear migration guides provided
4. Version-specific behavior supported