# SYNC.md already covered in OFFLINE_MODE.md - Detailed Sync Spec

See OFFLINE_MODE.md for full sync design.

This file adds implementation details.

## Sync Transaction Schema (Backend)

```python
class SyncTransaction(Base):
    id = UUID PK
    transaction_id = client UUID UNIQUE
    device_id
    user_id FK
    entity_type
    entity_id
    operation
    payload JSONB
    client_version INT
    server_version INT
    status (PENDING/PROCESSED/CONFLICT)
    conflict_data JSONB nullable
    created_at
    processed_at
```

## Upload Endpoint Logic

1. Authenticate
2. For each transaction in batch:
   - Validate schema per entity_type
   - Check user has permission for entity
   - Load server entity, compare version
   - If client_version < server_version => CONFLICT
   - Else apply: CREATE/UPDATE/DELETE
   - Increment server_version
   - Save sync_transaction as PROCESSED
3. Return accepted, conflicts, failed

## Download Endpoint Logic

- Client sends last_sync_at
- Server returns all entities updated since last_sync_at where user has access
- Includes deleted entities with operation DELETE
- Server_time included for next sync

## Client SyncEngine Implementation Steps

```dart
class SyncEngine {
  Future<void> sync() async {
    if (!await connectivity.isOnline) return;
    await _uploadPending();
    await _downloadServerChanges();
  }

  Future<void> _uploadPending() async {
    final pending = await syncQueue.getPending(limit: 50);
    if (pending.isEmpty) return;
    await syncQueue.markSyncing(pending.map((e) => e.transactionId).toList());
    try {
      final response = await api.post('/sync/upload', data: {transactions: pending});
      await handleUploadResponse(response);
    } catch (e) {
      await syncQueue.markFailed(pending.map((e) => e.transactionId).toList(), error: e.toString());
      rethrow;
    }
  }
}
```

## Conflict UI

- Page: /sync/conflicts
- List conflicts with entity type, local vs server diff
- Actions: Use Local, Use Server, Merge Manually
- For diagnostics, merge preserves both technician notes
