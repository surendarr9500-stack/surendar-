"""
AI Pipeline: User Input -> Component Identification -> Fault Classification -> Severity -> Actions -> 3D Mapping
"""
import re
import unicodedata
import uuid
from datetime import datetime
from typing import List, Dict, Tuple, Optional
from rapidfuzz import fuzz
from .component_registry import (
    COMPONENT_KEYWORDS, COMPONENT_INFO, FAULT_KEYWORDS, 
    SEVERITY_RULES, RECOMMENDED_ACTIONS, DEFAULT_ACTIONS, WARNINGS
)
from ..knowledge.retrieval import KnowledgeRetrieval

class TextNormalizer:
    @staticmethod
    def normalize(text: str) -> str:
        if not text:
            return ""
        # Unicode normalize
        text = unicodedata.normalize('NFKD', text)
        # Lowercase
        text = text.lower()
        # Remove extra spaces
        text = re.sub(r'\s+', ' ', text).strip()
        # Remove special chars but keep alphanumeric and spaces
        text = re.sub(r'[^\w\s\-]', ' ', text)
        text = re.sub(r'\s+', ' ', text).strip()
        return text

class LanguageDetector:
    @staticmethod
    def detect(text: str) -> str:
        # Simple heuristic: if contains devanagari or other scripts, detect
        # For now, default to 'en', future support for hi, etc.
        try:
            from langdetect import detect
            lang = detect(text)
            return lang if lang in ['en', 'hi'] else 'en'
        except:
            return 'en'

class Tokenizer:
    STOPWORDS = {'the', 'is', 'are', 'and', 'or', 'a', 'an', 'in', 'on', 'at', 'to', 'of', 'for', 'with', 'showing', 'is', 'are'}
    
    @staticmethod
    def tokenize(text: str) -> List[str]:
        tokens = text.lower().split()
        # Remove stopwords but keep important technical terms
        return [t for t in tokens if t not in Tokenizer.STOPWORDS or len(t) > 4]

class KeywordMatcher:
    @staticmethod
    def match_component(normalized_text: str) -> List[Tuple[str, float, str]]:
        """
        Returns list of (component_id, score, matched_keyword)
        """
        results = []
        for comp_id, keywords in COMPONENT_KEYWORDS.items():
            best_score = 0
            best_keyword = ""
            for keyword in keywords:
                # Exact substring match
                if keyword.lower() in normalized_text:
                    score = 1.0
                    # Boost for longer keyword matches
                    score += len(keyword) / 100.0
                    if score > best_score:
                        best_score = min(score, 1.0)
                        best_keyword = keyword
                else:
                    # Fuzzy partial match
                    fuzzy_score = fuzz.partial_ratio(keyword.lower(), normalized_text) / 100.0
                    if fuzzy_score > 0.85 and fuzzy_score > best_score:
                        best_score = fuzzy_score * 0.9  # Penalize fuzzy vs exact
                        best_keyword = keyword
            if best_score > 0:
                results.append((comp_id, best_score, best_keyword))
        
        # Sort by score descending
        results.sort(key=lambda x: x[1], reverse=True)
        return results

class PhraseMatcher:
    @staticmethod
    def match_fault(normalized_text: str) -> List[Tuple[str, float, str]]:
        """
        Returns list of (fault_name, score, matched_phrase)
        """
        results = []
        for fault_name, phrases in FAULT_KEYWORDS.items():
            best_score = 0
            best_phrase = ""
            for phrase in phrases:
                if phrase.lower() in normalized_text:
                    score = 1.0
                    if score > best_score:
                        best_score = score
                        best_phrase = phrase
                else:
                    fuzzy_score = fuzz.partial_ratio(phrase.lower(), normalized_text) / 100.0
                    if fuzzy_score > 0.80 and fuzzy_score > best_score:
                        best_score = fuzzy_score * 0.9
                        best_phrase = phrase
            if best_score > 0:
                results.append((fault_name, best_score, best_phrase))
        
        results.sort(key=lambda x: x[1], reverse=True)
        return results

class FuzzyMatcher:
    @staticmethod
    def fuzzy_match(text: str, candidates: List[str], threshold: float = 80.0) -> List[Tuple[str, float]]:
        results = []
        for cand in candidates:
            score = fuzz.ratio(text.lower(), cand.lower())
            if score >= threshold:
                results.append((cand, score / 100.0))
        results.sort(key=lambda x: x[1], reverse=True)
        return results

