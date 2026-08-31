# CAPACITY CONNECT - Deployment Guide

## 1. Prerequisites

Check environment:
```bash
flutter --version
dart --version
python3 --version
pip --version
git --version
```

Android SDK, Java, disk, RAM.

## 2. Client (Flutter)

### Setup
```bash
cd client
flutter pub get
flutter analyze
flutter test
```

### Run Dev
```bash
flutter run -d windows
flutter run -d android
flutter run -d chrome --web-renderer canvaskit
```

### Build Release
```bash
flutter build apk --release
flutter build windows --release
flutter build web --release
```

### Environment
- `lib/core/config/app_config.dart` reads from --dart-define
- `.env` not used in Flutter, use compile-time defines for API URLs

## 3. Local AI Engine

### Setup
```bash
cd secure_local_ai_engine
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Run
```bash
uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload
```

### Test
```bash
pytest tests -v
curl http://127.0.0.1:8001/health
curl -X POST http://127.0.0.1:8001/analyze -H "Content-Type: application/json" -d '{"text": "Sonar transducer is showing abnormal vibration and casing fracture."}'
```

### Bundle for Windows
```bash
pyinstaller --onefile --add-data "knowledge_base:knowledge_base" app/main.py
```

## 4. Backend

### Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# edit .env with DB credentials, JWT secret
```

### .env.example
```
DATABASE_URL=postgresql://user:pass@localhost:5432/capacity_connect
JWT_SECRET=change-me-strong-secret
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
STORAGE_PATH=./storage
LOG_LEVEL=info
```

### DB Migrations
```bash
alembic upgrade head
# or for dev:
python -m app.db.init_db
```

### Run
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Docker
```bash
docker-compose up --build
```

Docker-compose includes:
- postgres:15
- backend (FastAPI)
- maybe redis for workers

### Test
```bash
pytest tests -v
curl http://localhost:8000/api/v1/health
```

## 5. Full Stack Dev Run

Terminal 1: Backend
```bash
cd backend && uvicorn app.main:app --port 8000 --reload
```

Terminal 2: Local AI
```bash
cd secure_local_ai_engine && uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload
```

Terminal 3: Flutter
```bash
cd client && flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1 --dart-define=AI_ENGINE_URL=http://127.0.0.1:8001
```

## 6. Production Deployment

### Backend
- Docker image built via Dockerfile
- Deploy to VM/K8s
- Postgres managed service
- S3 for storage
- HTTPS via reverse proxy (nginx)
- Env vars from secrets manager

### Client
- APK distributed via internal MDM or Play Store internal track
- Windows MSIX via Intune or direct installer
- Web via nginx static hosting

### Local AI
- Bundled with Windows installer
- For Android, run as foreground service via Chaquopy or separate Termux script (documented)

## 7. Updates

- Backend: rolling update, migration via alembic
- Client: check /api/v1/updates/manifest on launch, download if mandatory
- Knowledge base: versioned, download via sync
- Models: versioned, checksum verified

## 8. Monitoring

- Backend logs via structlog -> file + stdout
- Health endpoints: /api/v1/health, /health for AI
- Metrics: Prometheus optional
- Client logs: local file, upload on sync

## 9. Backup & Recovery

- Local DB: backup to `backups/` dir, keep 3
- Cloud DB: daily PG backup
- Sync queue survives restart
