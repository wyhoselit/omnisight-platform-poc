#!/bin/bash
# scripts/infra/00-setup-all.sh - Run all infra scripts in order

set -euo pipefail

PROJECT_ID="${1:-}"
BILLING_ACCOUNT="${2:-${BILLING_ACCOUNT:-}}"
INFRA_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${3:-all}"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID> [BILLING_ACCOUNT] [backend|frontend|all]"
    echo "  PROJECT_ID:      Unique GCP project ID"
    echo "  BILLING_ACCOUNT: From 'gcloud billing accounts list'"
    echo "  TARGET:          Build/push target (backend, frontend, or all)"
    exit 1
fi

echo "=== FULL POC INFRA SETUP ==="
echo "Project: ${PROJECT_ID}"
echo "Target:  ${TARGET}"
echo ""

"${INFRA_DIR}/01-gcp-setup.sh" "$PROJECT_ID" "$BILLING_ACCOUNT"
"${INFRA_DIR}/02-artifact-registry.sh" "$PROJECT_ID"
"${INFRA_DIR}/03-iam-setup.sh" "$PROJECT_ID"
"${INFRA_DIR}/04-gke-setup.sh" "$PROJECT_ID"
"${INFRA_DIR}/05-build-push.sh" "$PROJECT_ID" "$TARGET"
"${INFRA_DIR}/06-cloud-run-deploy.sh" "$PROJECT_ID"
"${INFRA_DIR}/07-gke-deploy.sh" "$PROJECT_ID"
"${INFRA_DIR}/08-verify.sh" "$PROJECT_ID"

echo ""
echo "=== RUNNING VERIFICATION ==="
"${INFRA_DIR}/08-verify.sh" "$PROJECT_ID"