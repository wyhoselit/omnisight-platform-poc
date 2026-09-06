# Observability & Tracing — app

# Observability & Tracing Module

## Purpose

Provides OpenTelemetry integration for distributed tracing, metrics, and structured logging. Gracefully degrades when OTEL Collector is unreachable.

## Key Components

### `setup_observability(app: FastAPI, engine=None)`

Main entry point. Configures:
- **TracerProvider**: Distributed tracing with OTLP exporter
- **MeterProvider**: Metrics collection with periodic export
- **LoggerProvider**: Structured JSON logging with trace context
- **Instrumentations**: FastAPI, HTTPX, SQLAlchemy, system metrics

**Flow**:
1. Check OTEL Collector availability via TCP socket
2. If available: configure full OTLP pipeline with all providers
3. If unavailable: configure metrics-only, skip tracing/logging
4. Apply instrumentations regardless of collector status

### `is_otel_collector_available(endpoint, timeout=1.0) -> bool`

TCP connectivity check to OTEL Collector gRPC endpoint. Parses URL, attempts socket connection.

### `traced(name: str = None)`

Decorator for manual function tracing. Wraps sync/async functions with OpenTelemetry spans. Sets `function` attribute on span.

```python
@traced()
async def my_function():
    ...
```

### `tracer`

Module-level tracer instance from `trace.get_tracer(__name__)`.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FastAPI Application                       │
└─────────────────────┬─────────────────────────────────────────┘
                      │
┌─────────────────────▼─────────────────────────────────────────┐
│              setup_observability()                             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  OTEL Collector Available?                               │  │
│  │  Yes: Full pipeline (traces/metrics/logs)               │  │
│  │  No:  Metrics only                                     │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────┬─────────────────────────────────────────┘
                      │
┌─────────────────────▼─────────────────────────────────────────┐
│                 Instrumentations                               │
│  • FastAPIInstrumentor (HTTP tracing)                        │
│  • HTTPXClientInstrumentor (outbound HTTP)                   │
│  • SQLAlchemyInstrumentor (DB queries)                       │
│  • SystemMetricsInstrumentor (CPU/memory)                    │
└─────────────────────────────────────────────────────────────┘
```

## Integration Points

### Application Bootstrap

```python
# backend/app/main.py
from app.modules.core.observability import setup_observability

def create_app():
    app = FastAPI()
    setup_observability(app, engine=db_engine)
    return app
```

### Manual Tracing

```python
from app.modules.core.observability import traced

@traced("custom-operation-name")
async def business_logic():
    ...
```

### Function Execution Tracing

```python
# backend/app/modules/core/tracing.py
from app.modules.core.tracing import trace_execution

@trace_execution
async def slow_operation():
    ...
```

Records duration to `trace_entries` table when `TraceConfiguration.enabled=True` for "admin" service.

## Configuration

Settings from `app.modules.core.config`:
- `OTEL_COLLECTOR_ENDPOINT`: gRPC endpoint (default: `http://localhost:4317`)
- `OTEL_COLLECTOR_HTTP_ENDPOINT`: HTTP endpoint for connectivity check
- `SERVICE_NAME`: Service identifier in OTEL

## Test Coverage

- `test_observability.py`: Validates span export via mocked OTLP exporters
- `test_tracing.py`: Tests `trace_execution` decorator with database persistence