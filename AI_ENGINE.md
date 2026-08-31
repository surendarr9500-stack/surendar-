# CAPACITY CONNECT - AI Engine Design

## 1. Overview
Secure Local AI Engine runs on 127.0.0.1:8001, Python FastAPI. Provides troubleshooting analysis without internet. Deterministic retrieval + rule-based fallback ensures offline functionality even without LLM.

## 2. Architecture

```
User Input (text/voice)
   ↓
Normalization (lowercase, trim, remove extra spaces, unicode normalize)
   ↓
Language Detection (langdetect or simple heuristic, supports en + future hi)
   ↓
Tokenization (regex, stopword removal)
   ↓
Keyword Matching (exact keyword -> component)
   ↓
Phrase Matching (multi-word fault phrases)
   ↓
Fuzzy Matching (RapidFuzz ratio >= 80)
   ↓
Knowledge Retrieval (TF-IDF + BM25 over local knowledge_base)
   ↓
Component Identification (scoring)
   ↓
Fault Classification (from component_faults)
   ↓
Severity Estimation (rule-based: critical keywords)
   ↓
Recommended Action (from maintenance_procedures + knowledge)
   ↓
3D Component Mapping (component_id -> mesh_id)
   ↓
JSON Response
```

## 3. Knowledge Base

Structure:
- knowledge_base table: id, title, content, chunk_index, metadata (component_id, fault_type, category), source_document_id, embedding (optional)
- FTS5 index for fast retrieval
- Seed with engineering manuals, troubleshooting procedures

Pipeline for ingesting document:
```
Document
 ↓
Extraction (pdfminer, docx, txt)
 ↓
Cleaning (remove headers/footers, normalize)
 ↓
Chunking (500 tokens, 50 overlap)
 ↓
Metadata extraction (component mention, fault type)
 ↓
Indexing (FTS5 + optional embedding via sentence-transformers/all-MiniLM-L6-v2)
 ↓
Store
```

Initial knowledge covers:
- SONAR-001: vibration, casing fracture, transducer failure, calibration
- TELEM-001: signal loss, mast corrosion, transceiver failure
- ARGO-001: buoyancy, sensor drift, battery
- ECHO-001: multi-beam calibration, echo loss
- WINCH-001: hydraulic leak, cable tension, motor overheat

## 4. Component Registry for AI

Hardcoded + DB-backed mapping:

```python
COMPONENT_KEYWORDS = {
  "SONAR-001": ["sonar", "transducer", "sonar array", "acoustic", "vibration"],
  "TELEM-001": ["telemetry", "transceiver", "mast", "communication", "antenna"],
  "ARGO-001": ["argo", "float", "profiling", "buoyancy", "ctd"],
  "ECHO-001": ["echo sounder", "multi-beam", "bathymetry", "echo"],
  "WINCH-001": ["winch", "hydraulic", "cable", "deep-sea winch"]
}

FAULT_KEYWORDS = {
  "Casing fracture": ["fracture", "crack", "casing", "housing break"],
  "Abnormal vibration": ["vibration", "shaking", "abnormal", "resonance"],
  "Signal loss": ["signal loss", "no signal", "communication failure"],
  ...
}

SEVERITY_RULES = {
  "CRITICAL": ["fracture", "leak", "fire", "critical", "failure", "broken"],
  "HIGH": ["abnormal", "vibration", "overheat", "corrosion", "crack"],
  "MEDIUM": ["drift", "calibration", "degraded", "intermittent"],
  "LOW": ["minor", "inspection", "scheduled"]
}
```

## 5. Confidence Scoring (Real Algorithm, Not Fake)

Confidence = weighted sum:
- keyword_match_score (0-1) * 0.3
- phrase_match_score (0-1) * 0.3
- fuzzy_score (0-1) * 0.2
- knowledge_retrieval_score (BM25 normalized) * 0.2

Plus:
- If multiple evidences point to same component, boost +0.1
- If fault matches component's possible_faults, boost +0.1
- Cap at 0.99, floor at 0.1

