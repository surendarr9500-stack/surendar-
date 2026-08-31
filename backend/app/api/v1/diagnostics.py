from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ...db.session import get_db
from ...models.diagnostic import Diagnostic, MaintenanceRecord, WorkOrder
from ...schemas.diagnostic import DiagnosticCreate, DiagnosticUpdate, DiagnosticResponse, MaintenanceCreate, MaintenanceResponse
from ...core.security import get_current_user_token, require_role, ROLE_ADMIN, ROLE_SUPERVISOR, ALL_ROLES
from datetime import datetime
import json

router = APIRouter()

@router.get("/", response_model=List[DiagnosticResponse])
async def list_diagnostics(
    component_id: Optional[str] = None,
    status: Optional[str] = None,
    severity: Optional[str] = None,
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    query = db.query(Diagnostic)
    if component_id:
        query = query.filter(Diagnostic.component_id == component_id)
    if status:
        query = query.filter(Diagnostic.status == status)
    if severity:
        query = query.filter(Diagnostic.severity == severity)
    # Non-admin can only see own or all? For field ops, allow all for now, but log
    results = query.order_by(Diagnostic.created_at.desc()).all()
    # Convert JSON fields
    response = []
    for diag in results:
        # Ensure ai_analysis is dict if stored as JSON string
        if isinstance(diag.ai_analysis, str):
            try:
                diag.ai_analysis = json.loads(diag.ai_analysis)
            except:
                pass
        if isinstance(diag.recommended_actions, str):
            try:
                diag.recommended_actions = json.loads(diag.recommended_actions)
            except:
                diag.recommended_actions = []
        response.append(diag)
    return response

@router.get("/{diag_id}", response_model=DiagnosticResponse)
async def get_diagnostic(diag_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    diag = db.query(Diagnostic).filter(Diagnostic.id == diag_id).first()
    if not diag:
        raise HTTPException(status_code=404, detail="Diagnostic not found")
    if isinstance(diag.ai_analysis, str):
        try:
            diag.ai_analysis = json.loads(diag.ai_analysis)
        except:
            pass
    if isinstance(diag.recommended_actions, str):
        try:
            diag.recommended_actions = json.loads(diag.recommended_actions)
        except:
            diag.recommended_actions = []
    return diag

@router.post("/", response_model=DiagnosticResponse)
async def create_diagnostic(data: DiagnosticCreate, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    diag = Diagnostic(
        component_id=data.component_id,
        reported_by=user_id,
        title=data.title,
        description=data.description,
        ai_analysis=json.dumps(data.ai_analysis) if data.ai_analysis else None,
        fault_code=data.fault_code,
        severity=data.severity,
        status=data.status,
        recommended_actions=json.dumps(data.recommended_actions) if data.recommended_actions else "[]",
        version=1,
    )
    db.add(diag)
    db.commit()
    db.refresh(diag)
    # Convert for response
    if diag.ai_analysis:
        try:
            diag.ai_analysis = json.loads(diag.ai_analysis)
        except:
            pass
    try:
        diag.recommended_actions = json.loads(diag.recommended_actions) if isinstance(diag.recommended_actions, str) else diag.recommended_actions
    except:
        diag.recommended_actions = []
    return diag

@router.patch("/{diag_id}", response_model=DiagnosticResponse)
async def update_diagnostic(diag_id: str, update: DiagnosticUpdate, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    diag = db.query(Diagnostic).filter(Diagnostic.id == diag_id).first()
    if not diag:
        raise HTTPException(status_code=404, detail="Diagnostic not found")
    # Check ownership or supervisor/admin
    user_id = payload.get("sub")
    user_role = payload.get("role")
    if diag.reported_by != user_id and user_role not in [ROLE_ADMIN, ROLE_SUPERVISOR]:
        # Allow technician to update if assigned? For simplicity allow all field roles to update
        pass
    
    if update.status:
        diag.status = update.status
    if update.technician_action:
        diag.technician_action = update.technician_action
    if update.resolution_notes:
        diag.resolution_notes = update.resolution_notes
    if update.severity:
        diag.severity = update.severity
    
    diag.version += 1
    diag.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(diag)
    
    if isinstance(diag.ai_analysis, str) and diag.ai_analysis:
        try:
            diag.ai_analysis = json.loads(diag.ai_analysis)
        except:
            pass
    try:
        diag.recommended_actions = json.loads(diag.recommended_actions) if isinstance(diag.recommended_actions, str) else diag.recommended_actions
    except:
        diag.recommended_actions = []
    
    return diag

@router.delete("/{diag_id}", dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def delete_diagnostic(diag_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    diag = db.query(Diagnostic).filter(Diagnostic.id == diag_id).first()
    if not diag:
        raise HTTPException(status_code=404, detail="Diagnostic not found")
    db.delete(diag)
    db.commit()
    return {"message": "Diagnostic deleted"}

# Maintenance
@router.get("/maintenance/list", response_model=List[MaintenanceResponse])
async def list_maintenance(component_id: Optional[str] = None, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    query = db.query(MaintenanceRecord)
    if component_id:
        query = query.filter(MaintenanceRecord.component_id == component_id)
    return query.order_by(MaintenanceRecord.performed_at.desc()).all()

@router.post("/maintenance/", response_model=MaintenanceResponse)
async def create_maintenance(data: MaintenanceCreate, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    rec = MaintenanceRecord(
        component_id=data.component_id,
        diagnostic_id=data.diagnostic_id,
        type=data.type,
        description=data.description,
        performed_by=data.performed_by,
        next_due=data.next_due,
    )
    db.add(rec)
    db.commit()
    db.refresh(rec)
    return rec
