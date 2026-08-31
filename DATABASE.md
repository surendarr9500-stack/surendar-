# CAPACITY CONNECT - Database Design

## 1. Local Database (Drift / SQLite)

### Core Tables

#### users
- id (TEXT PK UUID)
- username (TEXT UNIQUE)
- email (TEXT UNIQUE)
- password_hash (TEXT) - only for offline cache, bcrypt
- role (TEXT: administrator, training_officer, field_engineer, technician, supervisor)
- display_name
- is_active (BOOL)
- last_login_at (DATETIME)
- created_at, updated_at

#### devices
- id (TEXT PK)
- user_id FK
- device_name
- platform
- registered_at
- last_sync_at

#### sessions
- id
- user_id
- device_id
- token_hash
- expires_at
- is_offline_session (BOOL)

#### components
- id (TEXT PK e.g., SONAR-001)
- name
- category
- description
- manufacturer
- model
- mesh_id (TEXT e.g., Mesh_042)
- x, y, z (REAL - 3D coords)
- status (TEXT enum)
- installation_location
- possible_faults (JSON)
- maintenance_procedures (JSON)
- training_references (JSON)
- documentation_references (JSON)
- last_inspection (DATETIME)
- next_maintenance (DATETIME)
- version (INT)
- created_at, updated_at

#### component_faults
- id PK
- component_id FK
- fault_code
- fault_name
- description
- severity (LOW/MEDIUM/HIGH/CRITICAL)
- keywords (JSON)

#### digital_twin_models
- id PK
- component_id FK (nullable for whole vessel)
- mesh_id UNIQUE
- file_path (local)
- file_url (remote)
- version
- checksum (SHA256)
- file_size
- is_downloaded (BOOL)
- created_at, updated_at

#### courses
- id PK
- title
- description
- category
- difficulty
- duration_minutes
- version
- is_published
- created_at, updated_at
- offline_available

#### modules
- id PK
- course_id FK
- title
- order_index
- description

#### lessons
- id PK
- module_id FK
- title
- type (video/document/quiz)
- order_index
- duration_minutes
- content_path (local)
- content_url (remote)
- is_downloaded
- version
- checksum

#### media
- id PK
- lesson_id FK (nullable)
- title
- file_path
- file_url
- file_type (video/pdf/image)
- file_size
- checksum
- version
- is_downloaded
- download_progress (REAL)
- playback_position (INT seconds)
- created_at, updated_at

#### documents
- id PK
- title
- version
- category
- component_id FK nullable
- language
- file_path
- file_url
- checksum
- created_at, updated_at
- offline_available
- fts_content (for local search)

#### quizzes
- id PK
- course_id or lesson_id FK
- title
- description
- passing_score
- time_limit_minutes
- version
- is_published

#### questions
- id PK
- quiz_id FK
- question_text
- type (multiple_choice/true_false)
- options (JSON)
- correct_answer (JSON)
- explanation
- order_index
- points

#### quiz_attempts
- id PK
- quiz_id FK
- user_id FK
- score (REAL)
- max_score
- passed (BOOL)
- started_at, completed_at
- answers (JSON)
- sync_status

#### diagnostics
- id PK UUID
- component_id FK
- reported_by user_id FK
- title
- description (original fault text)
- ai_analysis (JSON - full AI response)
- fault_code
- severity
- status (OPEN/IN_PROGRESS/RESOLVED/CLOSED)
- recommended_actions (JSON)
- technician_action (TEXT)
- resolution_notes
- created_at, updated_at
- sync_status
- version

#### maintenance_records
- id PK
- component_id FK
- diagnostic_id FK nullable
- type (preventive/corrective/inspection)
- description
- performed_by
- performed_at
- next_due
- attachments (JSON)
- sync_status

#### work_orders
- id PK
- component_id FK
- diagnostic_id FK
- assigned_to
- priority
- status
- due_date
- created_at, updated_at

#### attachments
- id PK
- entity_type (diagnostic/maintenance/work_order)
- entity_id FK
- file_path
- file_url
- file_type
- file_size
- checksum
- created_at
- sync_status

