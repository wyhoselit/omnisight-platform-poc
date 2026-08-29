#!/bin/bash
# scripts/infra/artifact-registry.sh - Create Artifact Registry repository for POC
# Usage: ./scripts/infra/02-artifact-registry.sh <PROJECT_ID>
#
# Variables:
#   PROJECT_ID:  Must match the GCP project created in 01-gcp-setup.sh.
#   REPO_NAME:   Hardcoded to "omnisight-repo" (can change via env var).
#   LOCATION:    Hardcoded to "asia-east1" (can change via env var).

set -euo pipefail

PROJECT_ID="${1:-}"
REPO_NAME="omnisight-repo"
LOCATION="asia-east1"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID>"
    exit 1
fi

echo "=== Creating Artifact Registry repository ==="

gcloud config set project "$PROJECT_ID"

# Check if repository exists
if gcloud artifacts repositories describe "$REPO_NAME" --location="$LOCATION" --quiet 2>/dev/null; then
    echo "Repository ${REPO_NAME} already exists in ${LOCATION}."
else
    echo "Creating ${REPO_NAME} in ${LOCATION}..."
    gcloud artifacts repositories create "$REPO_NAME" \
        --repository-format=docker \
        --location="$LOCATION" \
        --description="Omnisight POC Artifact Registry" \
        --quiet
fi

echo "=== Done ==="
echo "Repository URI: ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}"