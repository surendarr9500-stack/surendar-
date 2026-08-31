# Database Plan - Capacity Connect

## Local (Drift/SQLite)

### Tables
- users, devices, sessions
- components, component_faults, digital_twin_models
- courses, modules, lessons, media, documents
- quizzes, questions, quiz_attempts
- diagnostics, maintenance_records, work_orders, attachments
- progress, sync_queue, audit_logs, settings, knowledge_base

### Key Design
- components.mesh_id UNIQUE, indexed
- sync_queue: transaction_id PK UUID, device_id, user_id, entity_type, entity_id, operation, payload JSON, sync_status ENUM, retry_count, version, error_message
- audit_logs: timestamp indexed, user_id indexed, event indexed
- knowledge_base: FTS5 virtual table for search
- WAL mode, foreign_keys ON
- Encryption: SQLCipher or AES-256-GCM file encryption, keys in Secure Storage

### Seed
- 5 components: SONAR-001/Mesh_042, TELEM-001/Mesh_109, ARGO-001/Mesh_210, ECHO-001/Mesh_315, WINCH-001/Mesh_410
- 5 users: admin, field_engineer, technician, training_officer, supervisor
- Courses: Sonar Operations, Telemetry, Argo
- Knowledge: 10 chunks
- Quiz: 3 questions

## Backend (PostgreSQL + SQLAlchemy)

### Tables
Mirrors local plus:
- roles, permissions, role_permissions (RBAC)
- sync_transactions (transaction_id UNIQUE, device_id, user_id, entity_type, entity_id, operation, payload JSONB, client_version, server_version, status, conflict_data JSONB)
- content_versions, update_manifests
- audit_logs centralized

### Migrations
- Alembic for backend, Drift migrations for client
- Never modify production schemas manually

### Versioning
- Every content entity has version INT incrementing on update
- Sync uses version for conflict detection

### Backup
- Local: 3 backups in backups/ dir, WAL mode
- Cloud: PG backups + WAL archiving
- Sync queue never deleted until SYNCED
