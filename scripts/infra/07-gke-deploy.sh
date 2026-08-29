#!/bin/bash
# scripts/infra/07-gke-deploy.sh - Deploy to GKE with validation
set -euo pipefail

PROJECT_ID="${1:-}"
REPO_NAME="omnisight-repo"
LOCATION="asia-east1"
TAG="${TAG:-latest}"
REGISTRY="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}"
K8S_DIR="$(git rev-parse --show-toplevel)/kubernetes"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID>"
    exit 1
fi

echo "=== Deploying to GKE ==="

deploy_component() {
    local NAME=$1
    local YAML="${K8S_DIR}/${NAME}-deployment.yaml"
    local IMAGE="${REGISTRY}/${NAME}:${TAG}"

    if ! gcloud artifacts docker images describe "$IMAGE" --quiet &>/dev/null; then
        echo "Skipping ${NAME}: Image not found in registry."
        return 0
    fi

    echo "Deploying ${NAME}..."
    sed -i "s|gcr\.io/[^/]*/vue-python-demo-${NAME}:.*|${IMAGE}|g" "$YAML"
    kubectl apply -f "$YAML"
    kubectl rollout status "deployment/${NAME}" --timeout=120s
}

deploy_component "backend"
deploy_component "frontend"

echo "=== GKE Status ==="
kubectl get pods
kubectl get svc