#### progress
- id PK
- user_id FK
- course_id FK
- lesson_id FK nullable
- progress_percent
- completed (BOOL)
- last_accessed
- sync_status

#### sync_queue
- transaction_id PK UUID
- device_id
- user_id
- entity_type
- entity_id
- operation (CREATE/UPDATE/DELETE)
- payload (JSON TEXT)
- created_at
- updated_at
- sync_status (PENDING/SYNCING/SYNCED/FAILED/CONFLICT)
- retry_count
- version
- error_message

#### audit_logs
- id PK
- timestamp
- user_id
- device_id
- event (LOGIN, LOGOUT, DOCUMENT_ACCESS, TRAINING_COMPLETED, DIAGNOSTIC_CREATED, etc)
- entity_type
- entity_id
- result (SUCCESS/FAILURE)
- metadata (JSON)
- ip_address (nullable)
- sync_status

#### settings
- key PK
- value (TEXT)
- updated_at

#### knowledge_base
- id PK
- title
- content (TEXT)
- chunk_index
- embedding (BLOB nullable for future)
- metadata (JSON: component_id, fault_type, etc)
- source_document_id FK
- created_at
- fts (FTS5 virtual table for search)

### Indexes
- components.mesh_id UNIQUE
- components.status
- sync_queue.sync_status + created_at
- audit_logs.timestamp
- knowledge_base FTS5
- documents FTS5
- diagnostics.component_id + status

### Encryption
- DB file encrypted via SQLCipher or AES-256-GCM wrapper for sensitive columns.
- Keys in Flutter Secure Storage.

## 2. Backend Database (PostgreSQL + SQLAlchemy)

Mirrors local but with additional tables:

#### roles, permissions, role_permissions
- RBAC many-to-many

#### users (cloud)
- id UUID PK
- username UNIQUE
- email UNIQUE
- password_hash (bcrypt)
- role_id FK
- is_active
- created_at, updated_at

#### devices, sessions (same as local + refresh_token_hash)

#### courses, modules, lessons, media, documents, quizzes, questions, attempts, progress (same + published_by, publish logic)

#### components, component_faults, digital_twin_models (same + created_by)

#### diagnostics, maintenance_records, work_orders, attachments (same + server versioning)

#### sync_transactions
- id UUID PK
- transaction_id (client's)
- device_id
- user_id
- entity_type
- entity_id
- operation
- payload JSONB
- client_version
- server_version
- status
- conflict_data JSONB nullable
- created_at, processed_at

#### audit_logs (same as local, centralized)

#### content_versions
- id PK
- entity_type
- entity_id
- version
- checksum
- file_url
- created_at
- created_by

#### update_manifests
- id PK
- version
- entity_type
- changelog
- file_url
- checksum
- mandatory BOOL
- created_at

### Migrations
- Alembic for backend.
- Drift migrations for client.

### Seed Data
- 5 demo components: SONAR-001/Mesh_042, TELEM-001/Mesh_109, ARGO-001/Mesh_210, ECHO-001/Mesh_315, WINCH-001/Mesh_410
- Demo user accounts for each role
- Demo courses: "Sonar Operations", "Telemetry Systems", "Argo Float Maintenance"
- Knowledge base chunks for sonar, telemetry, etc.

## 3. Data Flow

```
User Action -> Drift DAO -> Local Table -> Sync Queue Entry (PENDING) -> UI Updated
Connectivity Restored -> Sync Engine -> Batch PENDING -> POST /api/v1/sync/upload -> Server Validation -> Conflict Check -> DB Write -> Ack -> Local SYNCED
```

## 4. Versioning Strategy
- Every content entity has version INT incrementing on update.
- Sync uses version for conflict detection: if client_version < server_version => CONFLICT.
- Diagnostics use field-level merge: preserve technician notes.

## 5. Backup & Recovery
- Local: periodic SQLite backup to app backup dir, WAL mode.
- Cloud: PG backups + WAL archiving.
- Sync queue never deleted until SYNCED ack; survives app kill via transaction.
