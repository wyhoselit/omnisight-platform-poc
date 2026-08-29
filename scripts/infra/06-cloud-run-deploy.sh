#!/bin/bash
# scripts/infra/cloud-run-deploy.sh - Deploy FastAPI image to Cloud Run
# Usage: ./scripts/infra/04-cloud-run-deploy.sh <PROJECT_ID>
#
# Variables:
#   PROJECT_ID:   Must match the GCP project created in 01-gcp-setup.sh.
#   REPO_NAME:    Hardcoded to "omnisight-repo" (must match 02-artifact-registry.sh).
#   LOCATION:     Hardcoded to "asia-east1" (must match 02-artifact-registry.sh).
#   SERVICE:      Hardcoded to "backend" (Cloud Run service name).
#   IMAGE:        Hardcoded to "backend" (must match image pushed in 03-build-push.sh).
#   TAG:          Optional; defaults to "latest". Set via: export TAG=v1.0

set -euo pipefail

PROJECT_ID="${1:-}"
REPO_NAME="omnisight-repo"
LOCATION="asia-east1"
SERVICE="backend"
IMAGE="${IMAGE:-backend}"
TAG="${TAG:-latest}"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID> [IMAGE] [TAG]"
    exit 1
fi

IMAGE_URI="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE}:${TAG}"

echo "=== Deploying to Cloud Run ==="
echo "Service: ${SERVICE}"
echo "Image:   ${IMAGE_URI}"

gcloud config set project "$PROJECT_ID"

gcloud run deploy "$SERVICE" \
    --memory 2Gi \
    --image="$IMAGE_URI" \
    --region="$LOCATION" \
    --platform="managed" \
    --allow-unauthenticated \
    --port=8000 \
    --quiet

echo "=== Done ==="
echo "URL: $(gcloud run services describe "$SERVICE" --region="$LOCATION" --format='value(status.url)')"

