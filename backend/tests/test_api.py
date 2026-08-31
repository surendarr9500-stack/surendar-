import pytest
from fastapi.testclient import TestClient
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app.main import app
from app.db.session import Base, engine, SessionLocal
from app.db.seed import seed_data

client = TestClient(app)

def setup_module():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    seed_data()

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "Capacity Connect" in response.json()["message"]

def test_health():
    response = client.get("/api/v1/health/")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_login_valid():
    response = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "Field@123",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["username"] == "field_engineer"

def test_login_invalid():
    response = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "WrongPassword",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    assert response.status_code == 401

def test_components_list_requires_auth():
    response = client.get("/api/v1/components/")
    assert response.status_code == 403  # No auth header

def test_components_list_with_auth():
    # Login first
    login_resp = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "Field@123",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    token = login_resp.json()["access_token"]
    
    response = client.get("/api/v1/components/", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 5
    # Check for demo components
    ids = [c["id"] for c in data]
    assert "SONAR-001" in ids
    assert "TELEM-001" in ids

def test_sonar_component_detail():
    login_resp = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "Field@123",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    token = login_resp.json()["access_token"]
    
    response = client.get("/api/v1/components/SONAR-001", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "SONAR-001"
    assert data["mesh_id"] == "Mesh_042"
    assert data["name"] == "Sonar Transducer Array"

def test_diagnostics_create_and_list():
    login_resp = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "Field@123",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    token = login_resp.json()["access_token"]
    
    # Create diagnostic
    create_resp = client.post("/api/v1/diagnostics/", 
        headers={"Authorization": f"Bearer {token}"},
        json={
            "component_id": "SONAR-001",
            "title": "Test diagnostic",
            "description": "Sonar transducer showing abnormal vibration",
            "severity": "HIGH",
            "status": "OPEN"
        }
    )
    assert create_resp.status_code == 200
    diag_id = create_resp.json()["id"]
    
    # List diagnostics
    list_resp = client.get("/api/v1/diagnostics/", headers={"Authorization": f"Bearer {token}"})
    assert list_resp.status_code == 200
    assert len(list_resp.json()) >= 1

def test_sync_upload():
    login_resp = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "Field@123",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    token = login_resp.json()["access_token"]
    
    response = client.post("/api/v1/sync/upload",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "device_id": "test-device-123",
            "transactions": [
                {
                    "transaction_id": "test-tx-001",
                    "entity_type": "diagnostic",
                    "entity_id": "diag-test-001",
                    "operation": "CREATE",
                    "payload": {
                        "component_id": "SONAR-001",
                        "title": "Sync test",
                        "description": "Test sync upload",
                        "severity": "HIGH"
                    },
                    "created_at": "2024-02-15T10:30:00Z",
                    "version": 1
                }
            ]
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "accepted" in data
    assert "test-tx-001" in data["accepted"]

def test_sync_download():
    login_resp = client.post("/api/v1/auth/login", json={
        "username": "field_engineer",
        "password": "Field@123",
        "device_id": "test-device-123",
        "device_name": "Test Device",
        "platform": "test"
    })
    token = login_resp.json()["access_token"]
    
    response = client.get("/api/v1/sync/download?device_id=test-device-123",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "transactions" in data
    assert "server_time" in data
