# CAPACITY CONNECT - Offline Mode & Sync Plan

## 1. Offline Philosophy
Local SQLite is primary operational DB, not cache. Cloud is eventual consistency.

## 2. Connectivity Detection

Service: `ConnectivityService`
- Uses `connectivity_plus` + periodic ping to backend `/health`
- States: ONLINE, OFFLINE, DEGRADED
- Stream: `connectivityStream` -> UI banner

UI Indicators:
- Green: ● ONLINE
- Red: ● OFFLINE - LOCAL ENGINE ACTIVE
- Yellow: ● DEGRADED

## 3. Offline Authentication Policy

- Online login caches: user profile, role, password_hash (bcrypt), JWT + refresh token in Secure Storage, expiry 7 days.
- Offline login: verify against cached hash, check offline session expiry, allow if device registered and within policy.
- Offline session max 72 hours without online re-auth (configurable).
- Failed offline login logged to audit_logs with sync_status PENDING.
- Secure Storage key protected by platform keystore.

Security:
- No plaintext passwords.
- Offline JWT is short-lived but extended via refresh if device trusted.
- Device registration required for offline.

## 4. Offline Capabilities (Must Work)

- Auth (per policy)
- Dashboard (from local DB)
- Training catalog, lessons, downloaded media playback, document viewer
- Quiz attempts (stored locally)
- Troubleshooting via Local AI (127.0.0.1)
- Digital Twin: load cached GLB, interact, highlight fault
- Diagnostics: create, update, attach photos/notes
- Search local knowledge (FTS5)
- Progress tracking
- Settings, storage management
- Audit logging (local)

## 5. Local AI Offline

- Engine runs on 127.0.0.1:8001, no internet needed.
- Knowledge base pre-bundled in app assets + downloadable updates.
- Fallback: if AI engine down, use Dart-side deterministic keyword matcher (same logic ported) so troubleshooting still works.

## 6. Sync Queue Design

Table: sync_queue
- transaction_id UUID PK
- device_id
- user_id
- entity_type
- entity_id
- operation
- payload JSON
- created_at
- updated_at
- sync_status ENUM
- retry_count
- version
- error_message

Every local write:
```dart
await db.transaction(() async {
  await dao.updateEntity(entity);
  await syncQueueDao.enqueue(
    entity_type: 'diagnostic',
    entity_id: entity.id,
    operation: 'UPDATE',
    payload: entity.toJson(),
    version: entity.version
  );
});
```

Sync statuses:
- PENDING: awaiting upload
- SYNCING: in progress
- SYNCED: acked by server
- FAILED: retryable error, retry_count++
- CONFLICT: version conflict, needs resolution

## 7. Sync Engine

Service: `SyncEngine`

Flow:
```
Local Transaction PENDING
   ↓
Connectivity Restored event
   ↓
Auth check (refresh token)
   ↓
Collect PENDING + FAILED (retry_count < max)
   ↓
Mark SYNCING
   ↓
POST /api/v1/sync/upload batch (max 50)
   ↓
Server Validation (JWT, schema, RBAC)
   ↓
Conflict Detection (compare version)
   ↓
If conflict -> mark CONFLICT, store server payload
   ↓
If success -> server returns accepted ids
   ↓
Local mark SYNCED, update version
   ↓
Then download: GET /api/v1/sync/download?last_sync_at
   ↓
Apply server changes locally (with conflict handling)
   ↓
Update last_sync_at in settings
   ↓
Emit sync completed event
```

Retry:
- Exponential backoff: 1s, 2s, 4s, 8s, 16s, max 5 retries, then FAILED.
- User can manually retry from Sync Status page.

Batching:
- 50 transactions per batch to avoid timeout.
- Attachments uploaded separately via multipart after main sync.

## 8. Conflict Resolution

Strategies per entity:

- diagnostics: field-level merge. Server keeps both versions, returns conflict. Client shows diff, technician chooses. Never auto-delete technician notes. Last-write-wins for status only if newer timestamp, but preserve history.
- maintenance_records: version compare, manual resolution for critical.
- progress, quiz_attempts: last-write-wins with version (higher version wins, but if client completed quiz offline, preserve).
- components (admin): version compare, admin manual.
- courses, documents: server wins (admin published), client discards if conflict unless admin.

Implementation:
- Server stores both client and server payload in sync_transactions.conflict_data.
- Client SyncConflictResolver UI shows side-by-side diff.
- Resolution via POST /api/v1/sync/resolve-conflict.

## 9. Offline Search

- FTS5 tables for knowledge_base, documents, components, diagnostics.
- Query: `SELECT * FROM knowledge_fts WHERE knowledge_fts MATCH ? ORDER BY rank`
- GlobalSearchService aggregates results from multiple FTS tables.

## 10. Storage Management

- Settings table tracks storage: total, used, breakdown.
- Media, docs, models can be deleted if not mandatory.
- Never delete PENDING sync data.
- Backup: copy SQLite file to backup dir before major operations, keep 3 backups.

## 11. Failure Handling

- Internet lost during sync: mark SYNCING -> PENDING, retry later.
- App killed during sync: on next launch, reset SYNCING to PENDING.
- DB error: show error screen, attempt recovery from backup.
- Corrupted asset: show placeholder, allow re-download.
- AI unavailable: fallback to Dart matcher.
- 3D model missing: show component data list view.

## 12. Audit & Observability Offline

- All events logged locally with sync_status PENDING.
- On sync, audit logs uploaded via /audit/logs batch.
- Local logs rotated, max 10MB.

## 13. Testing Offline

- Unit: sync queue enqueue/dequeue, conflict detection.
- Integration: simulate offline via mock connectivity, verify writes still work, then go online and verify sync.
- E2E: Full flow from spec - disconnect, troubleshooting, diagnostic create, quiz, restart, reconnect, sync.
- Failure tests: kill app during sync, restart device offline, corrupted DB, invalid API response.

## 14. UI/UX for Offline

- Banner: OFFLINE - LOCAL ENGINE ACTIVE
- Sync page: shows pending count, last sync, retry button, conflict list.
- Dashboard: shows network, storage, security, training %, alerts, twin health, sync queue.
- Training: indicator for offline available content.
- Digital Twin: indicator if model cached.
