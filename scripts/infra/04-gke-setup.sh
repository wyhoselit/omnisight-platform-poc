#!/bin/bash
# scripts/infra/gke-setup.sh - Create GKE Autopilot cluster
# Usage: ./scripts/infra/06-gke-setup.sh <PROJECT_ID>
#
# Variables:
#   PROJECT_ID:    Must match the GCP project created in 01-gcp-setup.sh.
#   CLUSTER_NAME:  Hardcoded to "omnisight-cluster".
#   LOCATION:      Hardcoded to "asia-east1" (Autopilot regional cluster).

set -euo pipefail

PROJECT_ID="${1:-}"
CLUSTER_NAME="omnisight-cluster"
LOCATION="asia-east1"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID>"
    exit 1
fi

echo "=== Creating GKE Autopilot cluster ==="

gcloud config set project "$PROJECT_ID"

# Check if cluster exists
if gcloud container clusters describe "$CLUSTER_NAME" --region="$LOCATION" &>/dev/null; then
    echo "Cluster ${CLUSTER_NAME} already exists."
else
    echo "Creating Autopilot cluster ${CLUSTER_NAME} in ${LOCATION}..."
    gcloud container clusters create-auto "$CLUSTER_NAME" \
        --region="$LOCATION" \
        --quiet
fi

# Get credentials
echo "Fetching cluster credentials..."
gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --region="$LOCATION"

echo "=== Done ==="
echo "Cluster: ${CLUSTER_NAME}"
echo "Region:  ${LOCATION}"
kubectl cluster-info