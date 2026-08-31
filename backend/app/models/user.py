from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from ..db.session import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    username = Column(String, unique=True, nullable=False, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    role = Column(String, nullable=False, default="field_engineer")
    display_name = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    last_login_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Device(Base):
    __tablename__ = "devices"
    
    id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=True)
    device_name = Column(String, nullable=False)
    platform = Column(String, nullable=False)
    registered_at = Column(DateTime, default=datetime.utcnow)
    last_sync_at = Column(DateTime, nullable=True)

class Session(Base):
    __tablename__ = "sessions"
    
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    device_id = Column(String, ForeignKey("devices.id"), nullable=False)
    refresh_token_hash = Column(String, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_offline_session = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
