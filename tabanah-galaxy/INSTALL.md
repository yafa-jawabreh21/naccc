# INSTALL — نشر التبانه (Galaxy) على Google Cloud

> هذه التعليمات مكثّفة وخالية من الحكي الزائد. نفّذها بالترتيب:

## 0) متطلبات
- حساب Google Cloud مفعل عليه الفوترة.
- تثبيت gcloud SDK.
- Docker أو Cloud Build.
- Project ID جاهز، واختيار Region مثل: `asia-south1` أو `europe-west1`.

## 1) إعداد المشروع
```bash
gcloud init
gcloud config set project YOUR_PROJECT_ID
gcloud config set run/region YOUR_REGION
gcloud services enable run.googleapis.com sqladmin.googleapis.com secretmanager.googleapis.com artifactregistry.googleapis.com compute.googleapis.com
```

## 2) مستودع صور (Artifact Registry)
```bash
gcloud artifacts repositories create tabanah --repository-format=docker --location=YOUR_REGION
# صيغة المرجع
# YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/IMAGE_NAME:TAG
```

## 3) بناء ودفع صور الـ Backend/Frontend
### Backend
```bash
cd backend
docker build -t YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/backend:galaxy .
gcloud auth configure-docker YOUR_REGION-docker.pkg.dev
docker push YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/backend:galaxy
cd ..
```

### Frontend
```bash
cd frontend
docker build -t YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/frontend:galaxy .
docker push YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/frontend:galaxy
cd ..
```

> بديل: يمكنك استخدام Cloud Build: `gcloud builds submit --tag ...`.

## 4) إنشاء Cloud SQL (PostgreSQL)
```bash
# أنشئ مثيل Postgres 14
gcloud sql instances create tabanah-db --database-version=POSTGRES_14 --tier=db-f1-micro --region=YOUR_REGION
gcloud sql databases create tabanah --instance=tabanah-db
gcloud sql users set-password postgres --instance=tabanah-db --password=STRONG_PASSWORD
```

سجّل اتصال المثيل:
```bash
gcloud sql instances describe tabanah-db --format='value(connectionName)'
# مثال: YOUR_PROJECT_ID:YOUR_REGION:tabanah-db
```

صيغة DATABASE_URL:
```
postgresql+psycopg2://postgres:STRONG_PASSWORD@/tabanah?host=/cloudsql/YOUR_PROJECT_ID:YOUR_REGION:tabanah-db
```

## 5) أسرار البيئة (Secret Manager)
أنشئ أسرار للبيئة لتغذية Cloud Run:
```bash
printf "DATABASE_URL=postgresql+psycopg2://postgres:STRONG_PASSWORD@/tabanah?host=/cloudsql/YOUR_CONN_NAME
JWT_SECRET=change_me
" | gcloud secrets create tabanah-backend-env --data-file=-
printf "VITE_API_BASE=https://YOUR_BACKEND_URL
" | gcloud secrets create tabanah-frontend-env --data-file=-
```

## 6) نشر Backend على Cloud Run
```bash
gcloud run deploy tabanah-backend   --image=YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/backend:galaxy   --add-cloudsql-instances=YOUR_CONN_NAME   --set-secrets=DATABASE_URL=tabanah-backend-env:latest,JWT_SECRET=tabanah-backend-env:latest   --port=8080   --allow-unauthenticated
```

> نقطة الصحة `GET /health` عامة. باقي المسارات يمكن ضبطها لاحقًا بسياسات أو بوابة API.

## 7) نشر Frontend على Cloud Run
```bash
gcloud run deploy tabanah-frontend   --image=YOUR_REGION-docker.pkg.dev/YOUR_PROJECT_ID/tabanah/frontend:galaxy   --set-secrets=VITE_API_BASE=tabanah-frontend-env:latest   --port=4173   --allow-unauthenticated
```

## 8) ربط الدومين + HTTPS
- من Cloud Run → Service → Domain mappings → اربط `app.YOURDOMAIN.com` لكل من الـ frontend و backend (أو backend عبر subpath).
- فعّل HTTPS تلقائي.

## 9) ترحيل الجداول (Alembic)
```bash
# بعد نشر backend، شغّل ترحيل قاعدة البيانات مرة محليًا أو داخل Job
cd backend
alembic upgrade head
```

## 10) تشغيل محلي (اختياري)
```bash
docker compose -f infra/docker-compose.yml up -d
# Backend: http://localhost:8000
# Frontend: http://localhost:5173
# Keycloak: http://localhost:8081 (حسب الملف)
```

## سكربتات جاهزة
- `infra/cloudrun/deploy.sh` يحتوي أوامر متغيرة بالمتغيرات.
- `infra/cloudrun/service-account-setup.sh` لتوليد الأذونات الأساسية.

> انتهى. استعمل README لكل مكون عند الحاجة.
