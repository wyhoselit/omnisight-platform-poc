#!/bin/bash
# scripts/infra/iam-setup.sh - Set up IAM Service Account for POC deployment
# Usage: ./scripts/infra/05-iam-setup.sh <PROJECT_ID>
#
# Variables:
#   PROJECT_ID:   Must match the GCP project created in 01-gcp-setup.sh.
#   SA_NAME:      Hardcoded to "omnisight-deployer" (Service Account name).
#   SA_EMAIL:     Auto-derived: omnisight-deployer@<PROJECT_ID>.iam.gserviceaccount.com

set -euo pipefail

PROJECT_ID="${1:-}"
SA_NAME="omnisight-deployer"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID>"
    exit 1
fi

echo "=== Setting up IAM Service Account ==="

gcloud config set project "$PROJECT_ID"

# 1. Create Service Account
if gcloud iam service-accounts describe "$SA_EMAIL" &>/dev/null; then
    echo "Service Account ${SA_EMAIL} already exists."
else
    echo "Creating Service Account ${SA_NAME}..."
    gcloud iam service-accounts create "$SA_NAME" \
        --display-name="Omnisight Deployer POC" \
        --quiet
fi

# 2. Assign Roles
ROLES=(
    "roles/artifactregistry.writer"
    "roles/run.admin"
    "roles/container.admin"
    "roles/iam.serviceAccountUser"
)

for role in "${ROLES[@]}"; do
    echo "Adding role ${role}..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:${SA_EMAIL}" \
        --role="$role" \
        --quiet &>/dev/null
done

echo "=== Done ==="
echo "Service Account: ${SA_EMAIL}"