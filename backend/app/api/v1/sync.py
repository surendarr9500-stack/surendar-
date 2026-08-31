from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from ...db.session import get_db
from ...models.sync import SyncTransaction
from ...models.diagnostic import Diagnostic
from ...models.component import Component
from ...models.course import Course, Progress, QuizAttempt
from ...schemas.sync import SyncUploadRequest, SyncUploadResponse, SyncConflict, SyncFailed, SyncDownloadResponse, ConflictResolutionRequest
from ...core.security import get_current_user_token
import json
import uuid

router = APIRouter()

@router.post("/upload", response_model=SyncUploadResponse)
async def sync_upload(request: SyncUploadRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    accepted = []
    conflicts = []
    failed = []
    
    for tx in request.transactions:
        # Check if already processed
        existing_tx = db.query(SyncTransaction).filter(SyncTransaction.transaction_id == tx.transaction_id).first()
        if existing_tx:
            accepted.append(tx.transaction_id)
            continue
        
        try:
            # Conflict detection based on version
            server_version = 1
            # For diagnostics, check existing entity version
            if tx.entity_type == "diagnostic":
                existing_entity = db.query(Diagnostic).filter(Diagnostic.id == tx.entity_id).first()
                if existing_entity:
                    server_version = existing_entity.version
                    if tx.version < server_version:
                        # Conflict
                        conflicts.append(SyncConflict(
                            transaction_id=tx.transaction_id,
                            server_version=server_version,
                            conflict_data={
                                "server_payload": {
                                    "id": existing_entity.id,
                                    "status": existing_entity.status,
                                    "version": existing_entity.version,
                                    "updated_at": existing_entity.updated_at.isoformat() if existing_entity.updated_at else None,
                                },
                                "client_payload": tx.payload,
                            },
                            message=f"Version conflict: client {tx.version} < server {server_version}"
                        ))
                        # Save conflict transaction
                        sync_tx = SyncTransaction(
                            transaction_id=tx.transaction_id,
                            device_id=request.device_id,
                            user_id=user_id,
                            entity_type=tx.entity_type,
                            entity_id=tx.entity_id,
                            operation=tx.operation,
                            payload=tx.payload,
                            client_version=tx.version,
                            server_version=server_version,
                            status="CONFLICT",
                            conflict_data={
                                "server_version": server_version,
                                "server_payload": {"status": existing_entity.status, "version": existing_entity.version}
                            },
                            created_at=tx.created_at,
                            processed_at=datetime.utcnow(),
                        )
                        db.add(sync_tx)
                        db.commit()
                        continue
            
            # Apply transaction
            if tx.entity_type == "diagnostic":
                if tx.operation == "CREATE":
                    # Check if exists (idempotent)
                    existing = db.query(Diagnostic).filter(Diagnostic.id == tx.entity_id).first()
                    if not existing:
                        diag_data = tx.payload
                        diag = Diagnostic(
                            id=tx.entity_id,
                            component_id=diag_data.get("component_id", "UNKNOWN"),
                            reported_by=user_id,
                            title=diag_data.get("title", "Untitled"),
                            description=diag_data.get("description", ""),
                            ai_analysis=json.dumps(diag_data.get("ai_analysis")) if diag_data.get("ai_analysis") else None,
                            severity=diag_data.get("severity", "MEDIUM"),
                            status=diag_data.get("status", "OPEN"),
                            recommended_actions=json.dumps(diag_data.get("recommended_actions", [])),
                            version=tx.version,
                        )
                        db.add(diag)
                elif tx.operation == "UPDATE":
                    existing = db.query(Diagnostic).filter(Diagnostic.id == tx.entity_id).first()
                    if existing:
                        payload_data = tx.payload
                        if "status" in payload_data:
                            existing.status = payload_data["status"]
                        if "technician_action" in payload_data:
                            existing.technician_action = payload_data["technician_action"]
                        if "resolution_notes" in payload_data:
                            existing.resolution_notes = payload_data["resolution_notes"]
                        if "severity" in payload_data:
                            existing.severity = payload_data["severity"]
                        existing.version = tx.version
                        existing.updated_at = datetime.utcnow()
                    else:
                        raise Exception(f"Diagnostic {tx.entity_id} not found for update")
                elif tx.operation == "DELETE":
                    existing = db.query(Diagnostic).filter(Diagnostic.id == tx.entity_id).first()
                    if existing:
                        db.delete(existing)
            
            # For other entity types, generic handling (progress, quiz_attempts, etc.)
            # For now, accept and store transaction
            
            # Save sync transaction as processed
            sync_tx = SyncTransaction(
                transaction_id=tx.transaction_id,
                device_id=request.device_id,
                user_id=user_id,
                entity_type=tx.entity_type,
                entity_id=tx.entity_id,
                operation=tx.operation,
                payload=tx.payload,
                client_version=tx.version,
                server_version=server_version + 1 if 'server_version' in locals() else tx.version,
                status="PROCESSED",
                created_at=tx.created_at,
                processed_at=datetime.utcnow(),
            )
            db.add(sync_tx)
            db.commit()
            accepted.append(tx.transaction_id)
            
        except Exception as e:
            failed.append(SyncFailed(transaction_id=tx.transaction_id, error=str(e)))
            # Save failed transaction
            try:
                sync_tx = SyncTransaction(
                    transaction_id=tx.transaction_id,
                    device_id=request.device_id,
                    user_id=user_id,
                    entity_type=tx.entity_type,
                    entity_id=tx.entity_id,
                    operation=tx.operation,
                    payload=tx.payload,
                    client_version=tx.version,
                    server_version=1,
                    status="FAILED",
                    conflict_data={"error": str(e)},
                    created_at=tx.created_at,
                    processed_at=datetime.utcnow(),
                )
                db.add(sync_tx)
                db.commit()
            except:
                db.rollback()
    
    return SyncUploadResponse(accepted=accepted, conflicts=conflicts, failed=failed)

@router.get("/download", response_model=SyncDownloadResponse)
async def sync_download(
    device_id: str,
    last_sync_at: str = None,
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    user_id = payload.get("sub")
    last_sync_dt = None
    if last_sync_at:
        try:
            last_sync_dt = datetime.fromisoformat(last_sync_at.replace("Z", "+00:00"))
        except:
            last_sync_dt = None
    
    transactions = []
    
    # Get diagnostics updated since last_sync_at
    query = db.query(Diagnostic)
    if last_sync_dt:
        query = query.filter(Diagnostic.updated_at > last_sync_dt)
    # Limit to recent 100 for demo
    diagnostics = query.order_by(Diagnostic.updated_at.desc()).limit(100).all()
    
    for diag in diagnostics:
        transactions.append({
            "entity_type": "diagnostic",
            "entity_id": diag.id,
            "operation": "UPDATE",
            "payload": {
                "id": diag.id,
                "component_id": diag.component_id,
                "title": diag.title,
                "description": diag.description,
                "status": diag.status,
                "severity": diag.severity,
                "version": diag.version,
                "updated_at": diag.updated_at.isoformat() if diag.updated_at else None,
            },
            "version": diag.version,
            "updated_at": diag.updated_at or datetime.utcnow(),
        })
    
    # Get components updated
    comp_query = db.query(Component)
    if last_sync_dt:
        comp_query = comp_query.filter(Component.updated_at > last_sync_dt)
    components = comp_query.limit(50).all()
    for comp in components:
        transactions.append({
            "entity_type": "component",
            "entity_id": comp.id,
            "operation": "UPDATE",
            "payload": {
                "id": comp.id,
                "name": comp.name,
                "status": comp.status,
                "version": comp.version,
            },
            "version": comp.version,
            "updated_at": comp.updated_at or datetime.utcnow(),
        })
    
    return SyncDownloadResponse(
        transactions=transactions,
        server_time=datetime.utcnow()
    )

@router.post("/resolve-conflict")
async def resolve_conflict(request: ConflictResolutionRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    tx = db.query(SyncTransaction).filter(SyncTransaction.transaction_id == request.transaction_id).first()
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    if request.resolution_strategy == "use_server":
        tx.status = "PROCESSED"
        tx.processed_at = datetime.utcnow()
        db.commit()
        return {"message": "Resolved using server version"}
    elif request.resolution_strategy == "use_local":
        # Re-apply client payload
        tx.status = "PENDING"
        # In real implementation, re-apply logic
        db.commit()
        return {"message": "Resolved using local version, will re-sync"}
    elif request.resolution_strategy == "merge" and request.merged_payload:
        tx.payload = request.merged_payload
        tx.status = "PENDING"
        db.commit()
        return {"message": "Merged and queued for re-sync"}
    else:
        raise HTTPException(status_code=400, detail="Invalid resolution strategy")

@router.get("/status")
async def sync_status(device_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    pending_count = db.query(SyncTransaction).filter(SyncTransaction.device_id == device_id, SyncTransaction.status == "PENDING").count()
    conflict_count = db.query(SyncTransaction).filter(SyncTransaction.device_id == device_id, SyncTransaction.status == "CONFLICT").count()
    failed_count = db.query(SyncTransaction).filter(SyncTransaction.device_id == device_id, SyncTransaction.status == "FAILED").count()
    last_sync = db.query(SyncTransaction).filter(SyncTransaction.device_id == device_id).order_by(SyncTransaction.processed_at.desc()).first()
    
    return {
        "device_id": device_id,
        "pending": pending_count,
        "conflicts": conflict_count,
        "failed": failed_count,
        "last_sync_at": last_sync.processed_at.isoformat() if last_sync and last_sync.processed_at else None,
    }
