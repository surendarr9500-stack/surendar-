# Folder Structure - Capacity Connect

```
capacity-connect/
├── client/ (Flutter)
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── config/app_config.dart
│   │   │   ├── constants/app_constants.dart
│   │   │   ├── theme/app_theme.dart
│   │   │   ├── security/ (encryption_service.dart, secure_storage_service.dart)
│   │   │   ├── offline/ (connectivity_service.dart)
│   │   │   ├── sync/ (sync_engine.dart)
│   │   │   ├── storage/ (local storage helpers)
│   │   │   └── utils/ (logger.dart)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── local/ (app_database.dart, app_database.g.dart, seed_data.dart)
│   │   │   │   └── remote/ (api clients)
│   │   │   ├── models/ (component_model.dart)
│   │   │   └── repositories/ (implementations)
│   │   ├── domain/
│   │   │   ├── entities/ (component.dart)
│   │   │   ├── repositories/ (component_repository.dart)
│   │   │   └── usecases/ (troubleshoot_usecase.dart)
│   │   ├── presentation/
│   │   │   ├── providers/ (auth_provider.dart, troubleshooting_provider.dart)
│   │   │   ├── pages/ (splash, login, dashboard, troubleshooting, digital_twin, training, diagnostics, documents, search, settings, sync_status, admin, quiz)
│   │   │   ├── widgets/ (offline_banner, status_card)
│   │   │   └── router/ (app_router.dart)
│   │   ├── features/
│   │   │   ├── auth/ (data/repositories/auth_repository_impl.dart)
│   │   │   ├── dashboard/
│   │   │   ├── training/
│   │   │   ├── diagnostics/
│   │   │   ├── digital_twin/
│   │   │   ├── search/
│   │   │   ├── admin/
│   │   │   └── settings/
│   │   └── l10n/ (localization)
│   ├── assets/
│   │   ├── models/ (.gitkeep, *.glb)
│   │   ├── docs/
│   │   ├── images/
│   │   ├── knowledge/
│   │   └── fonts/
│   └── test/ (widget_test.dart)
├── backend/ (FastAPI)
│   ├── app/
│   │   ├── main.py
│   │   ├── core/ (config.py, security.py)
│   │   ├── db/ (session.py, seed.py)
│   │   ├── models/ (user, component, course, diagnostic, sync, audit)
│   │   ├── schemas/ (auth, component, diagnostic, sync)
│   │   ├── api/v1/ (auth, components, diagnostics, sync, courses, admin, health, digital_twin, media)
│   │   ├── services/, repositories/, workers/
│   ├── tests/ (test_api.py)
│   ├── alembic/ (versions)
│   ├── requirements.txt, Dockerfile
├── secure_local_ai_engine/ (Local AI)
│   ├── app/
│   │   ├── main.py
│   │   ├── api/endpoints.py
│   │   ├── core/ (component_registry.py, pipeline.py)
│   │   ├── knowledge/ (retrieval.py)
│   │   ├── models/, pipeline/
│   ├── knowledge_base/
│   ├── tests/test_pipeline.py
│   ├── requirements.txt, Dockerfile
├── docs/
│   ├── plans/ (ARCHITECTURE_PLAN, DATABASE_PLAN, FOLDER_STRUCTURE, API_PLAN, OFFLINE_SYNC_PLAN, AI_PLAN, DIGITAL_TWIN_PLAN, SECURITY_PLAN, TEST_PLAN)
├── demo_server.py (Live Web UI 8080)
├── e2e_test.py (E2E acceptance)
├── docker-compose.yml
├── .env.example, .gitignore
├── README.md, ARCHITECTURE.md, DATABASE.md, API.md, SECURITY.md, OFFLINE_MODE.md, SYNC.md, AI_ENGINE.md, DIGITAL_TWIN.md, DEPLOYMENT.md, TESTING.md, TROUBLESHOOTING.md, IMPLEMENTATION_SUMMARY.md, FINAL_DELIVERY.md
```

## Why This Structure
- Clean Architecture: core, data, domain, presentation
- Feature-based: each feature has data/domain/presentation
- Modular: edge (Flutter + Local AI + Local DB) + cloud (API + Workers + DB) + sync
- Offline-first: local DB is source of truth
- Production-ready: no giant files, no duplicated logic, no hardcoded secrets
