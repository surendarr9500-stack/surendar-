"""
Knowledge Retrieval using TF-IDF + BM25-like scoring (deterministic, no cloud LLM)
"""
import re
import math
from typing import List, Dict
from collections import Counter, defaultdict

# Seed knowledge base - in production this would be loaded from files/DB
DEFAULT_KNOWLEDGE_BASE = [
    {
        "id": "kb-001",
        "title": "Sonar Transducer Array - Casing Fracture",
        "content": "Sonar transducer casing fracture is a critical fault caused by mechanical stress, impact, or material fatigue. Symptoms include abnormal vibration, acoustic performance degradation, and visible cracks. Immediate action: power down system, inspect casing, check vibration isolation mounts, run self-test. If fracture confirmed, replace casing seal and schedule dry-dock inspection. Risk of water ingress if operated with fracture.",
        "metadata": {"component_id": "SONAR-001", "fault_type": "Casing fracture", "severity": "HIGH", "mesh_id": "Mesh_042"}
    },
    {
        "id": "kb-002",
        "title": "Sonar Transducer - Abnormal Vibration",
        "content": "Abnormal vibration in sonar transducer array indicates mechanical looseness, worn isolation mounts, or internal component failure. Check mounting bolts, inspect vibration isolation mounts for wear, verify transducer alignment, run vibration analysis diagnostic. If vibration persists, replace isolation mounts. Severity HIGH due to risk of further damage.",
        "metadata": {"component_id": "SONAR-001", "fault_type": "Abnormal vibration", "severity": "HIGH", "mesh_id": "Mesh_042"}
    },
    {
        "id": "kb-003",
        "title": "Telemetry Transceiver - Signal Loss",
        "content": "Telemetry signal loss can be caused by mast corrosion, antenna misalignment, transceiver failure, cable damage, or satellite visibility issues. Troubleshooting: check mast for physical damage, verify antenna alignment, test transceiver loopback, check signal strength, inspect RF cables. Critical severity as impacts vessel safety communications.",
        "metadata": {"component_id": "TELEM-001", "fault_type": "Signal loss", "severity": "CRITICAL", "mesh_id": "Mesh_109"}
    },
    {
        "id": "kb-004",
        "title": "Argo Float - Buoyancy Failure",
        "content": "Argo profiling float buoyancy failure prevents float from maintaining depth or surfacing. Causes: oil bladder leak, buoyancy engine failure, CTD sensor error affecting density calculation, pressure housing leak. Test buoyancy engine, check oil bladder, verify CTD readings, inspect pressure housing. Recover float for shore maintenance if failure confirmed.",
        "metadata": {"component_id": "ARGO-001", "fault_type": "Buoyancy failure", "severity": "HIGH", "mesh_id": "Mesh_210"}
    },
    {
        "id": "kb-005",
        "title": "Echo Sounder - Echo Loss",
        "content": "Multi-beam echo sounder echo loss results in loss of bathymetric data. Causes: transducer failure, calibration error, motion sensor error, sound velocity profile error, beamforming failure. Check echo returns, run calibration, test beamforming, verify motion reference unit, update sound velocity profile.",
        "metadata": {"component_id": "ECHO-001", "fault_type": "Echo loss", "severity": "MEDIUM", "mesh_id": "Mesh_315"}
    },
    {
        "id": "kb-006",
        "title": "Hydraulic Winch - Hydraulic Leak",
        "content": "Hydraulic deep-sea winch hydraulic leak is critical fault requiring immediate power down. Locate leak source - hoses, fittings, seals. Contain spill per environmental procedures. Replace damaged hoses or seals, refill fluid, bleed system, test at low load. Risk of uncontrolled load drop and environmental contamination.",
        "metadata": {"component_id": "WINCH-001", "fault_type": "Hydraulic leak", "severity": "CRITICAL", "mesh_id": "Mesh_410"}
    },
    {
        "id": "kb-007",
        "title": "Sonar Operations Manual",
        "content": "Sonar transducer array operations manual covers installation, calibration, self-test diagnostics, maintenance procedures, troubleshooting common faults including vibration and casing fracture. Part of training course Sonar Operations and Maintenance.",
        "metadata": {"component_id": "SONAR-001", "category": "Manual", "mesh_id": "Mesh_042"}
    },
    {
        "id": "kb-008",
        "title": "Telemetry Systems Guide",
        "content": "Telemetry transceiver mast operations guide includes satellite communication, RF troubleshooting, mast corrosion prevention, antenna alignment, cable integrity checks.",
        "metadata": {"component_id": "TELEM-001", "category": "Manual", "mesh_id": "Mesh_109"}
    },
    {
        "id": "kb-009",
        "title": "Winch Safety Procedures",
        "content": "Hydraulic winch safety procedures: check hydraulic fluid level, inspect cable for wear, monitor motor temperature, test brake system, check spooling mechanism, emergency stop procedures, load limits.",
        "metadata": {"component_id": "WINCH-001", "category": "Safety", "mesh_id": "Mesh_410"}
    },
    {
        "id": "kb-010",
        "title": "Argo Float Maintenance",
        "content": "Argo float maintenance procedures: test buoyancy engine, calibrate CTD sensors, check battery voltage, test Iridium communication, inspect pressure housing, deploy and recovery procedures.",
        "metadata": {"component_id": "ARGO-001", "category": "Maintenance", "mesh_id": "Mesh_210"}
    },
]

