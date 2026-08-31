from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ...db.session import get_db
from ...models.component import Component, ComponentFault, DigitalTwinModel
from ...schemas.component import ComponentCreate, ComponentUpdate, ComponentResponse, ComponentFaultResponse
from ...core.security import get_current_user_token, require_role, ROLE_ADMIN, ALL_ROLES
from datetime import datetime

router = APIRouter()

@router.get("/", response_model=List[ComponentResponse])
async def list_components(
    category: Optional[str] = None,
    status: Optional[str] = None,
    search: Optional[str] = None,
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    query = db.query(Component)
    if category:
        query = query.filter(Component.category == category)
    if status:
        query = query.filter(Component.status == status)
    if search:
        query = query.filter(
            (Component.name.ilike(f"%{search}%")) |
            (Component.id.ilike(f"%{search}%")) |
            (Component.description.ilike(f"%{search}%"))
        )
    return query.all()

@router.get("/{component_id}", response_model=ComponentResponse)
async def get_component(component_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    comp = db.query(Component).filter(Component.id == component_id).first()
    if not comp:
        raise HTTPException(status_code=404, detail="Component not found")
    return comp

@router.post("/", response_model=ComponentResponse, dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def create_component(comp_data: ComponentCreate, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    existing = db.query(Component).filter((Component.id == comp_data.id) | (Component.mesh_id == comp_data.mesh_id)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Component with same ID or Mesh ID already exists")
    comp = Component(**comp_data.model_dump())
    db.add(comp)
    db.commit()
    db.refresh(comp)
    return comp

@router.patch("/{component_id}", response_model=ComponentResponse, dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def update_component(component_id: str, update_data: ComponentUpdate, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    comp = db.query(Component).filter(Component.id == component_id).first()
    if not comp:
        raise HTTPException(status_code=404, detail="Component not found")
    for field, value in update_data.model_dump(exclude_unset=True).items():
        setattr(comp, field, value)
    comp.version += 1
    comp.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(comp)
    return comp

@router.delete("/{component_id}", dependencies=[Depends(require_role([ROLE_ADMIN]))])
async def delete_component(component_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    comp = db.query(Component).filter(Component.id == component_id).first()
    if not comp:
        raise HTTPException(status_code=404, detail="Component not found")
    db.delete(comp)
    db.commit()
    return {"message": "Component deleted"}

@router.get("/{component_id}/faults", response_model=List[ComponentFaultResponse])
async def get_component_faults(component_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    faults = db.query(ComponentFault).filter(ComponentFault.component_id == component_id).all()
    return faults

@router.post("/{component_id}/status")
async def update_component_status(component_id: str, status: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    comp = db.query(Component).filter(Component.id == component_id).first()
    if not comp:
        raise HTTPException(status_code=404, detail="Component not found")
    comp.status = status
    comp.version += 1
    comp.updated_at = datetime.utcnow()
    db.commit()
    return {"message": "Status updated", "status": status}
