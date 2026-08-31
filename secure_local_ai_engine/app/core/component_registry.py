"""
Hardware Registry for AI Engine - Maps keywords to components
"""
from typing import Dict, List

COMPONENT_KEYWORDS: Dict[str, List[str]] = {
    "SONAR-001": [
        "sonar", "transducer", "sonar array", "acoustic", "vibration",
        "sonar transducer", "transducer array", "echo sounder", "sonar system",
        "sonar-001", "sonar 001"
    ],
    "TELEM-001": [
        "telemetry", "transceiver", "mast", "communication", "antenna",
        "telemetry mast", "transceiver mast", "telem", "telemetry system",
        "telem-001", "telemetry transceiver"
    ],
    "ARGO-001": [
        "argo", "float", "profiling", "buoyancy", "ctd", "argo float",
        "profiling float", "autonomous float", "argo-001", "argo profiling"
    ],
    "ECHO-001": [
        "echo sounder", "multi-beam", "multibeam", "bathymetry", "echo",
        "echo sounder", "multi beam", "bathymetric", "echo-001"
    ],
    "WINCH-001": [
        "winch", "hydraulic", "cable", "deep-sea winch", "deep sea winch",
        "hydraulic winch", "winch system", "winch-001", "cable winch"
    ]
}

COMPONENT_INFO: Dict[str, Dict] = {
    "SONAR-001": {
        "name": "Sonar Transducer Array",
        "mesh_id": "Mesh_042",
        "category": "Sonar",
        "manufacturer": "Kongsberg Maritime",
        "model": "EM-2040",
    },
    "TELEM-001": {
        "name": "Telemetry Transceiver Mast",
        "mesh_id": "Mesh_109",
        "category": "Telemetry",
        "manufacturer": "Cobham SATCOM",
        "model": "SAILOR 900",
    },
    "ARGO-001": {
        "name": "Autonomous Argo Profiling Float",
        "mesh_id": "Mesh_210",
        "category": "Argo",
        "manufacturer": "Teledyne Webb",
        "model": "APEX",
    },
    "ECHO-001": {
        "name": "Multi-beam Echo Sounder",
        "mesh_id": "Mesh_315",
        "category": "Echo Sounder",
        "manufacturer": "Kongsberg",
        "model": "EM-304",
    },
    "WINCH-001": {
        "name": "Hydraulic Deep-Sea Winch",
        "mesh_id": "Mesh_410",
        "category": "Winch",
        "manufacturer": "Dynacon",
        "model": "D-2000",
    }
}

FAULT_KEYWORDS: Dict[str, List[str]] = {
    "Casing fracture": ["fracture", "crack", "casing", "housing break", "casing fracture", "housing fracture", "case crack"],
    "Abnormal vibration": ["vibration", "shaking", "abnormal", "resonance", "abnormal vibration", "excessive vibration", "vibrating"],
    "Transducer failure": ["transducer failure", "transducer fault", "transducer error", "acoustic failure"],
    "Signal loss": ["signal loss", "no signal", "communication failure", "signal failure", "loss of signal", "telemetry loss"],
    "Mast corrosion": ["corrosion", "rust", "mast corrosion", "corroded", "oxidation"],
    "Buoyancy failure": ["buoyancy", "sinking", "float failure", "buoyancy failure", "unable to float"],
    "Sensor drift": ["sensor drift", "drift", "calibration drift", "sensor error", "ctd drift"],
    "Echo loss": ["echo loss", "no echo", "bathymetry failure", "echo failure", "loss of echo"],
    "Hydraulic leak": ["hydraulic leak", "fluid leak", "oil leak", "hydraulic failure", "leak"],
    "Cable tension high": ["cable tension", "tension high", "cable stress", "over tension"],
    "Motor overheat": ["overheat", "overheating", "motor hot", "thermal", "motor overheat"],
    "Calibration error": ["calibration", "calibration error", "calibration failure", "out of calibration"],
    "Water ingress": ["water ingress", "water leak", "flooding", "water intrusion", "leakage"],
}

SEVERITY_RULES: Dict[str, List[str]] = {
    "CRITICAL": ["fire", "critical", "signal loss", "water ingress", "hydraulic leak", "buoyancy failure", "broken"],
    "HIGH": ["fracture", "leak", "failure", "abnormal", "vibration", "overheat", "corrosion", "crack", "casing fracture", "transducer failure", "echo loss", "high tension"],
    "MEDIUM": ["drift", "calibration", "degraded", "intermittent", "sensor drift", "calibration error"],
    "LOW": ["minor", "inspection", "scheduled", "maintenance", "check", "minor issue"],
}

RECOMMENDED_ACTIONS: Dict[str, List[str]] = {
    "Casing fracture": [
        "Inspect sonar transducer casing for visible fractures - power down system first",
        "Check vibration isolation mounts - replace if worn",
        "Run diagnostic: sonar --self-test",
        "If fracture confirmed, replace casing seal and schedule dry-dock inspection",
        "Document fracture with photos for maintenance record"
    ],
    "Abnormal vibration": [
        "Power down sonar system and inspect mounting bolts",
        "Check vibration isolation mounts for wear or damage",
        "Verify transducer alignment and secure all fasteners",
        "Run vibration analysis diagnostic",
        "If vibration persists, schedule replacement of isolation mounts"
    ],
    "Signal loss": [
        "Check telemetry mast for physical damage or corrosion",
        "Verify antenna alignment and cable connections",
        "Test transceiver with loopback diagnostic",
        "Check satellite visibility and signal strength",
        "Inspect RF cables for damage"
    ],
    "Mast corrosion": [
        "Inspect mast structure for corrosion extent",
        "Clean and treat corroded areas with anti-corrosion coating",
        "Check grounding and cathodic protection",
        "Schedule mast replacement if structural integrity compromised"
    ],
    "Buoyancy failure": [
        "Test buoyancy engine operation",
        "Check oil bladder for leaks",
        "Verify CTD sensor readings for density calculation",
        "Inspect pressure housing for leaks",
        "If failure confirmed, recover float for shore maintenance"
    ],
    "Hydraulic leak": [
        "Immediately power down winch system",
        "Locate leak source - check hoses, fittings, and seals",
        "Contain hydraulic fluid spill per environmental procedures",
        "Replace damaged hoses or seals",
        "Refill hydraulic fluid and bleed system",
        "Test operation at low load before full operation"
    ],
}

DEFAULT_ACTIONS = [
    "Document fault with photos and detailed description",
    "Check component operational manual for troubleshooting steps",
    "Run built-in self-test diagnostics if available",
    "Notify supervisor of fault and severity",
    "Create diagnostic record in Capacity Connect",
    "If CRITICAL, secure equipment and prevent further operation"
]

WARNINGS: Dict[str, List[str]] = {
    "Casing fracture": ["Do not operate sonar with fractured casing - risk of water ingress and total failure"],
    "Hydraulic leak": ["Hydraulic fluid is hazardous - wear PPE and contain spill immediately", "Do not operate winch with hydraulic leak - risk of uncontrolled load drop"],
    "Signal loss": ["Loss of telemetry may impact vessel safety communications - switch to backup"],
    "Buoyancy failure": ["Argo float may be lost if buoyancy not restored - attempt recovery if possible"],
}
