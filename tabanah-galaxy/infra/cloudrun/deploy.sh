#!/usr/bin/env bash
set -euo pipefail

# === Editable Variables ===
PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
REGION="${REGION:-YOUR_REGION}"
REPO="tabanah"
CONN_NAME="${CONN_NAME:-YOUR_PROJECT_ID:YOUR_REGION:tabanah-db}"

BACKEND_IMG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/backend:galaxy"
FRONTEND_IMG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/frontend:galaxy"

# === Build & Push ===
gcloud auth configure-docker ${REGION}-docker.pkg.dev -q

docker build -t "$BACKEND_IMG" ../../backend
docker push "$BACKEND_IMG"

docker build -t "$FRONTEND_IMG" ../../frontend
docker push "$FRONTEND_IMG"

# === Deploy Backend ===
gcloud run deploy tabanah-backend   --image="$BACKEND_IMG"   --region="$REGION"   --add-cloudsql-instances="$CONN_NAME"   --set-secrets=DATABASE_URL=tabanah-backend-env:latest,JWT_SECRET=tabanah-backend-env:latest   --port=8080   --allow-unauthenticated

# === Deploy Frontend ===
gcloud run deploy tabanah-frontend   --image="$FRONTEND_IMG"   --region="$REGION"   --set-secrets=VITE_API_BASE=tabanah-frontend-env:latest   --port=4173   --allow-unauthenticated

echo "Done."
