from sqlalchemy import Column, String, Float, DateTime, Text, Integer, JSON
from datetime import datetime
from ..db.session import Base

class Component(Base):
    __tablename__ = "components"
    
    id = Column(String, primary_key=True)  # e.g., SONAR-001
    name = Column(String, nullable=False)
    category = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    manufacturer = Column(String, nullable=False)
    model = Column(String, nullable=False)
    mesh_id = Column(String, unique=True, nullable=False, index=True)  # e.g., Mesh_042
    x = Column(Float, default=0.0)
    y = Column(Float, default=0.0)
    z = Column(Float, default=0.0)
    status = Column(String, default="UNKNOWN")
    installation_location = Column(String, nullable=False)
    possible_faults = Column(JSON, default=list)
    maintenance_procedures = Column(JSON, default=list)
    training_references = Column(JSON, default=list)
    documentation_references = Column(JSON, default=list)
    last_inspection = Column(DateTime, nullable=True)
    next_maintenance = Column(DateTime, nullable=True)
    version = Column(Integer, default=1)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ComponentFault(Base):
    __tablename__ = "component_faults"
    
    id = Column(String, primary_key=True)
    component_id = Column(String, nullable=False, index=True)
    fault_code = Column(String, nullable=False)
    fault_name = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    severity = Column(String, nullable=False)
    keywords = Column(JSON, default=list)

class DigitalTwinModel(Base):
    __tablename__ = "digital_twin_models"
    
    id = Column(String, primary_key=True)
    component_id = Column(String, nullable=True)
    mesh_id = Column(String, unique=True, nullable=False)
    file_path = Column(String, nullable=False)
    file_url = Column(String, nullable=True)
    version = Column(Integer, default=1)
    checksum = Column(String, nullable=True)
    file_size = Column(Integer, default=0)
    is_downloaded = Column(String, default="false")  # for compatibility
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
