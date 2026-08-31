from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime

class DiagnosticCreate(BaseModel):
    component_id: str
    title: str
    description: str
    ai_analysis: Optional[Dict[str, Any]] = None
    fault_code: Optional[str] = None
    severity: str = "MEDIUM"
    status: str = "OPEN"
    recommended_actions: Optional[List[str]] = None

class DiagnosticUpdate(BaseModel):
    status: Optional[str] = None
    technician_action: Optional[str] = None
    resolution_notes: Optional[str] = None
    severity: Optional[str] = None

class DiagnosticResponse(BaseModel):
    id: str
    component_id: str
    reported_by: str
    title: str
    description: str
    ai_analysis: Optional[Dict[str, Any]] = None
    fault_code: Optional[str] = None
    severity: str
    status: str
    recommended_actions: List[str] = []
    technician_action: Optional[str] = None
    resolution_notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    version: int
    
    class Config:
        from_attributes = True

class MaintenanceCreate(BaseModel):
    component_id: str
    diagnostic_id: Optional[str] = None
    type: str
    description: str
    performed_by: str
    next_due: Optional[datetime] = None

class MaintenanceResponse(BaseModel):
    id: str
    component_id: str
    diagnostic_id: Optional[str] = None
    type: str
    description: str
    performed_by: str
    performed_at: datetime
    next_due: Optional[datetime] = None
    
    class Config:
        from_attributes = True
