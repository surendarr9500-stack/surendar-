# Architecture Plan - Capacity Connect

## Overview
Offline-first hybrid ecosystem: Flutter client + Local AI Engine (127.0.0.1:8001) + Local DB (Drift/SQLite) + Cloud Platform (FastAPI + PostgreSQL) + Sync Engine.

## High-Level
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

## Decisions
- Flutter: Material 3, Riverpod, GoRouter, Drift, SecureStorage, Dio, model_viewer_plus
- Local AI: Python FastAPI on 127.0.0.1, deterministic TF-IDF/BM25 + keyword matching, pluggable embeddings
- Backend: FastAPI, PostgreSQL, SQLAlchemy, Pydantic, JWT, RBAC
- Sync: Transaction ledger, PENDING/SYNCING/SYNCED/FAILED/CONFLICT, version-based conflict detection
- Security: AES-256-GCM, bcrypt, JWT 15min/7d, secure storage, audit logs
- Digital Twin: GLB/GLTF cached locally, mesh mapping component_id→mesh_id→scene node, state layer

## Folder Structure
```
/client
  /lib
    /core (config, constants, theme, security, sync, offline, storage, utils)
    /data (datasources/local/remote, models, repositories)
    /domain (entities, repositories, usecases)
    /presentation (providers, pages, widgets, router)
    /features (auth, dashboard, training, diagnostics, digital_twin, search, admin, settings)
  /assets (models, docs, images, knowledge)
  /test
/backend
  /app
    /api/v1 (auth, users, components, digital-twin, courses, media, documents, diagnostics, sync, audit)
    /core (config, security)
    /models (SQLAlchemy)
    /schemas (Pydantic)
    /services, /repositories, /workers, /db
  /tests, /alembic
/secure_local_ai_engine
  /app
    /api, /core, /knowledge, /models, /pipeline
  /knowledge_base
  /tests
```

## Non-Functional
- Fast startup <3s, 60fps UI, async heavy work via isolates
- Offline-first: local DB source of truth, cloud eventual consistency
- Graceful degradation everywhere
