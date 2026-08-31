# API Plan - Capacity Connect

Base URL: /api/v1

## Conventions
- Versioned: /api/v1/...
- Auth: Bearer JWT, refresh via /auth/refresh
- Errors: {detail, code, timestamp, request_id}
- Pagination: ?page=1&page_size=20
- Filtering: ?status=OPEN&component_id=SONAR-001

## Endpoints

### Auth
- POST /auth/login {username, password, device_id, device_name, platform} → {access_token, refresh_token, expires_in, user, device}
- POST /auth/refresh {refresh_token, device_id} → {access_token, refresh_token}
- POST /auth/logout {device_id}
- POST /auth/register-device
- GET /auth/me

### Users (admin)
- GET /users, POST /users, GET /users/{id}, PATCH /users/{id}, DELETE /users/{id}, POST /users/{id}/reset-password

### Components
- GET /components?category&status&search
- POST /components (admin)
- GET /components/{id}
- PATCH /components/{id} (admin)
- DELETE /components/{id} (admin)
- GET /components/{id}/faults
- POST /components/{id}/status

### Digital Twin
- GET /digital-twin/models
- GET /digital-twin/models/{mesh_id}
- POST /digital-twin/models (admin upload multipart)
- GET /digital-twin/state
- POST /digital-twin/state/update {mesh_id, status, fault}

### Training
- GET /courses, POST /courses (training_officer, admin), GET /courses/{id}, PATCH, DELETE
- GET /courses/{id}/modules, POST /courses/{id}/modules
- GET /modules/{id}/lessons, POST /modules/{id}/lessons
- Media: GET /media, POST /media/upload multipart, GET /media/{id}, GET /media/{id}/download, DELETE /media/{id}
- Documents: GET /documents, POST /documents/upload, GET /documents/{id}, GET /documents/{id}/download, PATCH, DELETE
- Quizzes: GET /quizzes, POST /quizzes, GET /quizzes/{id}, PATCH, DELETE, GET /quizzes/{id}/questions, POST /quizzes/{id}/questions
- Attempts: POST /quizzes/{id}/attempts {answers} → {score, passed, attempt_id}, GET /attempts, GET /attempts/{id}
- Progress: GET /progress/me, POST /progress {course_id, lesson_id, progress_percent, completed}

### Diagnostics
- GET /diagnostics?component_id&status&severity&reported_by
- POST /diagnostics {component_id, title, description, ai_analysis, severity, status}
- GET /diagnostics/{id}
- PATCH /diagnostics/{id} {status, technician_action, resolution_notes}
- DELETE /diagnostics/{id} (admin)
- Maintenance: GET /maintenance, POST /maintenance, GET /maintenance/{id}, PATCH /maintenance/{id}
- Work Orders: GET /work-orders, POST /work-orders, GET /work-orders/{id}, PATCH /work-orders/{id}

### Sync
- POST /sync/upload {device_id, transactions: [{transaction_id, entity_type, entity_id, operation, payload, created_at, version}]} → {accepted: [], conflicts: [{transaction_id, server_version, conflict_data}], failed: []}
- GET /sync/download?device_id&last_sync_at → {transactions: [server changes], server_time}
- POST /sync/resolve-conflict {transaction_id, resolution_strategy, merged_payload}
- GET /sync/status?device_id → {pending, conflicts, failed, last_sync_at}

### Audit
- GET /audit/logs?user_id&event&entity_type&from&to (admin or own)
- POST /audit/logs (client upload offline logs during sync)

### Search
- GET /search?q=sonar&entity_type=component → aggregated results

### Updates
- GET /updates/manifest?current_versions → {updates: [{entity_type, entity_id, version, file_url, checksum, mandatory, changelog}], server_time}
- GET /updates/check

### Admin
- GET /admin/stats, /admin/devices, /admin/sync-queue, /admin/storage

### Health
- GET /health, GET /health/detailed

## Local AI Engine (127.0.0.1:8001)
- POST /analyze {text, language?, user_id?, request_id?} → {request_id, component_id, component_name, mesh_id, fault, severity, confidence, evidence, recommended_actions, warnings, timestamp, processing_time_ms}
- POST /search {query, top_k} → {results: [{id, title, content, score, metadata}]}
- GET /health → {status, version, knowledge_base_count, model_loaded}
- GET /knowledge/components, GET /knowledge/components/{component_id}

## Security
- All except /auth/login and /health require Bearer
- RBAC via require_role dependency
- Rate limiting 100/min IP, 1000/min user (slowapi)
- Pydantic validation, ORM prevents SQL injection
- Audit log for mutating operations

## Schemas
- Pydantic models with id UUID, created_at, updated_at, version
- Consistent error structure
