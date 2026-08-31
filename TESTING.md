# CAPACITY CONNECT - Testing Strategy

## 1. Unit Tests

### Flutter (client/test)
- Parsers: normalization, tokenization, keyword matching
- Repositories: Drift DAOs mock
- Services: ConnectivityService, SyncEngine (mock API), AuthService
- State: Riverpod providers
- Encryption wrappers
- Digital Twin state mapping

### Backend (backend/tests)
- Auth: login, token generation, RBAC
- Components CRUD
- Diagnostics CRUD
- Sync upload/download, conflict detection
- Pydantic validation

### Local AI (secure_local_ai_engine/tests)
- Normalization
- Keyword matching
- Phrase matching
- Fuzzy matching
- Confidence scoring
- Full pipeline with demo fault
- Knowledge retrieval

Run:
```bash
flutter test
pytest backend/tests
pytest secure_local_ai_engine/tests
```

## 2. Integration Tests

### Flutter + Local DB + Local AI
- Login -> Dashboard -> Troubleshooting -> AI -> Twin -> Diagnostic -> Save -> Verify DB
- Offline: mock connectivity offline, verify local ops still work
- Sync: enqueue, go online, verify upload

### Backend + DB
- API startup
- Migration test
- Endpoint integration with test DB (Postgres or SQLite for test)

## 3. E2E Tests (Critical Path)

```
START
 ↓
LOGIN (test user field_engineer / password)
 ↓
DASHBOARD (verify stats from real DB)
 ↓
DOWNLOAD TRAINING (mock download)
 ↓
OPEN DIGITAL TWIN (load model, verify meshes)
 ↓
DISCONNECT INTERNET (simulate offline)
 ↓
OFFLINE MODE banner
 ↓
ENTER ENGINEERING FAULT: "Sonar transducer is showing abnormal vibration and casing fracture."
 ↓
LOCAL AI PROCESSING (call 127.0.0.1:8001)
 ↓
IDENTIFY COMPONENT SONAR-001 Mesh_042 HIGH confidence >0.8
 ↓
MAP COMPONENT TO 3D MODEL (highlight)
 ↓
DISPLAY DIAGNOSTIC GUIDANCE
 ↓
CREATE DIAGNOSTIC RECORD
 ↓
COMPLETE TRAINING QUIZ
 ↓
SAVE ALL DATA LOCALLY (verify Drift DB)
 ↓
RESTART APPLICATION (simulate: close and reopen DB, verify data persists)
 ↓
RESTORE INTERNET
 ↓
SYNCHRONIZATION (upload pending, verify SYNCED)
 ↓
SERVER CONFIRMATION (check backend sync_transactions)
 ↓
ADMIN CAN VIEW RECORD (login as admin, GET /diagnostics)
 ↓
END
```

## 4. Failure Testing

Explicitly test:
- Internet suddenly disconnected during sync -> queue intact, retry
- Backend crashes during upload -> client marks FAILED, retry
- Database temporarily unavailable -> safe error screen, recovery
- AI service unavailable -> fallback to Dart matcher
- Model missing -> fallback to list view
- Sync interrupted (app killed) -> on restart, SYNCING -> PENDING
- Device restarted while offline -> data persists, offline auth works
- Invalid API response -> validation error, not crash
- Corrupted asset (GLB) -> error handling, allow re-download
- Invalid input (empty fault text) -> validation message
- Expired token -> refresh flow, or re-login

## 5. Performance Testing

- Startup time <3s
- DB query: 1000 diagnostics query <100ms
- AI pipeline: <500ms for 1000 chunks
- 3D rendering: 60fps, memory <200MB
- Sync: 100 transactions batch <2s
- Use `flutter test --benchmark` and `pytest --benchmark`

## 6. Security Testing

- Password hashing verification
- JWT validation
- RBAC: field_engineer cannot access admin endpoints
- Offline auth expiry
- Encryption roundtrip
- No secrets in logs

## 7. Manual QA Checklist

- [ ] Login with valid/invalid credentials
- [ ] Offline login after online
- [ ] Dashboard shows real data, no fake numbers
- [ ] Training download, play, resume, delete
- [ ] Document search
- [ ] Troubleshooting with demo fault -> correct component
- [ ] Digital Twin rotate, zoom, pan, select, highlight, reset, isolate
- [ ] Diagnostic create, edit, attach photo, save
- [ ] Quiz take, score, progress
- [ ] Sync status page, pending count, retry, conflict resolution
- [ ] Storage management
- [ ] Admin: create user, create component, upload model, publish course
- [ ] Logs: no sensitive data

## 8. CI/CD

- GitHub Actions: run flutter analyze, flutter test, pytest, build apk
- Pre-commit hooks: format, analyze

## 9. Test Data

- Seed data clearly marked as demo
- No fake live data pretending to be real
- Use factories for test entities
