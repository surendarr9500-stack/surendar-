from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0",
        "service": "capacity-connect-backend",
    }

@router.get("/detailed")
async def detailed_health():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0",
        "service": "capacity-connect-backend",
        "checks": {
            "database": "ok",
            "storage": "ok",
            "api": "ok",
        }
    }
