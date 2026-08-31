# CAPACITY CONNECT - Architecture Document

## 1. Overview
Capacity Connect is an offline-first hybrid ecosystem for Ministry of Earth Sciences (MoES) field personnel. It enables secure authentication, local AI troubleshooting, Digital Twin visualization, training, diagnostics, and eventual cloud sync.

Target platforms: Android (primary), Windows (primary), Linux, Web.

Core philosophy: **Local database is the source of truth**. Cloud is eventual consistency layer.

## 2. High-Level Architecture

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
  Client   Engine   (Drift)   (FastAPI) (Celery) (PG)
     │       │        │          │       │        │
     └───────┴────────┘          └───────┴────────┘
             │                           │
             └──────── SYNC ─────────────┘
```

### Edge Components
1. **Flutter Client** (Dart, Material 3, Riverpod, GoRouter, Drift, SecureStorage, Dio, model_viewer_plus/custom 3D)
2. **Secure Local AI Engine** - Python FastAPI on 127.0.0.1:8001, deterministic retrieval + fuzzy matching, pluggable embeddings.
3. **Local DB** - SQLite via Drift, encrypted via SQLCipher wrapper (or AES-256-GCM file encryption), full offline operational DB.

### Cloud Components
1. **FastAPI Backend** - REST API v1, PostgreSQL, SQLAlchemy, Pydantic, JWT auth, RBAC.
2. **Background Workers** - for document indexing, media transcoding, sync conflict analysis.
3. **PostgreSQL** - primary cloud DB.
4. **Object Storage** - for media, documents, GLB models (S3 compatible abstraction).

## 3. Modular Folder Structure

```
/client
  /lib
    /core
      /config, /constants, /theme, /utils, /security, /sync, /offline, /storage
    /data
      /datasources/local, /datasources/remote, /models, /repositories
    /domain
      /entities, /repositories, /usecases
    /presentation
      /providers, /pages, /widgets, /router
    /features
      /auth, /dashboard, /training, /media, /documents, /diagnostics, /digital_twin, /search, /admin, /settings
  /assets
    /models, /docs, /images
  /test
/backend
  /app
    /api/v1, /core, /models, /schemas, /services, /repositories, /workers, /db
  /tests
  /alembic
/secure_local_ai_engine
  /app
    /api, /core, /knowledge, /models, /pipeline
  /knowledge_base
  /tests
/docs
```

## 4. Flutter Layered Architecture (Clean + Riverpod)

- **Presentation**: Widgets + Pages + Riverpod Notifiers
- **Domain**: Entities + UseCases + Repository interfaces
- **Data**: Drift DAOs + Remote Datasources (Dio) + Repository impl

State Management: Riverpod 2.x with AsyncNotifier, StateNotifier.
Routing: GoRouter with auth guards, offline guards.

## 5. Offline-First Principle

- Local Drift DB is primary.
- Every write creates transaction in sync_queue.
- ConnectivityService monitors network (connectivity_plus).
- SyncEngine observes connectivity restored -> triggers upload.
- UI shows OFFLINE / LOCAL AI ACTIVE banners based on Connectivity + Backend health check.

## 6. Local AI Engine Architecture

Runs as separate Python process on device (Android via Chaquopy/Termux concept, Windows via bundled Python, Dev via localhost).

Interface: `http://127.0.0.1:8001/analyze` POST {text, language, user_id}

Pipeline:
```
User Input -> Normalization -> Language Detection -> Tokenization -> Keyword Matching -> Phrase Matching -> Fuzzy Matching (RapidFuzz) -> Knowledge Retrieval (TF-IDF + BM25 locally) -> Component Identification -> Fault Classification -> Severity Estimation -> Recommended Action -> 3D Component Mapping -> JSON Response
```

- Knowledge base stored as JSON + SQLite FTS5 + embeddings (optional sentence-transformers).
- Deterministic fallback: if no model, use rule-based keyword->component mapping with confidence scoring based on match ratio, not arbitrary.

Pluggable LLM: interface `EmbeddingProvider` and `LLMProvider` - can later inject ONNX, llama.cpp, etc.

## 7. Digital Twin Engine

- Asset: GLB/GLTF models stored locally in app documents directory, cached.
- Renderer: `model_viewer_plus` for Web/Android, `flutter_3d_controller` or custom `o3d` viewer, with fallback to custom OpenGL via `flutter_cube` if needed. For production we abstract via `DigitalTwinRenderer` interface.
- State Layer: `DigitalTwinStateService` holds component_id -> status (NORMAL, WARNING, DEGRADED, CRITICAL, MAINTENANCE, OFFLINE, UNKNOWN).
- Mapping: ComponentRegistry.mesh_id -> Scene graph node name. On AI result, highlight mesh via emissive color.
- Interactions: rotate, zoom, pan, select, isolate, reset camera, show metadata.

## 8. Training & Media

- Courses -> Modules -> Lessons -> Media (Video/Doc) + Quiz.
- MediaManager handles download with Dio chunked, pause/resume via Range headers, checksum SHA256, storage info.
- Video: `video_player` + `chewie`, resume position stored in DB.
- Documents: local file viewer, PDF via `flutter_pdfview` or web fallback.

## 9. Sync Architecture

Transaction ledger:
```
transaction_id (uuid), device_id, user_id, entity_type, entity_id, operation (CREATE/UPDATE/DELETE), payload (JSON), created_at, updated_at, sync_status (PENDING/SYNCING/SYNCED/FAILED/CONFLICT), retry_count, version
```

Flow:
```
Local Write -> sync_queue PENDING -> Connectivity Restored -> Auth -> Upload batch -> Server Validation -> Conflict Detection (version compare) -> Ack -> Local mark SYNCED
```

Conflict strategies per entity:
- Diagnostics: manual/field-level merge, never silent loss.
- Training progress: last-write-wins with version.
- Components (admin only): version comparison.

## 10. Security Layers

- Local: SQLCipher / AES-256-GCM file encryption, Flutter Secure Storage for keys, device registration, session timeout, integrity checks.
- Network: HTTPS, cert pinning option, JWT (access 15min, refresh 7d), rate limiting via slowapi.
- Backend: RBAC, bcrypt password hashing, token validation, Pydantic validation, audit logging.
- Data: AES-256-GCM for sensitive fields, no hardcoded keys, .env.

## 11. Versioning & Updates

Versioned: app, API, courses, docs, 3D models, knowledge base, AI models.
Client stores installed versions in settings table.
UpdateService checks /api/v1/updates/manifest and downloads deltas with checksum.

## 12. Observability

- App logs: logger package, local file rotation.
- Backend logs: structlog.
- Local AI logs: file + endpoint /logs.
- Sync logs: sync_queue metadata.
- No sensitive data logged.

## 13. Deployment

- Client: APK, Windows MSIX/exe, Web.
- Backend: Docker + Uvicorn + Postgres.
- Local AI: bundled Python executable or pip package, systemd/Windows service.

## 14. Non-Functional Requirements

- Fast startup <3s, smooth 60fps UI, async heavy work via isolates/compute.
- Offline auth with cached JWT + secure storage + expiry policy.
- Graceful degradation everywhere.
