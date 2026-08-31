from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.endpoints import router
from datetime import datetime

app = FastAPI(
    title="Capacity Connect - Secure Local AI Engine",
    description="Local AI processing node for offline troubleshooting. Runs on 127.0.0.1:8001. SIH 2026 SIH26075",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Local only, so allow all for Flutter client
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

@app.get("/")
async def root():
    return {
        "message": "Capacity Connect Secure Local AI Engine",
        "version": "1.0.0",
        "host": "127.0.0.1",
        "port": 8001,
        "status": "running",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "endpoints": {
            "analyze": "/analyze",
            "search": "/search",
            "health": "/health",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "service": "secure_local_ai_engine",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "version": "1.0.0",
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8001)
