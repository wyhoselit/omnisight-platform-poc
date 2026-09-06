# Observability & Tracing — todo

`fix_grafana_dashboard.sh` → skipped: dashboard auto-rebuild, add when Grafana API exists.  

This script dumps raw observability data to debug misconfigured metrics/logs. It does not fix dashboards. It never did.  

### Purpose  
Diagnose why Grafana panels show no data. Checks:  
- Prometheus metrics and targets  
- Loki log labels and sample queries  
- OTel collector metrics endpoint  
- Backend `/metrics` exposure  

### How It Works  
1. Queries Prometheus, Loki, OTel collector, and app `/metrics` endpoints  
2. Extracts label values (`job`, `exporter`, `level`)  
3. Samples recent logs and metrics  
4. Saves all output to `metrics-and-labels.txt`  

### Key Components  
- **Prometheus** (`localhost:9090`) → checks `up`, metric names, scrape health  
- **Loki** (`localhost:3100`) → lists labels, queries last hour of logs  
- **OTel collector** (`localhost:8889`) → dumps raw OpenTelemetry metrics  
- **App backend** (`localhost:8000`) → verifies `/metrics` is reachable  

### Output  
`metrics-and-labels.txt` contains:  
- Top 40 Prometheus metric names  
- Active scrape targets + errors  
- Loki label values (`job`, `exporter`, `level`)  
- 5 recent log entries  
- First 30 lines of OTel metrics  
- First 40 lines of app `/metrics`  
- OTel collector config (`collector-config.yml`)  

### Connection to Codebase  
No code calls this. It’s a manual debug tool. Used when:  
- Grafana shows “no data”  
- Logs don’t appear in Loki  
- Metrics missing from Prometheus  

### Why Not Auto-Fix?  
Grafana dashboards are JSON files. This script doesn’t touch them.  
Fix dashboards manually:  
1. Open Grafana → Dashboard → Edit  
2. Verify data source = Prometheus/Loki  
3. Match label selectors to what `curl` returned  

`ponytail:` Add Grafana API calls when dashboard templating breaks. Until then: copy-paste labels from `metrics-and-labels.txt` into query editors.