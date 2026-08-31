import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app.core.pipeline import TroubleshootingPipeline, TextNormalizer, KeywordMatcher, PhraseMatcher, SeverityEstimator, ConfidenceScorer
from app.knowledge.retrieval import KnowledgeRetrieval

def test_normalizer():
    normalizer = TextNormalizer()
    assert normalizer.normalize("  Sonar   Transducer  ") == "sonar transducer"
    assert normalizer.normalize("SONAR-001") == "sonar-001"
    assert normalizer.normalize("") == ""

def test_keyword_matcher_sonar():
    matcher = KeywordMatcher()
    results = matcher.match_component("sonar transducer is showing abnormal vibration")
    assert len(results) > 0
    assert results[0][0] == "SONAR-001"
    assert results[0][1] > 0.8

def test_keyword_matcher_telemetry():
    matcher = KeywordMatcher()
    results = matcher.match_component("telemetry mast signal loss")
    assert len(results) > 0
    assert results[0][0] == "TELEM-001"

def test_phrase_matcher_fracture():
    matcher = PhraseMatcher()
    results = matcher.match_fault("casing fracture detected")
    assert len(results) > 0
    assert results[0][0] == "Casing fracture"

def test_phrase_matcher_vibration():
    matcher = PhraseMatcher()
    results = matcher.match_fault("abnormal vibration in sonar")
    assert len(results) > 0
    assert results[0][0] == "Abnormal vibration"

def test_severity_estimator_critical():
    estimator = SeverityEstimator()
    severity, conf = estimator.estimate("hydraulic leak detected critical failure")
    assert severity == "CRITICAL"
    assert conf > 0.8

def test_severity_estimator_high():
    estimator = SeverityEstimator()
    severity, conf = estimator.estimate("abnormal vibration and casing fracture")
    assert severity == "HIGH"

def test_confidence_scorer():
    scorer = ConfidenceScorer()
    confidence = scorer.calculate(
        keyword_scores=[("SONAR-001", 0.98, "sonar")],
        phrase_scores=[("Casing fracture", 0.95, "casing fracture")],
        knowledge_score=0.9,
        component_match_count=1
    )
    assert confidence > 0.8
    assert confidence <= 0.99

def test_knowledge_retrieval():
    retrieval = KnowledgeRetrieval()
    results = retrieval.search("sonar transducer casing fracture", top_k=3)
    assert len(results) > 0
    assert results[0]["metadata"]["component_id"] == "SONAR-001"
    assert results[0]["score"] > 0

def test_full_pipeline_demo_fault():
    """Test the demo fault from spec: Sonar transducer is showing abnormal vibration and casing fracture."""
    pipeline = TroubleshootingPipeline()
    result = pipeline.analyze("Sonar transducer is showing abnormal vibration and casing fracture.")
    
    assert result["component_id"] == "SONAR-001"
    assert result["component_name"] == "Sonar Transducer Array"
    assert result["mesh_id"] == "Mesh_042"
    assert result["severity"] == "HIGH" or result["severity"] == "CRITICAL"  # Should be HIGH per spec
    assert result["confidence"] > 0.8
    assert "fracture" in result["fault"].lower() or "vibration" in result["fault"].lower()
    assert len(result["recommended_actions"]) > 0
    assert len(result["evidence"]) > 0
    assert result["request_id"] is not None
    assert result["timestamp"] is not None

def test_full_pipeline_telemetry():
    pipeline = TroubleshootingPipeline()
    result = pipeline.analyze("Telemetry transceiver mast showing signal loss")
    
    assert result["component_id"] == "TELEM-001"
    assert result["mesh_id"] == "Mesh_109"
    assert result["severity"] in ["CRITICAL", "HIGH"]

def test_full_pipeline_unknown():
    pipeline = TroubleshootingPipeline()
    result = pipeline.analyze("Random gibberish xyz abc 123")
    
    # Should return UNKNOWN with low confidence, not crash
    assert result["confidence"] < 0.5
    # Either UNKNOWN or low confidence
    assert result["component_id"] == "UNKNOWN" or result["confidence"] < 0.6

def test_full_pipeline_empty():
    pipeline = TroubleshootingPipeline()
    result = pipeline.analyze("")
    
    assert result["component_id"] == "UNKNOWN"
    assert result["confidence"] == 0.2

def test_full_pipeline_hydraulic_leak():
    pipeline = TroubleshootingPipeline()
    result = pipeline.analyze("Hydraulic winch showing hydraulic leak and fluid loss")
    
    assert result["component_id"] == "WINCH-001"
    assert result["mesh_id"] == "Mesh_410"
    assert result["severity"] == "CRITICAL"
    assert len(result["warnings"]) > 0

def test_demo_fault_expected_output():
    """Verify demo fault matches spec exactly"""
    pipeline = TroubleshootingPipeline()
    text = "Sonar transducer is showing abnormal vibration and casing fracture."
    result = pipeline.analyze(text)
    
    # Per spec expected:
    # Component: SONAR-001
    # Mesh: Mesh_042
    # Severity: HIGH
    print(f"Demo fault result: {result}")
    
    assert result["component_id"] == "SONAR-001", f"Expected SONAR-001, got {result['component_id']}"
    assert result["mesh_id"] == "Mesh_042", f"Expected Mesh_042, got {result['mesh_id']}"
    assert result["severity"] == "HIGH", f"Expected HIGH, got {result['severity']}"
    assert result["confidence"] >= 0.8, f"Expected confidence >=0.8, got {result['confidence']}"
    # Check evidence contains sonar and fracture
    evidence_text = str(result["evidence"]).lower()
    assert "sonar" in evidence_text or "transducer" in evidence_text
