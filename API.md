# CAPACITY CONNECT - API Design

Base URL: `/api/v1`

## 1. General Conventions

- Versioned: `/api/v1/...`
- Auth: Bearer JWT, refresh via `/auth/refresh`
- Content-Type: application/json
- Errors: consistent structure
```json
{
  "detail": "message",
  "code": "ERROR_CODE",
  "timestamp": "ISO8601",
  "request_id": "uuid"
}
```
- Pagination: `?page=1&page_size=20`
- Sorting: `?sort_by=created_at&sort_order=desc`
- Filtering: `?status=OPEN&component_id=SONAR-001`

## 2. Auth

### POST /api/v1/auth/login
Body: {username, password, device_id, device_name, platform}
Response: {access_token, refresh_token, expires_in, user, device}

### POST /api/v1/auth/refresh
Body: {refresh_token, device_id}
Response: {access_token, refresh_token}

### POST /api/v1/auth/logout
Header: Bearer
Body: {device_id}

### POST /api/v1/auth/register-device
For offline auth caching, registers device and returns offline token policy.

## 3. Users

### GET /api/v1/users/me
### GET /api/v1/users (admin)
### POST /api/v1/users (admin)
Body: {username, email, password, role, display_name}
### GET /api/v1/users/{id}
### PATCH /api/v1/users/{id} (admin)
### DELETE /api/v1/users/{id} (admin disable)
### POST /api/v1/users/{id}/reset-password (admin)

## 4. Components

### GET /api/v1/components
Query: category, status, search
### POST /api/v1/components (admin)
### GET /api/v1/components/{id}
### PATCH /api/v1/components/{id} (admin)
### DELETE /api/v1/components/{id} (admin)
### GET /api/v1/components/{id}/faults
### GET /api/v1/components/{id}/maintenance
### POST /api/v1/components/{id}/status (technician+)

## 5. Digital Twin

### GET /api/v1/digital-twin/models
### GET /api/v1/digital-twin/models/{mesh_id}
### POST /api/v1/digital-twin/models (admin upload)
Multipart: file, mesh_id, component_id, version
### GET /api/v1/digital-twin/state
Returns all components status
### POST /api/v1/digital-twin/state/update
Body: {mesh_id, status, fault}

## 6. Courses / Training

### GET /api/v1/courses
### POST /api/v1/courses (training_officer, admin)
### GET /api/v1/courses/{id}
### PATCH /api/v1/courses/{id}
### DELETE /api/v1/courses/{id}
### GET /api/v1/courses/{id}/modules
### POST /api/v1/courses/{id}/modules
### GET /api/v1/modules/{id}/lessons
### POST /api/v1/modules/{id}/lessons

### Media
### GET /api/v1/media
### POST /api/v1/media/upload (multipart)
### GET /api/v1/media/{id}
### GET /api/v1/media/{id}/download
### DELETE /api/v1/media/{id}

### Documents
### GET /api/v1/documents
### POST /api/v1/documents/upload
### GET /api/v1/documents/{id}
### GET /api/v1/documents/{id}/download
### PATCH /api/v1/documents/{id}
### DELETE /api/v1/documents/{id}

### Quizzes
### GET /api/v1/quizzes
### POST /api/v1/quizzes
### GET /api/v1/quizzes/{id}
### PATCH /api/v1/quizzes/{id}
### DELETE /api/v1/quizzes/{id}
### GET /api/v1/quizzes/{id}/questions
### POST /api/v1/quizzes/{id}/questions

### Attempts
### POST /api/v1/quizzes/{id}/attempts
Body: {answers}
Response: {score, passed, attempt_id}
### GET /api/v1/attempts
### GET /api/v1/attempts/{id}

### Progress
### GET /api/v1/progress/me
### POST /api/v1/progress
Body: {course_id, lesson_id, progress_percent, completed}

## 7. Diagnostics

