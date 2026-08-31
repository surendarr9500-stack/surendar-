from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from ...db.session import get_db
from ...models.course import Media, Document
from ...core.security import get_current_user_token, require_role, ROLE_ADMIN, ROLE_TRAINING_OFFICER
import os
import uuid
import hashlib
from datetime import datetime

router = APIRouter()

@router.get("/")
async def list_media(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    media = db.query(Media).all()
    return media

@router.get("/{media_id}")
async def get_media(media_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.id == media_id).first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    return media

@router.post("/upload", dependencies=[Depends(require_role([ROLE_ADMIN, ROLE_TRAINING_OFFICER]))])
async def upload_media(file: UploadFile = File(...), payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    # Save file
    storage_path = f"./storage/media/{uuid.uuid4()}_{file.filename}"
    os.makedirs(os.path.dirname(storage_path), exist_ok=True)
    
    content = await file.read()
    with open(storage_path, "wb") as f:
        f.write(content)
    
    checksum = hashlib.sha256(content).hexdigest()
    
    media = Media(
        id=str(uuid.uuid4()),
        title=file.filename or "Untitled",
        file_path=storage_path,
        file_url=f"/api/v1/media/{storage_path}/download",
        file_type=file.content_type or "application/octet-stream",
        file_size=len(content),
        checksum=checksum,
        version=1,
    )
    db.add(media)
    db.commit()
    db.refresh(media)
    return media

@router.get("/{media_id}/download")
async def download_media(media_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    media = db.query(Media).filter(Media.id == media_id).first()
    if not media:
        raise HTTPException(status_code=404, detail="Media not found")
    return {"file_path": media.file_path, "file_url": media.file_url, "checksum": media.checksum}

# Documents
@router.get("/documents/list")
async def list_documents(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    docs = db.query(Document).all()
    return docs

@router.get("/documents/{doc_id}")
async def get_document(doc_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    doc = db.query(Document).filter(Document.id == doc_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return doc
