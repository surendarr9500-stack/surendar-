from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime

class SyncTransactionItem(BaseModel):
    transaction_id: str
    entity_type: str
    entity_id: str
    operation: str  # CREATE, UPDATE, DELETE
    payload: Dict[str, Any]
    created_at: datetime
    version: int = 1

class SyncUploadRequest(BaseModel):
    device_id: str
    transactions: List[SyncTransactionItem]

class SyncConflict(BaseModel):
    transaction_id: str
    server_version: int
    conflict_data: Dict[str, Any]
    message: str

class SyncFailed(BaseModel):
    transaction_id: str
    error: str

class SyncUploadResponse(BaseModel):
    accepted: List[str]
    conflicts: List[SyncConflict]
    failed: List[SyncFailed]

class SyncDownloadItem(BaseModel):
    entity_type: str
    entity_id: str
    operation: str
    payload: Dict[str, Any]
    version: int
    updated_at: datetime

class SyncDownloadResponse(BaseModel):
    transactions: List[SyncDownloadItem]
    server_time: datetime

class ConflictResolutionRequest(BaseModel):
    transaction_id: str
    resolution_strategy: str  # use_local, use_server, merge
    merged_payload: Optional[Dict[str, Any]] = None
