#!/bin/bash
# scripts/infra/gcp-setup.sh - Create GCP project and enable required APIs for POC
# Usage: ./scripts/infra/01-gcp-setup.sh <PROJECT_ID>
#
# Variables:
#   PROJECT_ID:      Choose a globally unique ID (e.g. omnisight-poc-12345).
#   BILLING_ACCOUNT: Run `gcloud billing accounts list` to get yours (format: 0X0X0X-0X0X0X-0X0X0X).
#                    Set as env var: export BILLING_ACCOUNT=0X0X0X-0X0X0X-0X0X0X
#
# Requires: gcloud

set -euo pipefail

PROJECT_ID="${1:-}"
BILLING_ACCOUNT="${BILLING_ACCOUNT:-}"
REGION="asia-east1"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID> [BILLING_ACCOUNT]"
    echo "  PROJECT_ID       GCP project ID (e.g. omnisight-poc-8888)"
    echo "  BILLING_ACCOUNT  Optional; if omitted, billing must already be linked"
    exit 1
fi

if [[ -n "${BILLING_ACCOUNT}" ]]; then
    BILLING_ARG="--billing-account=${BILLING_ACCOUNT}"
else
    BILLING_ARG=""
fi

echo "=== GCP Setup for ${PROJECT_ID} ==="

# 1. Create project
if gcloud projects describe "$PROJECT_ID" &>/dev/null; then
    echo "Project ${PROJECT_ID} already exists."
else
    echo "Creating project ${PROJECT_ID}..."
    gcloud projects create "$PROJECT_ID" --name="Omnisight POC"
    echo "Project creation submitted."
fi

# 2. Set default project
gcloud config set project "$PROJECT_ID"

# 3. Link billing
if [[ -n "$BILLING_ACCOUNT" ]]; then
    echo "Linking billing account ${BILLING_ACCOUNT}..."
    gcloud billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT"
fi

# 4. Enable required APIs
APIS=(
    "artifactregistry.googleapis.com"
    "run.googleapis.com"
    "container.googleapis.com"
    "cloudbuild.googleapis.com"
    "iam.googleapis.com"
)
for api in "${APIS[@]}"; do
    echo "Enabling ${api}..."
    gcloud services enable "$api" --quiet
done

# 5. Set default region
gcloud config set compute/region "$REGION"

echo "=== Done ==="
echo "Project: ${PROJECT_ID}"
echo "Region:  ${REGION}"
