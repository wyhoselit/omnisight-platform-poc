#!/bin/bash
# scripts/infra/05-build-push.sh - Build FastAPI stub and frontend stub, push to Artifact Registry
# Usage: ./scripts/infra/05-build-push.sh <PROJECT_ID> [backend|frontend|all]

set -euo pipefail

PROJECT_ID="${1:-}"
REPO_NAME="omnisight-repo"
LOCATION="asia-east1"
TAG="${TAG:-latest}"
TARGET="${2:-all}"

if [[ -z "$PROJECT_ID" ]]; then
    echo "Usage: $0 <PROJECT_ID> [backend|frontend|all]"
    exit 1
fi

case "$TARGET" in
    backend|frontend|all) ;;
    *)
        echo "Invalid target: $TARGET (expected backend, frontend, or all)"
        exit 1
        ;;
esac

gcloud config set project "$PROJECT_ID" >/dev/null
gcloud auth configure-docker "${LOCATION}-docker.pkg.dev" --quiet

build_backend() {
    IMAGE_URI="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/backend:${TAG}"
    echo "=== Building backend ==="
    echo "Image: ${IMAGE_URI}"

    mkdir -p backend
    if [[ ! -f "backend/main.py" ]]; then
        cat > backend/main.py <<'EOF'
from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}
EOF
    fi

    if [[ ! -f "backend/Dockerfile" ]]; then
        cat > backend/Dockerfile <<'EOF'
FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn
COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
    fi

    gcloud builds submit backend/ --tag="$IMAGE_URI" --quiet
    echo "Pushed: ${IMAGE_URI}"
}

build_frontend() {
    IMAGE_URI="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/frontend:${TAG}"
    echo "=== Building frontend ==="
    echo "Image: ${IMAGE_URI}"

    mkdir -p frontend
    if [[ ! -f "frontend/index.html" ]]; then
        cat > frontend/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Omnisight POC</title></head>
<body>
  <h1>Omnisight POC Frontend</h1>
  <p>Status: <span id="status">checking...</span></p>
  <script>
    fetch('/health').then(r => r.json()).then(d => {
      document.getElementById('status').innerText = d.status;
    }).catch(e => {
      document.getElementById('status').innerText = 'unreachable';
    });
  </script>
</body>
</html>
EOF
    fi

    if [[ ! -f "frontend/Dockerfile" ]]; then
        cat > frontend/Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
    fi

    if [[ ! -f "frontend/nginx.conf" ]]; then
        cat > frontend/nginx.conf <<'EOF'
server {
  listen 80;
  location / {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;
  }
  location /health {
    return 200 'ok\n';
    add_header Content-Type text/plain;
  }
}
EOF
    fi

    gcloud builds submit frontend/ --tag="$IMAGE_URI" --quiet
    echo "Pushed: ${IMAGE_URI}"
}

[[ "$TARGET" == "backend" || "$TARGET" == "all" ]] && build_backend
[[ "$TARGET" == "frontend" || "$TARGET" == "all" ]] && build_frontend

echo "=== Build & push complete ==="