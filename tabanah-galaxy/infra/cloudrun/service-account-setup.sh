#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
REGION="${REGION:-YOUR_REGION}"
SVC="${SVC:-tabanah-deployer}"

gcloud iam service-accounts create "$SVC" --display-name="Tabanah Deployer" || true

gcloud projects add-iam-policy-binding "$PROJECT_ID"   --member="serviceAccount:${SVC}@${PROJECT_ID}.iam.gserviceaccount.com"   --role="roles/run.admin"

gcloud projects add-iam-policy-binding "$PROJECT_ID"   --member="serviceAccount:${SVC}@${PROJECT_ID}.iam.gserviceaccount.com"   --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding "$PROJECT_ID"   --member="serviceAccount:${SVC}@${PROJECT_ID}.iam.gserviceaccount.com"   --role="roles/secretmanager.admin"

gcloud projects add-iam-policy-binding "$PROJECT_ID"   --member="serviceAccount:${SVC}@${PROJECT_ID}.iam.gserviceaccount.com"   --role="roles/cloudsql.client"

echo "Service account and roles configured."
