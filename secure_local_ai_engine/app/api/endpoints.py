from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
import uuid
import time
from ..core.pipeline import TroubleshootingPipeline
from ..knowledge.retrieval import KnowledgeRetrieval
from ..core.component_registry import COMPONENT_INFO

router = APIRouter()

# Singleton pipeline
knowledge_retrieval = KnowledgeRetrieval()
pipeline = TroubleshootingPipeline(knowledge_retrieval=knowledge_retrieval)

class AnalyzeRequest(BaseModel):
    text: str
    language: Optional[str] = "en"
    user_id: Optional[str] = None
    request_id: Optional[str] = None

class AnalyzeResponse(BaseModel):
    request_id: str
    component_id: str
    component_name: str
    mesh_id: str
    fault: str
    severity: str
    confidence: float
    evidence: List[Dict[str, Any]]
    recommended_actions: List[str]
    warnings: List[str]
    timestamp: str
    processing_time_ms: Optional[int] = None

class SearchRequest(BaseModel):
    query: str
    top_k: int = 5

class SearchResponse(BaseModel):
    results: List[Dict[str, Any]]
    query: str
    count: int

@router.post("/analyze", response_model=AnalyzeResponse)
async def analyze_fault(request: AnalyzeRequest):
    if not request.text or len(request.text.strip()) == 0:
        raise HTTPException(status_code=400, detail="Text input is required")
    
    if len(request.text) > 2000:
        raise HTTPException(status_code=400, detail="Text input too long, max 2000 characters")
    
    try:
        result = pipeline.analyze(
            text=request.text,
            request_id=request.request_id or str(uuid.uuid4())
        )
        
        # Return structured JSON per spec
        return AnalyzeResponse(
            request_id=result["request_id"],
            component_id=result["component_id"],
            component_name=result["component_name"],
            mesh_id=result["mesh_id"],
            fault=result["fault"],
            severity=result["severity"],
            confidence=result["confidence"],
            evidence=result["evidence"],
            recommended_actions=result["recommended_actions"],
            warnings=result["warnings"],
            timestamp=result["timestamp"],
            processing_time_ms=result.get("processing_time_ms")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@router.post("/search", response_model=SearchResponse)
async def search_knowledge(request: SearchRequest):
    if not request.query:
        raise HTTPException(status_code=400, detail="Query is required")
    
    results = knowledge_retrieval.search(request.query, top_k=request.top_k)
    return SearchResponse(
        results=results,
        query=request.query,
        count=len(results)
    )

@router.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "version": "1.0.0",
        "service": "secure_local_ai_engine",
        "knowledge_base_count": len(knowledge_retrieval.knowledge_base),
        "model_loaded": False,
        "pipeline": "deterministic TF-IDF + keyword matching",
        "host": "127.0.0.1",
        "port": 8001,
    }

@router.get("/knowledge/components")
async def list_components():
    return {
        "components": [
            {
                "id": comp_id,
                "name": info["name"],
                "mesh_id": info["mesh_id"],
                "category": info["category"],
            }
            for comp_id, info in COMPONENT_INFO.items()
        ]
    }

@router.get("/knowledge/components/{component_id}")
async def get_component_knowledge(component_id: str):
    if component_id not in COMPONENT_INFO:
        raise HTTPException(status_code=404, detail="Component not found")
    
    info = COMPONENT_INFO[component_id]
    knowledge = knowledge_retrieval.get_by_component(component_id)
    
    return {
        "component": {
            "id": component_id,
            **info
        },
        "knowledge": knowledge,
        "count": len(knowledge)
    }

@router.get("/logs")
async def get_logs():
    # In production, return recent logs from file
    return {
        "logs": [
            {"timestamp": datetime.utcnow().isoformat() + "Z", "level": "INFO", "message": "AI Engine running on 127.0.0.1:8001"},
        ]
    }