class KnowledgeRetrieval:
    def __init__(self, knowledge_base: List[Dict] = None):
        self.knowledge_base = knowledge_base or DEFAULT_KNOWLEDGE_BASE
        self._build_index()
    
    def _build_index(self):
        # Build TF-IDF index
        self.doc_tokens = []
        self.doc_term_freq = []
        self.term_doc_freq = defaultdict(int)
        self.N = len(self.knowledge_base)
        
        for doc in self.knowledge_base:
            text = f"{doc['title']} {doc['content']}"
            tokens = self._tokenize(text)
            self.doc_tokens.append(tokens)
            tf = Counter(tokens)
            self.doc_term_freq.append(tf)
            for term in set(tokens):
                self.term_doc_freq[term] += 1
        
        # Compute IDF
        self.idf = {}
        for term, df in self.term_doc_freq.items():
            self.idf[term] = math.log((self.N - df + 0.5) / (df + 0.5) + 1)
    
    def _tokenize(self, text: str) -> List[str]:
        text = text.lower()
        tokens = re.findall(r'\b\w+\b', text)
        # Remove short tokens
        tokens = [t for t in tokens if len(t) > 2]
        return tokens
    
    def _bm25_score(self, query_tokens: List[str], doc_idx: int, k1: float = 1.5, b: float = 0.75) -> float:
        score = 0.0
        doc_len = len(self.doc_tokens[doc_idx])
        avg_dl = sum(len(tokens) for tokens in self.doc_tokens) / self.N if self.N > 0 else 1
        
        tf = self.doc_term_freq[doc_idx]
        
        for term in query_tokens:
            if term not in tf:
                continue
            idf = self.idf.get(term, 0)
            term_freq = tf[term]
            numerator = term_freq * (k1 + 1)
            denominator = term_freq + k1 * (1 - b + b * doc_len / avg_dl)
            score += idf * numerator / denominator
        
        return score
    
    def search(self, query: str, top_k: int = 5) -> List[Dict]:
        if not query:
            return []
        
        query_tokens = self._tokenize(query.lower())
        if not query_tokens:
            return []
        
        scores = []
        for idx, doc in enumerate(self.knowledge_base):
            bm25 = self._bm25_score(query_tokens, idx)
            # Boost if component_id matches query keywords (heuristic)
            # For simplicity, if doc's component_id appears in query, boost
            boost = 0
            comp_id = doc.get('metadata', {}).get('component_id', '').lower()
            if comp_id and comp_id in query.lower():
                boost = 2.0
            
            # Also boost for fault type match
            fault_type = doc.get('metadata', {}).get('fault_type', '').lower()
            if fault_type and any(token in fault_type for token in query_tokens):
                boost += 1.0
            
            final_score = bm25 + boost
            if final_score > 0:
                scores.append((idx, final_score))
        
        scores.sort(key=lambda x: x[1], reverse=True)
        
        results = []
        for idx, score in scores[:top_k]:
            doc = self.knowledge_base[idx]
            results.append({
                "id": doc["id"],
                "title": doc["title"],
                "content": doc["content"],
                "score": round(score, 4),
                "metadata": doc.get("metadata", {})
            })
        
        return results
    
    def add_document(self, doc: Dict):
        self.knowledge_base.append(doc)
        self._build_index()
    
    def get_by_component(self, component_id: str) -> List[Dict]:
        return [doc for doc in self.knowledge_base if doc.get('metadata', {}).get('component_id') == component_id]
