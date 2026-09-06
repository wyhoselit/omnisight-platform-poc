#!/bin/bash
# scripts/infra/08-verify.sh - Verify POC deployment health
# Usage: ./scripts/infra/08-verify.sh <PROJECT_ID>

set -euo pipefail

PROJECT_ID="${1:-}"
LOCATION="asia-east1"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID>"
    exit 1
fi

echo "=== VERIFYING OMNISIGHT PLATFORM POC ==="

# 1. Cloud Run
echo ""
echo "--- Checking Cloud Run ---"
CR_URL=$(gcloud run services describe backend --region="$LOCATION" --project="$PROJECT_ID" --format='value(status.url)' 2>/dev/null || echo "")

if [[ -n "$CR_URL" ]]; then
    echo "Service URL: ${CR_URL}"
    echo "Checking health endpoint..."
    curl -sfL "${CR_URL}/health" || echo "FAILED"
else
    echo "Cloud Run service not found."
fi

# 2. GKE
echo ""
echo "--- Checking GKE ---"
CLUSTER_NAME="omnisight-cluster"
if gcloud container clusters describe "$CLUSTER_NAME" --region="$LOCATION" --project="$PROJECT_ID" &>/dev/null; then
    gcloud container clusters get-credentials "$CLUSTER_NAME" --region="$LOCATION" --project="$PROJECT_ID" --quiet

    echo ""
    echo "Pods status:"
    kubectl get pods -o wide

    echo ""
    echo "Services status (External IPs):"
    kubectl get svc -o wide

    echo ""
    echo "Endpoint Checks:"
    # Check backend via ClusterIP (from inside cluster or port-forward if not public)
    # Since backend service is ClusterIP, we check pod readiness.
    BACKEND_READY=$(kubectl get deployment backend -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    if [[ "$BACKEND_READY" -gt 0 ]]; then
        echo "Backend pods are READY."
    else
        echo "Backend pods are NOT ready."
    fi

    # Frontend Service is LoadBalancer
    FRONTEND_IP=$(kubectl get svc frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [[ -n "$FRONTEND_IP" ]]; then
        echo "Frontend IP: ${FRONTEND_IP}"
        echo "Curling Frontend..."
        curl -I -m 5 "http://${FRONTEND_IP}" || echo "Connection failed (normal if LB is still provisioning)"
    else
        echo "Frontend LoadBalancer IP not assigned yet."
    fi
else
    echo "GKE cluster not found."
fi
