---
type: Documentation
title: Observability Overview
description: Comprehensive documentation for the application's observability stack, including OpenTelemetry, metrics, tracing, logging, SLO-based alerting, and Grafana dashboards for both frontend and backend.
tags: [observability, opentelemetry, metrics, tracing, logging, grafana, prometheus, loki, tempo, frontend, backend, slo, alerting]
---

# Observability Overview

This application is instrumented with a robust observability stack using OpenTelemetry to provide insights into its behavior, performance, and health. This includes metrics, distributed tracing, centralized logging, and SLO-based alerting, visualized through Grafana.

## Key Components

The observability stack consists of the following tools, orchestrated via Docker Compose:

-   **OpenTelemetry Collector**: Receives, processes, and exports telemetry data from the application.
    -   Configuration: `dockerdata/observability/otel-collector/collector-config.yml`
-   **Prometheus**: Time-series database for storing and querying metrics.
    -   Configuration: `dockerdata/observability/prometheus/prometheus.yml`
    -   **Alert Rules**: `dockerdata/observability/prometheus/alerts.yml`
    -   **SLO Alert Rules**: `dockerdata/observability/prometheus/slo-alert.rules`
    -   **Alertmanager**: `dockerdata/observability/prometheus/alertmanager.yml`
-   **Loki**: Log aggregation system for centralized logging.
    -   Configuration: `dockerdata/observability/loki/loki-config.yml`
-   **Tempo**: High-volume, distributed tracing backend.
    -   Configuration: `dockerdata/observability/tempo/tempo-config.yml`
-   **Grafana**: Data visualization and dashboarding platform.
    -   Configuration: `dockerdata/observability/grafana/provisioning/` (dashboards and datasources)
-   **Nginx Prometheus Exporter**: Scrapes Nginx stub_status for proxy-level metrics.

## Frontend Observability

The frontend application uses OpenTelemetry to capture performance and user interaction metrics.

-   **Instrumentation**: `frontend/src/modules/core/observability.ts`
-   **Metrics Definition**: `frontend/src/modules/core/metrics/metrics.ts`
-   **Component Render Metrics**: `frontend/src/modules/core/metrics/useComponentRenderMetrics.ts`
-   **User Interaction Metrics**: `frontend/src/modules/core/metrics/useMetrics.ts`
-   **Grafana Dashboard**: `dockerdata/observability/grafana/provisioning/dashboards/frontend-observability.json`
-   **E2E Tests**: `frontend/cypress/e2e/observability.cy.ts`

## Backend Observability

The FastAPI backend is instrumented with OpenTelemetry for tracing, metrics, and structured logging.

-   **Instrumentation**: `backend/app/modules/core/observability.py`
-   **Logging**: `backend/app/modules/core/logging.py` (integrates with OpenTelemetry for trace context)
-   **Grafana Dashboards**:
    -   `dockerdata/observability/grafana/provisioning/dashboards/backend-observability.json`
    -   `dockerdata/observability/grafana/provisioning/dashboards/Overall-observability.json`
    -   `dockerdata/observability/grafana/provisioning/dashboards/nginx-observability.json`

## Metrics Reference

All collected metrics are documented in [docs/metrics-reference.md](/repos/omnisight-platform-poc/docs/metrics-reference.md), including:

- **Backend HTTP Server Metrics**: `http_server_duration_milliseconds`, `http_server_active_requests`, `http_server_request`, `http_server_response`
- **Frontend User Interaction Metrics**: Page views, button clicks, form submissions, component render duration
- **Alert Rules**: SLO-based alerts for latency (P95 > 200ms), error rate (> 5%), active requests, service down, and frontend-specific alerts

## SLO-Based Alerting

The system defines Service Level Objectives (SLOs) with corresponding Prometheus alert rules:

- **Availability SLO**: > 99.9% uptime (`ServiceDown` alert)
- **Latency SLO**: P95 < 200ms (`HighBackendLatency` alert)
- **Error Rate SLO**: < 5% (`HighErrorRate` alert)
- **Frontend SLOs**: Component render P95 < 500ms, page view activity, API latency

Alerts are managed by Alertmanager and can be viewed in Grafana.

## Verifying Observability

To verify the observability setup:

1.  Ensure all Docker services are running: `docker compose up`
2.  Access Grafana at `http://localhost:3000` (default credentials `admin`/`admin`).
3.  Explore the provisioned dashboards (Frontend Observability, Backend Observability, Overall Observability, Nginx Observability) to see metrics, logs, and traces.
4.  Run frontend E2E tests:
    ```bash
    cd frontend
    npm install # if not already installed
    npx cypress run --browser chrome --spec "cypress/e2e/observability.cy.ts"
    ```
    This will generate traffic and metrics visible in Grafana.
5.  Refer to `docs/telemetry-verification.md` for detailed verification steps and expected outputs.
6.  Check Prometheus alerts: `http://localhost:9090/alerts`
7.  Check Alertmanager: `http://localhost:9093`

## Architecture Decision

The observability stack implementation follows the specification in [OBSERVABILITY_SPEC.md](/repos/omnisight-platform-poc/OBSERVABILITY_SPEC.md), which defines the problem statement, user stories, implementation decisions, and testing strategy for the full observability stack.