Example:
Input: "Sonar transducer is showing abnormal vibration and casing fracture."
- keyword "sonar" -> SONAR-001 score 1.0
- phrase "abnormal vibration" -> matches fault 0.95
- fuzzy "casing fracture" -> 1.0
- knowledge retrieval returns SONAR-001 docs score 0.9
=> confidence = 0.3*1.0 + 0.3*0.95 + 0.2*1.0 + 0.2*0.9 = 0.965 -> boosted -> 0.94 after normalization (example)

We compute actual scores, not hardcoded.

## 6. API Response Format

```json
{
  "request_id": "uuid",
  "component_id": "SONAR-001",
  "component_name": "Sonar Transducer Array",
  "mesh_id": "Mesh_042",
  "fault": "Casing fracture",
  "severity": "HIGH",
  "confidence": 0.94,
  "evidence": [
    {"type": "keyword", "keyword": "sonar", "matched_text": "sonar", "score": 0.98, "component_id": "SONAR-001"},
    {"type": "phrase", "keyword": "abnormal vibration", "matched_text": "abnormal vibration", "score": 0.95}
  ],
  "recommended_actions": [
    "Inspect sonar transducer casing for visible fractures - power down system first",
    "Check vibration isolation mounts - replace if worn",
    "Run diagnostic: sonar --self-test",
    "If fracture confirmed, replace casing seal and schedule dry-dock inspection"
  ],
  "warnings": ["Do not operate sonar with fractured casing - risk of water ingress"],
  "timestamp": "2026-08-31T00:00:00Z",
  "processing_time_ms": 45
}
```

If no component identified:
- component_id = "UNKNOWN"
- confidence low (0.2)
- recommended_actions = ["Please provide more details: component name, symptoms"]

## 7. Pluggable LLM/Embedding

Interfaces:

```python
class EmbeddingProvider(Protocol):
    def embed(self, text: str) -> List[float]: ...
    def embed_batch(self, texts: List[str]) -> List[List[float]]: ...

class LLMProvider(Protocol):
    def generate(self, prompt: str, context: str) -> str: ...

# Implementations:
# - TFIDFEmbeddingProvider (default, no model needed)
# - SentenceTransformerProvider (optional, if model downloaded)
# - ONNXProvider (future)
# - NoOpLLM (returns retrieved knowledge directly)
```

This allows future local LLM without rewriting.

## 8. Voice Input

- Flutter: `speech_to_text` package
- Audio -> text -> same pipeline
- Voice is enhancement, not required. UI shows mic button, but text input always available.
- If speech_to_text unavailable, hide mic gracefully.

## 9. Security for Local AI

- Binds only to 127.0.0.1, not 0.0.0.0
- No auth needed for localhost, but request_id logging
- Input validation: max length 2000 chars, sanitize
- No code execution from input
- Logs don't contain sensitive raw data beyond troubleshooting text (which is operational, not PII)

## 10. Performance

- Target <100ms for keyword/phrase matching
- <500ms for full pipeline with TF-IDF retrieval over 1000 chunks
- Async FastAPI, no blocking
- Knowledge base loaded at startup, cached in memory

## 11. Testing

- Unit: normalization, tokenization, keyword matching, fuzzy matching, confidence scoring
- Integration: full pipeline with demo fault "Sonar transducer is showing abnormal vibration and casing fracture." must return SONAR-001, Mesh_042, HIGH
- Failure: empty input, gibberish, no match -> UNKNOWN with low confidence, not crash
- Performance: 100 queries in <10 sec

## 12. Deployment

- Dev: `uvicorn app.main:app --host 127.0.0.1 --port 8001`
- Windows: bundled as exe via PyInstaller or run via pythonw
- Android: via Chaquopy or Termux (for demo, we run on dev machine and Flutter connects to 127.0.0.1 via adb forward)
- Knowledge base updates via /api/v1/updates/manifest

## 13. Future: Local LLM

When model available:
- Download GGUF model
- Use llama.cpp Python bindings
- Prompt: "Given context: {retrieved_knowledge}, user reports: {input}, identify component, fault, severity, actions"
- Still return structured JSON via function calling or JSON mode
- Confidence from model logprobs + retrieval score