### GET /api/v1/diagnostics
Query: component_id, status, severity, reported_by
### POST /api/v1/diagnostics
Body: {component_id, title, description, ai_analysis, severity, status}
### GET /api/v1/diagnostics/{id}
### PATCH /api/v1/diagnostics/{id}
Body: {status, technician_action, resolution_notes}
### DELETE /api/v1/diagnostics/{id} (admin)

### Maintenance
### GET /api/v1/maintenance
### POST /api/v1/maintenance
### GET /api/v1/maintenance/{id}
### PATCH /api/v1/maintenance/{id}

### Work Orders
### GET /api/v1/work-orders
### POST /api/v1/work-orders
### GET /api/v1/work-orders/{id}
### PATCH /api/v1/work-orders/{id}

## 8. Sync

### POST /api/v1/sync/upload
Body: {device_id, transactions: [{transaction_id, entity_type, entity_id, operation, payload, created_at, version}]}
Response: {accepted: [], conflicts: [{transaction_id, server_version, conflict_data}], failed: []}
Logic: validate JWT, check version, detect conflict, write to sync_transactions, apply to main tables if no conflict.

### GET /api/v1/sync/download
Query: device_id, last_sync_at
Response: {transactions: [server changes since last_sync], server_time}

### POST /api/v1/sync/resolve-conflict
Body: {transaction_id, resolution_strategy, merged_payload}

### GET /api/v1/sync/status
Returns pending, last sync, device status

## 9. Audit

### GET /api/v1/audit/logs
Query: user_id, event, entity_type, from, to
Admin only, or user can view own.

### POST /api/v1/audit/logs
For client to upload offline audit logs during sync.

## 10. Search

### GET /api/v1/search?q=sonar&entity_type=component
Returns aggregated results from components, docs, courses, diagnostics.

## 11. Updates / Manifest

### GET /api/v1/updates/manifest
Query: current_versions JSON
Response: {updates: [{entity_type, entity_id, version, file_url, checksum, mandatory, changelog}], server_time}

### GET /api/v1/updates/check

## 12. Admin / System

### GET /api/v1/admin/stats
### GET /api/v1/admin/devices
### GET /api/v1/admin/sync-queue
### GET /api/v1/admin/storage

## 13. Local AI Engine API (127.0.0.1:8001)

### POST /analyze
Body: {text, language?, user_id?, request_id?}
Response:
```json
{
  "request_id": "...",
  "component_id": "SONAR-001",
  "component_name": "Sonar Transducer Array",
  "mesh_id": "Mesh_042",
  "fault": "Casing fracture",
  "severity": "HIGH",
  "confidence": 0.94,
  "evidence": [{"keyword": "sonar", "matched": "sonar", "score": 0.98}],
  "recommended_actions": ["Inspect casing...", "Check vibration..."],
  "warnings": [],
  "timestamp": "..."
}
```

### POST /search
Body: {query, top_k}
Response: {results: [{id, title, content, score, metadata}]}

### GET /health
Response: {status, version, knowledge_base_count, model_loaded}

### GET /knowledge/components

## 14. Security

- All endpoints except /auth/login and /health require Bearer.
- RBAC enforced via dependency: `require_role([admin, training_officer])`
- Rate limiting: 100 req/min per IP, 1000 per user (slowapi)
- Input validation via Pydantic, SQL injection prevented via ORM.
- Audit log for every mutating operation.

## 15. WebSocket (Optional)

### WS /api/v1/ws/sync-status
For real-time sync progress when online.

### WS /api/v1/ws/digital-twin
For live twin state updates (future).

## 16. Schemas (Pydantic)

All schemas have:
- id: UUID
- created_at, updated_at: datetime
- version: int

Example ComponentSchema:
```python
class ComponentBase(BaseModel):
    id: str
    name: str
    category: str
    description: str
    manufacturer: str
    model: str
    mesh_id: str
    x: float
    y: float
    z: float
    status: ComponentStatus
    installation_location: str
    possible_faults: List[str]
    maintenance_procedures: List[str]
    ...
```
