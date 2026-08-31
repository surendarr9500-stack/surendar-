# CAPACITY CONNECT - Security Architecture

## 1. Overview
Defense in depth: Local, Network, Backend, Data layers. Must meet MoES operational security.

## 2. Local Security (Edge)

### Database Encryption
- Option A: SQLCipher for Drift (encrypted SQLite)
- Option B: AES-256-GCM file encryption for DB file + sensitive columns
- Key storage: Flutter Secure Storage (Android Keystore, Windows Credential Manager)
- Key rotation: on password change, re-encrypt

### Secure Storage
- Use `flutter_secure_storage`
- Store: JWT, refresh token, encryption key, device_id, user credentials hash
- No plaintext passwords in SharedPreferences

### Application Files
- App documents directory protected by OS sandbox
- Integrity check: SHA256 for critical assets (models, knowledge base)
- Root/jailbreak detection: optional warning (not blocking for field use)

### Session Security
- Access token 15 min expiry, refresh token 7 days
- Offline session max 72h
- Auto logout on inactivity (15 min configurable)
- Session stored with device_id binding

### Device Registration
- On first login, register device via /auth/register-device
- Device_id = UUID + hardware fingerprint (hashed)
- Server tracks devices per user, max 3
- Admin can revoke device

## 3. Network Security

### HTTPS
- All cloud communication via HTTPS
- Certificate validation enabled
- Optional cert pinning for production (configurable)

### API Authentication
- Bearer JWT
- Refresh flow
- Rate limiting: slowapi, 100/min IP, 1000/min user
- CORS configured for web client

### Request Validation
- Pydantic validation on backend
- Input sanitization (max length, no script injection)
- File upload: check mime, size limit 100MB, scan filename

## 4. Backend Security

### RBAC
Roles:
- administrator: full access
- training_officer: training management, assessments, progress
- field_engineer: training, diagnostics, troubleshooting, twin
- technician: diagnostics, maintenance, twin
- supervisor: view all, approve work orders

Enforcement:
- Dependency `require_role` in FastAPI
- Never rely only on UI hiding
- Row-level: user can only edit own diagnostics unless supervisor/admin

### Password Policy
- Min 8 chars, uppercase, lowercase, number, special
- Bcrypt hashing (12 rounds)
- No plaintext storage
- Reset via admin only (for field ops)

### Token Validation
- JWT signed with HS256, secret from env
- Validate exp, iat, device_id claim
- Refresh token stored hashed in DB

### Audit Logging
- Every auth, data access, admin action logged
- Logs include timestamp, user, device, event, entity, result, metadata
- No sensitive data in logs (passwords, keys)

## 5. Data Security

### Encryption
- AES-256-GCM for sensitive fields (e.g., diagnostic notes if marked confidential)
- Key from env, not hardcoded
- IV random per encryption, stored with ciphertext
- Example:
```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
aesgcm = AESGCM(key)
nonce = os.urandom(12)
ct = aesgcm.encrypt(nonce, plaintext, associated_data)
```

### No Hardcoded Secrets
- Use .env, .env.example
- .gitignore .env
- CI/CD secrets via env vars

### Input Validation
- Pydantic models validate all inputs
- SQL injection prevented via SQLAlchemy ORM
- XSS prevented via Flutter (no innerHTML)

## 6. Offline Security

### Offline Auth Policy
- Cached password hash verified via bcrypt
- Offline JWT with reduced claims, expiry 72h
- Device must have been online within 7 days
- Audit log for offline login

### Local AI
- Binds only 127.0.0.1
- No remote access
- Input max length 2000

## 7. Digital Twin Security
- Model download requires auth
- Checksum validation
- Role check: field_engineer+ can view

## 8. Sync Security
- Sync upload requires valid JWT
- Transaction payload validated
- Device_id must match token
- Conflict resolution audit logged

## 9. Logging Security
Never log:
- passwords
- encryption keys
- raw JWT
- sensitive tokens
- confidential raw data unnecessarily

Logs:
- Use structured logging
- Rotate, max size
- Sync logs encrypted in transit

## 10. Compliance
- MoES data handling: no cloud LLM for operational data
- Local processing only for troubleshooting
- Audit trail for all maintenance actions
- Data retention policy: diagnostics kept 7 years (configurable)

## 11. Testing Security
- Unit: password hashing, encryption roundtrip, token validation
- Integration: RBAC, offline auth, device registration
- Penetration: attempt SQL injection, XSS, token replay, device spoofing
- Failure: expired token, revoked device, corrupted DB

## 12. Known Limitations (Document Honestly)
- SQLCipher integration may require custom Drift setup; if not available, use file-level AES + secure storage (documented)
- Root detection is warning only, not blocking (field devices may be rooted for operational reasons)
- Local AI has no auth beyond localhost binding (acceptable for edge)
