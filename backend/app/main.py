from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from .core.config import settings
from .db.session import init_db
from .api.v1 import auth, components, diagnostics, sync, courses, admin, health, digital_twin, media
import structlog

# Setup logger
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title="Capacity Connect Backend",
    description="Secure operational platform for MoES field personnel - SIH 2026 SIH26075",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix=f"{settings.API_V1_PREFIX}/health", tags=["health"])
app.include_router(auth.router, prefix=f"{settings.API_V1_PREFIX}/auth", tags=["auth"])
app.include_router(components.router, prefix=f"{settings.API_V1_PREFIX}/components", tags=["components"])
app.include_router(diagnostics.router, prefix=f"{settings.API_V1_PREFIX}/diagnostics", tags=["diagnostics"])
app.include_router(sync.router, prefix=f"{settings.API_V1_PREFIX}/sync", tags=["sync"])
app.include_router(courses.router, prefix=f"{settings.API_V1_PREFIX}/courses", tags=["courses"])
app.include_router(admin.router, prefix=f"{settings.API_V1_PREFIX}/admin", tags=["admin"])
app.include_router(digital_twin.router, prefix=f"{settings.API_V1_PREFIX}/digital-twin", tags=["digital-twin"])
app.include_router(media.router, prefix=f"{settings.API_V1_PREFIX}/media", tags=["media"])
app.include_router(media.router, prefix=f"{settings.API_V1_PREFIX}/documents", tags=["documents"])

@app.on_event("startup")
async def startup_event():
    init_db()
    # Seed data if needed
    from .db.seed import seed_data
    seed_data()

@app.get("/")
async def root():
    return {
        "message": "Capacity Connect Backend - SIH 2026 SIH26075",
        "version": "1.0.0",
        "docs": "/docs",
        "health": f"{settings.API_V1_PREFIX}/health",
    }

@app.get("/health")
async def root_health():
    return {"status": "healthy", "service": "capacity-connect"}
