from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class ComponentBase(BaseModel):
    id: str
    name: str
    category: str
    description: str
    manufacturer: str
    model: str
    mesh_id: str
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0
    status: str = "UNKNOWN"
    installation_location: str
    possible_faults: List[str] = []
    maintenance_procedures: List[str] = []
    training_references: List[str] = []
    documentation_references: List[str] = []
    last_inspection: Optional[datetime] = None
    next_maintenance: Optional[datetime] = None

class ComponentCreate(ComponentBase):
    pass

class ComponentUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    manufacturer: Optional[str] = None
    model: Optional[str] = None
    mesh_id: Optional[str] = None
    x: Optional[float] = None
    y: Optional[float] = None
    z: Optional[float] = None
    status: Optional[str] = None
    installation_location: Optional[str] = None
    possible_faults: Optional[List[str]] = None
    maintenance_procedures: Optional[List[str]] = None
    last_inspection: Optional[datetime] = None
    next_maintenance: Optional[datetime] = None

class ComponentResponse(ComponentBase):
    version: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class ComponentFaultResponse(BaseModel):
    id: str
    component_id: str
    fault_code: str
    fault_name: str
    description: str
    severity: str
    keywords: List[str] = []
    
    class Config:
        from_attributes = True
