# CAPACITY CONNECT - Troubleshooting Guide

## Common Issues

### Flutter

**flutter: command not found**
- Install Flutter SDK from https://docs.flutter.dev/get-started/install
- Add to PATH
- Or use Docker with Flutter

**Pub get fails**
- Check internet
- `flutter pub cache repair`
- Delete pubspec.lock and retry

**Drift build fails**
- Run `dart run build_runner build --delete-conflicting-outputs`

**Model viewer not showing**
- Check GLB path exists
- Check web renderer canvaskit required for model_viewer_plus
- Fallback to list view if needed

### Local AI Engine

**Port 8001 already in use**
- `lsof -i :8001` then kill, or change port in config

**Knowledge base not found**
- Ensure `knowledge_base/` dir exists
- Run `python -m app.knowledge.seed`

**Low confidence always**
- Check keyword mapping in `app/core/component_registry.py`
- Check knowledge base seeded

**Module not found**
- Activate venv, pip install -r requirements.txt

### Backend

**DB connection failed**
- Check DATABASE_URL in .env
- Check postgres running
- For dev, use SQLite fallback: `DATABASE_URL=sqlite:///./dev.db`

**Alembic migration fails**
- Check `alembic.ini` sqlalchemy.url
- `alembic current`, `alembic history`
- For dev reset: delete DB file and re-run init

**JWT invalid**
- Check JWT_SECRET same across restarts
- Check token expiry

**CORS error on Web**
- Add frontend origin to CORS_ORIGINS in .env

### Sync

**Sync stuck PENDING**
- Check connectivity service says ONLINE
- Check backend /health reachable
- Check JWT not expired
- Look at sync_queue error_message column

**Conflict always**
- Check version increment logic
- Ensure client sends correct version

**Data loss after sync**
- Check conflict resolution strategy
- Never delete PENDING transactions
- Check logs

### Offline Mode

**Offline login fails**
- Must have logged in online at least once
- Check device registered
- Check offline session not expired (72h)

**OFFLINE banner not showing**
- Check ConnectivityService
- Simulate offline via airplane mode or mock

### Digital Twin

**Model not loading**
- Check file exists in app documents
- Check checksum matches
- Try fallback renderer

**Highlight not working**
- Check mesh_id mapping correct
- Check renderer JS interop for model_viewer_plus
- Verify state service updated

## Debug Steps

1. Check logs: `client/logs/`, `backend/logs/`, `secure_local_ai_engine/logs/`
2. Check DB: open SQLite file with DB Browser, check tables
3. Check network: curl backend health, AI health
4. Check storage: settings page shows breakdown
5. Reproduce: follow E2E test steps

## Support

- Check ARCHITECTURE.md, API.md, OFFLINE_MODE.md
- Run tests: `flutter test`, `pytest`
- Open issue with logs, steps, expected vs actual
