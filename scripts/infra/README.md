# Omnisight Platform POC Infrastructure

Infrastructure scripts to deploy a FastAPI stub to Google Cloud Platform (Cloud Run and GKE Autopilot).

## Requirements

1. **Google Cloud SDK (`gcloud`)**: [Install Link](https://cloud.google.com/sdk/docs/install)
2. **google-cloud-cli-gke-gcloud-auth-plugin**: [Install Link](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
3. **Kubectl**: [Install Link](https://kubernetes.io/docs/tasks/tools/)
4. **Docker**: Required for local builds (though scripts use Cloud Build by default).

### Login & Setup
```bash
gcloud auth login
gcloud auth application-default login
```

## Quick Start (All-in-One)

Run the master script to execute all steps in sequence:

```bash
# 1. Get your Billing Account ID
gcloud billing accounts list

# 2. Run setup
export PROJECT_ID="omnisight-poc-$(date +%s | cut -c9-12)"
export BILLING_ACCOUNT="0X0X0X-0X0X0X-0X0X0X"

./scripts/infra/00-setup-all.sh $PROJECT_ID $BILLING_ACCOUNT
```

## Scripts Overview

| File | Purpose |
|------|---------|
| `00-setup-all.sh` | Orchestrates all scripts in order, runs verification at end. |
| `01-gcp-setup.sh` | Creates project, enables APIs (AR, Run, GKE, IAM), sets default region. |
| `02-artifact-registry.sh` | Creates a Docker repository named `omnisight-repo` in `asia-east1`. |
| `03-iam-setup.sh` | Creates `omnisight-deployer` Service Account with necessary roles. |
| `04-gke-setup.sh` | Provisions a GKE Autopilot cluster and configures `kubectl`. |
| `05-build-push.sh` | Creates FastAPI/frontend stubs and pushes to Artifact Registry. |
| `06-cloud-run-deploy.sh` | Deploys the image to a public Cloud Run service. |
| `07-gke-deploy.sh` | Patches image paths and deploys to GKE (skips missing images). |
| `08-verify.sh` | Verifies Cloud Run + GKE deployments, checks health endpoints. |

## Variables

All scripts accept `PROJECT_ID` as the first argument. Other variables can be overridden via environment:

- `REGION`: Default `asia-east1`.
- `TAG`: Default `latest`. Set via: `export TAG=v1.0`
- `REPO_NAME`: Default `omnisight-repo`.
- `TARGET` (for `05-build-push.sh`): `backend`, `frontend`, or `all`.

## Usage Examples

### Full Deployment
```bash
./scripts/infra/00-setup-all.sh my-project-id my-billing-account all
```

### Build Only Frontend
```bash
./scripts/infra/05-build-push.sh my-project-id frontend
```

### Verify Deployment
```bash
./scripts/infra/08-verify.sh my-project-id
```

## Endpoints

After successful deployment:

| Service | Endpoint |
|---------|----------|
| Cloud Run | `https://<PROJECT_ID>-backend-xxxxx-asia-east1.run.app/health` → `{"status":"ok"}` |
| GKE Backend | ClusterIP (port 80), health at `/health` via pod exec |
| GKE Frontend | LoadBalancer IP (provisional), UI at `/` |

## Clean Up

```bash
# Delete everything (CR + GKE + AR + IAM)
gcloud projects delete my-project-id
```