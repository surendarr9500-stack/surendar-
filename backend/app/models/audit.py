from sqlalchemy import Column, String, DateTime, Text
from datetime import datetime
import uuid
from ..db.session import Base

class AuditLog(Base):
    __tablename__ = "audit_logs"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    user_id = Column(String, nullable=False, index=True)
    device_id = Column(String, nullable=False)
    event = Column(String, nullable=False, index=True)
    entity_type = Column(String, nullable=True)
    entity_id = Column(String, nullable=True)
    result = Column(String, nullable=False)
    extra_metadata = Column('metadata', Text, nullable=True)
    ip_address = Column(String, nullable=True)
    sync_status = Column(String, default="SYNCED")
