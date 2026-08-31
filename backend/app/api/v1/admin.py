from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from ...db.session import get_db
from ...models.user import User, Device
from ...models.diagnostic import Diagnostic
from ...models.component import Component
from ...models.sync import SyncTransaction
from ...models.audit import AuditLog
from ...core.security import require_role, ROLE_ADMIN

router = APIRouter()

@router.get("/stats", dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def get_stats(db: Session = Depends(get_db)):
    user_count = db.query(func.count(User.id)).scalar()
    device_count = db.query(func.count(Device.id)).scalar()
    diagnostic_count = db.query(func.count(Diagnostic.id)).scalar()
    component_count = db.query(func.count(Component.id)).scalar()
    pending_sync = db.query(func.count(SyncTransaction.id)).filter(SyncTransaction.status == "PENDING").scalar()
    
    return {
        "users": user_count,
        "devices": device_count,
        "diagnostics": diagnostic_count,
        "components": component_count,
        "pending_sync": pending_sync,
    }

@router.get("/devices", dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def list_devices(db: Session = Depends(get_db)):
    devices = db.query(Device).all()
    return devices

@router.get("/sync-queue", dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def list_sync_queue(db: Session = Depends(get_db)):
    txs = db.query(SyncTransaction).order_by(SyncTransaction.created_at.desc()).limit(100).all()
    return txs

@router.get("/audit-logs", dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def list_audit_logs(db: Session = Depends(get_db)):
    logs = db.query(AuditLog).order_by(AuditLog.timestamp.desc()).limit(100).all()
    return logs
