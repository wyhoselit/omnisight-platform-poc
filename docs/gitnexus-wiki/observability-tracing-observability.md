# Observability & Tracing — observability

# Observability & Tracing — observability module

## Overview
- Centralizes metrics, traces, logs for all services.
- Provides Grafana dashboards and alerting for health, performance, errors.

## Architecture
- Services emit OpenTelemetry data.
- OTel collector receives → processes → forwards:
  - Traces → Tempo
  - Logs → Loki
  - Metrics → Prometheus
- Prometheus scrapes collector metrics and service metrics.
- Tempo stores traces, Loki stores logs.
- Grafana queries datasources (Prometheus, Tempo, Loki) to render dashboards.
- Alertmanager evaluates Prometheus alert rules, sends notifications.

## Key components
- **Grafana dashboards** (`dockerdata/observability/grafana/provisioning/dashboards/*.json`):
  - Overall, Backend, Frontend, Nginx.
- **Provisioning** (`dashboards.yml`, `datasources.yml`).
- **Loki** (`loki-config.yml`).
- **OTel collector** (`otel-collector/collector-config.yml`).
- **Tempo** (`tempo-config.yml`).
- **Prometheus** (`prometheus.yml`, `alerts.yml`, `alert.rules`, `slo-alert.rules`).
- **Alertmanager** (`alertmanager.yml`).
- **Test sender** (`otel-collector/test-sender.sh`).

## Data flow diagram
```mermaid
flowchart TD
    A[Service (metrics/traces/logs)] --> B[OTel Collector]
    B --> C[Tempo]
    B --> D[Loki]
    B --> E[Prometheus]
    C --> F[Grafana (traces)]
    D --> G[Grafana (logs)]
    E --> H[Grafana (metrics)]
    H --> I[Alertmanager]
    I --> J[Notification channels]
```

## Dashboards
- **Overall**: request rate, error rate, traces, logs.
- **Backend**: availability, request rate, latency, traces, logs.
- **Frontend**: page views, latency, button clicks, form submits, traces, logs.
- **Nginx**: connections, request rate.

## Alerting
- Prometheus alert rules (`alerts.yml`, `alert.rules`, `slo-alert.rules`).
- Alertmanager routes to telegram-webhook, pagerduty.
- Alerts cover:
  - High error rate
  - Service down
  - High backend latency
  - Too many active backend requests
  - Slow component render
  - Page view drop
  - High frontend client latency
  - No login button clicks
  - Nginx down
  - High active connections
  - High request rate
  - Availability burn rate (SLO)

## Configuration
- Grafana provisioning mounts dashboards and datasources.
- Loki, Tempo, Prometheus configs define storage and retention.
- OTel collector defines pipelines and exporters.

## Integration points
- New service adds OpenTelemetry instrumentation.
- Metrics appear in Prometheus scrape.
- Traces flow to Tempo via OTel collector.
- Logs flow to Loki.
- Grafana dashboards automatically include new time series.

## Maintenance
- Update dashboard JSON to add panels.
- Adjust Prometheus queries in dashboards.
- Modify alert rules in `alerts.yml`.
- Rotate logs/storage per backend configs.
- Test OTel sender script for trace ingestion.