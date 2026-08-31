from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class LoginRequest(BaseModel):
    username: str
    password: str
    device_id: str
    device_name: str
    platform: str = "unknown"

class RefreshRequest(BaseModel):
    refresh_token: str
    device_id: str

class LogoutRequest(BaseModel):
    device_id: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
    user: dict
    device: dict

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    role: str = "field_engineer"
    display_name: str

class UserResponse(BaseModel):
    id: str
    username: str
    email: str
    role: str
    display_name: str
    is_active: bool
    last_login_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    role: Optional[str] = None
    display_name: Optional[str] = None
    is_active: Optional[bool] = None
