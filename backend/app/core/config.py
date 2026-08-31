from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./capacity_connect.db")
    JWT_SECRET: str = os.getenv("JWT_SECRET", "change-this-to-a-very-strong-random-secret-at-least-32-chars")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "15"))
    REFRESH_TOKEN_EXPIRE_DAYS: int = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", "7"))
    CORS_ORIGINS: str = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:5173,http://localhost:8000,http://127.0.0.1:8001")
    STORAGE_PATH: str = os.getenv("STORAGE_PATH", "./storage")
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "info")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    API_V1_PREFIX: str = "/api/v1"
    
    @property
    def cors_origins_list(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
