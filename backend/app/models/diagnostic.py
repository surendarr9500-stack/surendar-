from sqlalchemy import Column, String, DateTime, Text, Integer, Float, ForeignKey
from datetime import datetime
import uuid
from ..db.session import Base

class Diagnostic(Base):
    __tablename__ = "diagnostics"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    component_id = Column(String, nullable=False, index=True)
    reported_by = Column(String, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    ai_analysis = Column(Text, nullable=True)  # JSON
    fault_code = Column(String, nullable=True)
    severity = Column(String, default="MEDIUM")
    status = Column(String, default="OPEN")
    recommended_actions = Column(Text, default="[]")
    technician_action = Column(Text, nullable=True)
    resolution_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    sync_status = Column(String, default="SYNCED")
    version = Column(Integer, default=1)

class MaintenanceRecord(Base):
    __tablename__ = "maintenance_records"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    component_id = Column(String, nullable=False)
    diagnostic_id = Column(String, nullable=True)
    type = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    performed_by = Column(String, nullable=False)
    performed_at = Column(DateTime, default=datetime.utcnow)
    next_due = Column(DateTime, nullable=True)
    attachments = Column(Text, default="[]")
    sync_status = Column(String, default="SYNCED")

class WorkOrder(Base):
    __tablename__ = "work_orders"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    component_id = Column(String, nullable=False)
    diagnostic_id = Column(String, nullable=True)
    assigned_to = Column(String, nullable=True)
    priority = Column(String, default="MEDIUM")
    status = Column(String, default="OPEN")
    due_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Attachment(Base):
    __tablename__ = "attachments"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    entity_type = Column(String, nullable=False)
    entity_id = Column(String, nullable=False)
    file_path = Column(String, nullable=True)
    file_url = Column(String, nullable=True)
    file_type = Column(String, nullable=False)
    file_size = Column(Integer, default=0)
    checksum = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    sync_status = Column(String, default="SYNCED")
