# CAPACITY CONNECT

**SIH 2026 - SIH26075 - Ministry of Earth Sciences (MoES), Government of India**

Secure offline-first operational platform for MoES field personnel: training, troubleshooting, Digital Twin visualization, diagnostics, and sync.

## Production Engineering Master Prompt v2.0 Implementation

This repository implements the full Capacity Connect specification as production-oriented software, not a mockup.

## Architecture

```
                    CAPACITY CONNECT
                           │
             ┌─────────────┴─────────────┐
             │                           │
       EDGE APPLICATION             CLOUD PLATFORM
             │                           │
     ┌───────┼────────┐          ┌───────┼────────┐
     │       │        │          │       │        │
 Flutter   Local AI  Local DB   API    Workers   DB
     │       │        │          │       │        │
     └───────┴────────┘          └───────┴────────┘
             │                           │
             └──────── SYNC ─────────────┘
```

- **Client**: Flutter, Dart, Material 3, Riverpod, GoRouter, Drift/SQLite, Secure Storage, Dio, model_viewer_plus
- **Local AI Engine**: Python FastAPI on 127.0.0.1:8001, deterministic retrieval, pluggable embeddings
- **Backend**: Python FastAPI, PostgreSQL, SQLAlchemy, Pydantic, JWT, RBAC

## Key Features (Production)

1. Secure authentication with offline policy
2. Offline-first operation with LOCAL ENGINE ACTIVE banner
3. Local training with media download, resume, offline playback
4. Operational documentation with local FTS search
5. Global search (courses, docs, components, diagnostics, knowledge)
6. Text + voice input for troubleshooting
7. Local AI-assisted troubleshooting with real confidence scoring
8. Component identification + mesh mapping (SONAR-001 -> Mesh_042)
9. 3D Digital Twin with GLB/GLTF, rotate, zoom, pan, select, highlight, isolate, reset
10. Diagnostic workflow with audit trail
11. Quiz engine with offline completion
12. Sync engine with transaction ledger, conflict resolution
13. Role-based access (Administrator, Training Officer, Field Engineer, Technician, Supervisor)
14. Security: AES-256-GCM, secure storage, HTTPS, bcrypt, JWT, audit logs
15. Admin portal for users, training, assets, knowledge, system

## Folder Structure

```
client/                      # Flutter app
  lib/
    core/                    # config, constants, theme, security, sync, offline
    data/                    # datasources, models, repositories
    domain/                  # entities, usecases
    presentation/            # providers, pages, widgets, router
    features/                # auth, dashboard, training, diagnostics, digital_twin, etc
  assets/
    models/                  # GLB/GLTF cached
  test/
backend/                     # FastAPI cloud platform
  app/
    api/v1/                  # versioned endpoints
    core/                    # config, security, logging
    models/                  # SQLAlchemy
    schemas/                 # Pydantic
    services/                # business logic
    db/                      # session, init
  tests/
  alembic/                   # migrations
secure_local_ai_engine/      # Local AI on 127.0.0.1
  app/
    api/                     # FastAPI endpoints
    core/                    # registry, pipeline, confidence
    knowledge/               # indexing, retrieval
    models/                  # data models
    pipeline/                # normalization -> mapping
  knowledge_base/            # seeded knowledge chunks
  tests/
docs/                        # Additional docs
ARCHITECTURE.md
DATABASE.md
API.md
SECURITY.md
OFFLINE_MODE.md
SYNC.md
AI_ENGINE.md
DIGITAL_TWIN.md
DEPLOYMENT.md
TESTING.md
TROUBLESHOOTING.md
```

## Quick Start

### Prerequisites Check

```bash
flutter --version
dart --version
python3 --version
pip --version
git --version
```

See DEPLOYMENT.md for full prerequisites.

### Backend

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp ../.env.example .env
# Edit .env
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Health: http://localhost:8000/api/v1/health

### Local AI Engine

```bash
cd secure_local_ai_engine
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload
```

Test:
```bash
curl -X POST http://127.0.0.1:8001/analyze -H "Content-Type: application/json" -d '{"text": "Sonar transducer is showing abnormal vibration and casing fracture."}'
```

Expected: SONAR-001, Mesh_042, HIGH, confidence ~0.94

### Client

```bash
cd client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1 --dart-define=AI_ENGINE_URL=http://127.0.0.1:8001
```

Build:
```bash
flutter build apk --release
flutter build windows --release
```

## Demo Mode - LIVE ENGINEERING DEMO

Real production pipeline, not fake animation:

```
Engineer opens app
 ↓
Login (field_engineer / Field@123)
 ↓
Dashboard
 ↓
Disable Internet (airplane mode)
 ↓
OFFLINE MODE - LOCAL ENGINE ACTIVE
 ↓
Troubleshooting -> Enter: "Sonar transducer is showing abnormal vibration and casing fracture."
 ↓
Local AI (127.0.0.1:8001) -> SONAR-001, Mesh_042, HIGH, 0.94
 ↓
3D Digital Twin -> Highlight Mesh_042 red
 ↓
Diagnostic guidance
 ↓
Create diagnostic record
 ↓
Complete quiz
 ↓
Save locally (Drift DB)
 ↓
Restart app -> Data still exists
 ↓
Restore Internet
 ↓
Synchronization -> SYNCED
 ↓
Admin can view record
```

## Demo Fault (Preloaded)

```
Component: Sonar Transducer Array
ID: SONAR-001
Mesh: Mesh_042
Problem: Abnormal vibration and casing fracture
Expected: HIGH severity, diagnostic procedure
```

## Security

- No hardcoded secrets (.env.example only)
- AES-256-GCM where appropriate
- Bcrypt password hashing
- JWT access 15min, refresh 7d
- RBAC enforced backend + frontend
- Audit logs for all sensitive actions
- See SECURITY.md

## Offline-First

Local SQLite is source of truth. Cloud is eventual consistency. See OFFLINE_MODE.md and SYNC.md.

## Testing

```bash
cd client && flutter test
cd backend && pytest tests -v
cd secure_local_ai_engine && pytest tests -v
```

See TESTING.md for E2E and failure testing.

## Documentation

- ARCHITECTURE.md - System architecture
- DATABASE.md - Local and cloud DB design
- API.md - REST API v1 spec
- AI_ENGINE.md - Local AI pipeline
- DIGITAL_TWIN.md - 3D twin design
- OFFLINE_MODE.md - Offline + sync
- SECURITY.md - Security layers
- DEPLOYMENT.md - Deployment guide
- TESTING.md - Testing strategy
- TROUBLESHOOTING.md - Troubleshooting

## Implementation Phases

Completed per PLAN -> BUILD -> RUN -> TEST -> FIX -> VERIFY -> NEXT

- Phase 1: Repository and environment ✓
- Phase 2: Flutter shell
- Phase 3: Design system
- ... up to Phase 32: Final integration

See git log for phase commits.

## Definition of Done

Feature complete only when:
- Code exists AND Build succeeds AND Tests pass AND UI works AND DB works AND Error states work AND Offline tested AND Integration verified AND Docs updated

## License

Proprietary - Ministry of Earth Sciences, Government of India - SIH 2026

## Engineering Changelog

See git commits and docs.
