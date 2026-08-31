from sqlalchemy import Column, String, DateTime, Text, Integer, JSON
from datetime import datetime
import uuid
from ..db.session import Base

class SyncTransaction(Base):
    __tablename__ = "sync_transactions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    transaction_id = Column(String, unique=True, nullable=False, index=True)  # client UUID
    device_id = Column(String, nullable=False)
    user_id = Column(String, nullable=False)
    entity_type = Column(String, nullable=False)
    entity_id = Column(String, nullable=False)
    operation = Column(String, nullable=False)
    payload = Column(JSON, nullable=False)
    client_version = Column(Integer, default=1)
    server_version = Column(Integer, default=1)
    status = Column(String, default="PENDING")
    conflict_data = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    processed_at = Column(DateTime, nullable=True)

class ContentVersion(Base):
    __tablename__ = "content_versions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    entity_type = Column(String, nullable=False)
    entity_id = Column(String, nullable=False)
    version = Column(Integer, default=1)
    checksum = Column(String, nullable=True)
    file_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    created_by = Column(String, nullable=True)

class UpdateManifest(Base):
    __tablename__ = "update_manifests"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    version = Column(String, nullable=False)
    entity_type = Column(String, nullable=False)
    entity_id = Column(String, nullable=True)
    changelog = Column(Text, nullable=True)
    file_url = Column(String, nullable=True)
    checksum = Column(String, nullable=True)
    mandatory = Column(String, default="false")
    created_at = Column(DateTime, default=datetime.utcnow)