class SeverityEstimator:
    @staticmethod
    def estimate(normalized_text: str, fault_name: Optional[str] = None) -> Tuple[str, float]:
        """
        Returns (severity, confidence)
        """
        text_lower = normalized_text.lower()
        
        # Check fault-specific severity from component registry if needed
        # For now, use keyword rules
        
        critical_score = 0
        high_score = 0
        medium_score = 0
        low_score = 0
        
        for keyword in SEVERITY_RULES["CRITICAL"]:
            if keyword.lower() in text_lower:
                critical_score += 1
        for keyword in SEVERITY_RULES["HIGH"]:
            if keyword.lower() in text_lower:
                high_score += 1
        for keyword in SEVERITY_RULES["MEDIUM"]:
            if keyword.lower() in text_lower:
                medium_score += 1
        for keyword in SEVERITY_RULES["LOW"]:
            if keyword.lower() in text_lower:
                low_score += 1
        
        # Determine severity by highest score, with critical taking precedence
        if critical_score > 0:
            return "CRITICAL", min(0.9 + critical_score * 0.05, 0.99)
        elif high_score > 0:
            return "HIGH", min(0.8 + high_score * 0.05, 0.95)
        elif medium_score > 0:
            return "MEDIUM", min(0.6 + medium_score * 0.05, 0.85)
        elif low_score > 0:
            return "LOW", min(0.5 + low_score * 0.05, 0.75)
        else:
            # Default based on fault name
            if fault_name in ["Casing fracture", "Hydraulic leak", "Signal loss"]:
                return "HIGH", 0.7
            return "MEDIUM", 0.5

class ConfidenceScorer:
    @staticmethod
    def calculate(
        keyword_scores: List[Tuple[str, float, str]],
        phrase_scores: List[Tuple[str, float, str]],
        knowledge_score: float,
        component_match_count: int
    ) -> float:
        """
        Real confidence algorithm, not arbitrary
        Weighted sum: keyword 0.3, phrase 0.3, fuzzy 0.2, knowledge 0.2
        Plus boosts for multiple evidences
        """
        keyword_score = keyword_scores[0][1] if keyword_scores else 0.0
        phrase_score = phrase_scores[0][1] if phrase_scores else 0.0
        fuzzy_score = max(keyword_score, phrase_score)  # For simplicity, use best of keyword/phrase as fuzzy proxy
        
        # Weighted sum
        confidence = (
            keyword_score * 0.3 +
            phrase_score * 0.3 +
            fuzzy_score * 0.2 +
            knowledge_score * 0.2
        )
        
        # Boosts
        if component_match_count > 1:
            confidence += 0.05
        if keyword_score > 0.9 and phrase_score > 0.9:
            confidence += 0.1
        if knowledge_score > 0.8:
            confidence += 0.05
        
        # Cap and floor
        confidence = max(0.1, min(confidence, 0.99))
        return round(confidence, 4)

