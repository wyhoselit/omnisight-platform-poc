# Observability & Tracing — specs



# Observability & Tracing — specs

## Architecture
```mermaid
graph LR
    Backend__FastAPI["Backend((FastAPI))"] --> OTelCollector__OTel["OTelCollector((OTel"] Collector))
    Frontend__Vue_js["Frontend((Vue.js))"] --> OTelCollector
    OTelCollector --> Prometheus__Prometheus["Prometheus((Prometheus))"]
    OTelCollector --> Jaeger__Jaeger["Jaeger((Jaeger))"]
    OTelCollector --> Loki__Loki["Loki((Loki))"]
    Prometheus --> Grafana__Grafana["Grafana((Grafana))"]
    Jaeger --> Grafana
    Loki --> Grafana
```

## Backend instrumentation
- FastAPI app instrumented with OpenTelemetry Python SDK
- Traces, logs exported via OTLP to Collector
- Metrics exposed through Prometheus exporter endpoint
- Key files: `backend/app/main.py`, `backend/app/observability.py`

## Frontend instrumentation
- Vue.js app instrumented with OpenTelemetry JavaScript SDK
- Traces, metrics, logs exported via OTLP to Collector
- Key files: `frontend/src/main.ts`, `frontend/src/observability.ts`

## Collector configuration
- `collector-config.yaml` defines OTLP receiver
- Exporters: Prometheus, Jaeger, Loki
- Collector routes data to appropriate backends

## Monitoring stack integration
- Prometheus scrapes metrics from Collector (optionally from FastAPI exporter)
- Grafana visualizes metrics, logs, traces
- Jaeger/Tempo provides distributed tracing
- Loki aggregates logs

## Deployment
- Docker Compose orchestrates services: backend, frontend, otel-collector, prometheus, grafana, jaeger, loki
- Core definitions in `docker-compose.yml`
- Development overrides in `docker-compose.override.yml`

## Testing
- Verify telemetry emission from backend endpoints
- Verify telemetry emission from frontend interactions
- End-to-end tests confirm data flow to Collector and backends
- Extend pytest, Vitest, Cypress with telemetry assertions

## Out of scope
- Zero-code instrumentation
- Advanced process instrumentation
- Specific route management instrumentation
- Deep Pinia/Vuex integration
- Automatic Grafana dashboard generation
- Long-term storage cost optimization
- Alerting rule configuration

## Further notes
- Collector decouples applications from backend tools
- Docker Compose provides reproducible environment