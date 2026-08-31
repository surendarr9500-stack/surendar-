from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ...db.session import get_db
from ...models.component import DigitalTwinModel, Component
from ...core.security import get_current_user_token
from datetime import datetime

router = APIRouter()

@router.get("/models")
async def list_models(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    models = db.query(DigitalTwinModel).all()
    return models

@router.get("/models/{mesh_id}")
async def get_model(mesh_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    model = db.query(DigitalTwinModel).filter(DigitalTwinModel.mesh_id == mesh_id).first()
    if not model:
        raise HTTPException(status_code=404, detail="Model not found")
    return model

@router.get("/state")
async def get_twin_state(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    components = db.query(Component).all()
    state = []
    for comp in components:
        state.append({
            "mesh_id": comp.mesh_id,
            "component_id": comp.id,
            "component_name": comp.name,
            "status": comp.status,
            "x": comp.x,
            "y": comp.y,
            "z": comp.z,
            "updated_at": comp.updated_at.isoformat() if comp.updated_at else None,
        })
    return {"state": state, "count": len(state), "timestamp": datetime.utcnow().isoformat()}

@router.post("/state/update")
async def update_twin_state(mesh_id: str, status: str, fault: str = None, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    comp = db.query(Component).filter(Component.mesh_id == mesh_id).first()
    if not comp:
        raise HTTPException(status_code=404, detail="Component not found for mesh")
    comp.status = status
    comp.version += 1
    comp.updated_at = datetime.utcnow()
    db.commit()
    return {"message": "State updated", "mesh_id": mesh_id, "status": status, "fault": fault}
