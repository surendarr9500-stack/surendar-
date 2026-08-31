from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from ...db.session import get_db
from ...models.user import User, Device, Session as UserSession
from ...schemas.auth import LoginRequest, RefreshRequest, LogoutRequest, TokenResponse, UserCreate, UserResponse
from ...core.security import verify_password, get_password_hash, create_access_token, create_refresh_token, verify_token, get_current_user_token, require_role, ROLE_ADMIN
from ...core.config import settings
import hashlib
import uuid

router = APIRouter()

@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == request.username).first()
    if not user or not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    if not user.is_active:
        raise HTTPException(status_code=403, detail="User account is disabled")
    
    # Update last login
    user.last_login_at = datetime.utcnow()
    db.commit()
    
    # Register or update device
    device = db.query(Device).filter(Device.id == request.device_id).first()
    if not device:
        device = Device(
            id=request.device_id,
            user_id=user.id,
            device_name=request.device_name,
            platform=request.platform,
            registered_at=datetime.utcnow(),
            last_sync_at=datetime.utcnow()
        )
        db.add(device)
    else:
        device.last_sync_at = datetime.utcnow()
        device.user_id = user.id
    db.commit()
    
    # Create tokens
    token_data = {
        "sub": user.id,
        "username": user.username,
        "role": user.role,
        "device_id": request.device_id,
    }
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)
    
    # Store refresh token hash
    refresh_hash = hashlib.sha256(refresh_token.encode()).hexdigest()
    # Delete old sessions for this device
    db.query(UserSession).filter(UserSession.device_id == request.device_id).delete()
    session = UserSession(
        id=str(uuid.uuid4()),
        user_id=user.id,
        device_id=request.device_id,
        refresh_token_hash=refresh_hash,
        expires_at=datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
    )
    db.add(session)
    db.commit()
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user={
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "role": user.role,
            "display_name": user.display_name,
        },
        device={
            "id": device.id,
            "device_name": device.device_name,
            "platform": device.platform,
        }
    )

@router.post("/refresh")
async def refresh_token(request: RefreshRequest, db: Session = Depends(get_db)):
    try:
        payload = verify_token(request.refresh_token)
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))
    
    refresh_hash = hashlib.sha256(request.refresh_token.encode()).hexdigest()
    session = db.query(UserSession).filter(
        UserSession.device_id == request.device_id,
        UserSession.refresh_token_hash == refresh_hash
    ).first()
    
    if not session or session.expires_at < datetime.utcnow():
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")
    
    user = db.query(User).filter(User.id == payload.get("sub")).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found or inactive")
    
    token_data = {
        "sub": user.id,
        "username": user.username,
        "role": user.role,
        "device_id": request.device_id,
    }
    new_access_token = create_access_token(token_data)
    new_refresh_token = create_refresh_token(token_data)
    
    # Update session
    session.refresh_token_hash = hashlib.sha256(new_refresh_token.encode()).hexdigest()
    session.expires_at = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    db.commit()
    
    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }

@router.post("/logout")
async def logout(request: LogoutRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    db.query(UserSession).filter(UserSession.device_id == request.device_id).delete()
    db.commit()
    return {"message": "Logged out successfully"}

@router.post("/register-device")
async def register_device(device_id: str, device_name: str, platform: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    device = db.query(Device).filter(Device.id == device_id).first()
    if not device:
        device = Device(
            id=device_id,
            user_id=user_id,
            device_name=device_name,
            platform=platform,
        )
        db.add(device)
        db.commit()
    return {"message": "Device registered", "device_id": device_id}

@router.get("/me", response_model=UserResponse)
async def get_me(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == payload.get("sub")).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