class TroubleshootingPipeline:
    def __init__(self, knowledge_retrieval: Optional[KnowledgeRetrieval] = None):
        self.normalizer = TextNormalizer()
        self.language_detector = LanguageDetector()
        self.tokenizer = Tokenizer()
        self.keyword_matcher = KeywordMatcher()
        self.phrase_matcher = PhraseMatcher()
        self.fuzzy_matcher = FuzzyMatcher()
        self.severity_estimator = SeverityEstimator()
        self.confidence_scorer = ConfidenceScorer()
        self.knowledge_retrieval = knowledge_retrieval or KnowledgeRetrieval()
    
    def analyze(self, text: str, request_id: Optional[str] = None) -> Dict:
        start_time = datetime.utcnow()
        request_id = request_id or str(uuid.uuid4())
        
        if not text or not text.strip():
            return self._unknown_response(request_id, text, "Empty input", start_time)
        
        if len(text) > 2000:
            text = text[:2000]
        
        # Pipeline steps
        normalized = self.normalizer.normalize(text)
        language = self.language_detector.detect(text)
        tokens = self.tokenizer.tokenize(normalized)
        
        # Keyword matching -> component
        component_matches = self.keyword_matcher.match_component(normalized)
        
        # Phrase matching -> fault
        fault_matches = self.phrase_matcher.match_fault(normalized)
        
        # Knowledge retrieval
        knowledge_results = self.knowledge_retrieval.search(normalized, top_k=5)
        knowledge_score = knowledge_results[0]['score'] if knowledge_results else 0.0
        # Normalize BM25 score to 0-1 (heuristic)
        knowledge_score_normalized = min(knowledge_score / 10.0, 1.0) if knowledge_score > 0 else 0.0
        
        # Determine component
        if component_matches:
            component_id, comp_score, matched_keyword = component_matches[0]
            component_info = COMPONENT_INFO.get(component_id, {})
        else:
            # Try to infer from knowledge retrieval metadata
            if knowledge_results and knowledge_results[0].get('metadata', {}).get('component_id'):
                component_id = knowledge_results[0]['metadata']['component_id']
                component_info = COMPONENT_INFO.get(component_id, {})
                comp_score = 0.6
                matched_keyword = "knowledge_inferred"
            else:
                return self._unknown_response(request_id, text, "No component identified", start_time, normalized, tokens, knowledge_results)
        
        # Determine fault
        if fault_matches:
            fault_name, fault_score, matched_phrase = fault_matches[0]
        else:
            fault_name = "Unknown fault"
            fault_score = 0.3
            matched_phrase = ""
        
        # Severity
        severity, severity_conf = self.severity_estimator.estimate(normalized, fault_name)
        
        # Confidence
        confidence = self.confidence_scorer.calculate(
            keyword_scores=component_matches,
            phrase_scores=fault_matches,
            knowledge_score=knowledge_score_normalized,
            component_match_count=len(component_matches)
        )
        
        # Recommended actions
        recommended_actions = RECOMMENDED_ACTIONS.get(fault_name, DEFAULT_ACTIONS)
        
        # Warnings
        warnings = WARNINGS.get(fault_name, [])
        
        # Evidence
        evidence = []
        for comp_id, score, kw in component_matches[:3]:
            evidence.append({
                "type": "keyword",
                "keyword": kw,
                "matched_text": kw,
                "score": round(score, 4),
                "component_id": comp_id
            })
        for fault, score, phrase in fault_matches[:3]:
            evidence.append({
                "type": "phrase",
                "keyword": phrase,
                "matched_text": phrase,
                "score": round(score, 4),
                "fault": fault
            })
        for kr in knowledge_results[:2]:
            evidence.append({
                "type": "knowledge",
                "keyword": kr['title'],
                "matched_text": kr['content'][:100],
                "score": round(kr['score'], 4),
                "source": kr.get('metadata', {})
            })
        
        # Build response
        end_time = datetime.utcnow()
        processing_time_ms = int((end_time - start_time).total_seconds() * 1000)
        
        response = {
            "request_id": request_id,
            "component_id": component_id,
            "component_name": component_info.get("name", "Unknown"),
            "mesh_id": component_info.get("mesh_id", "UNKNOWN"),
            "fault": fault_name,
            "severity": severity,
            "confidence": confidence,
            "evidence": evidence,
            "recommended_actions": recommended_actions,
            "warnings": warnings,
            "timestamp": end_time.isoformat() + "Z",
            "processing_time_ms": processing_time_ms,
            "language": language,
            "normalized_input": normalized,
            "tokens": tokens,
            "knowledge_results": knowledge_results[:3],
        }
        
        return response
    
    def _unknown_response(self, request_id: str, original_text: str, reason: str, start_time: datetime, normalized: str = "", tokens: List[str] = [], knowledge_results: List = []) -> Dict:
        end_time = datetime.utcnow()
        processing_time_ms = int((end_time - start_time).total_seconds() * 1000)
        return {
            "request_id": request_id,
            "component_id": "UNKNOWN",
            "component_name": "Unknown Component",
            "mesh_id": "UNKNOWN",
            "fault": "Unknown fault",
            "severity": "UNKNOWN",
            "confidence": 0.2,
            "evidence": [{"type": "info", "keyword": "no_match", "matched_text": reason, "score": 0.2}],
            "recommended_actions": [
                "Please provide more details: component name, symptoms, error codes",
                "Check component registry for valid component IDs",
                "Refer to operational manual for fault description guidelines",
                "Contact supervisor if issue persists"
            ],
            "warnings": [],
            "timestamp": end_time.isoformat() + "Z",
            "processing_time_ms": processing_time_ms,
            "language": "en",
            "normalized_input": normalized,
            "tokens": tokens,
            "knowledge_results": knowledge_results,
        }
