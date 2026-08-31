class ComponentModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String manufacturer;
  final String model;
  final String meshId;
  final double x, y, z;
  String status;
  final String installationLocation;
  final List<String> possibleFaults;
  final List<String> maintenanceProcedures;
  final List<String> trainingReferences;
  final List<String> documentationReferences;
  final DateTime? lastInspection;
  final DateTime? nextMaintenance;
  final int version;
  
  ComponentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.manufacturer,
    required this.model,
    required this.meshId,
    required this.x,
    required this.y,
    required this.z,
    required this.status,
    required this.installationLocation,
    required this.possibleFaults,
    required this.maintenanceProcedures,
    required this.trainingReferences,
    required this.documentationReferences,
    this.lastInspection,
    this.nextMaintenance,
    this.version = 1,
  });
  
  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      meshId: json['mesh_id'] ?? json['meshId'],
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      z: (json['z'] ?? 0).toDouble(),
      status: json['status'] ?? 'UNKNOWN',
      installationLocation: json['installation_location'] ?? json['installationLocation'] ?? '',
      possibleFaults: List<String>.from(json['possible_faults'] ?? json['possibleFaults'] ?? []),
      maintenanceProcedures: List<String>.from(json['maintenance_procedures'] ?? json['maintenanceProcedures'] ?? []),
      trainingReferences: List<String>.from(json['training_references'] ?? json['trainingReferences'] ?? []),
      documentationReferences: List<String>.from(json['documentation_references'] ?? json['documentationReferences'] ?? []),
      lastInspection: json['last_inspection'] != null ? DateTime.parse(json['last_inspection']) : null,
      nextMaintenance: json['next_maintenance'] != null ? DateTime.parse(json['next_maintenance']) : null,
      version: json['version'] ?? 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'manufacturer': manufacturer,
      'model': model,
      'mesh_id': meshId,
      'x': x,
      'y': y,
      'z': z,
      'status': status,
      'installation_location': installationLocation,
      'possible_faults': possibleFaults,
      'maintenance_procedures': maintenanceProcedures,
      'training_references': trainingReferences,
      'documentation_references': documentationReferences,
      'last_inspection': lastInspection?.toIso8601String(),
      'next_maintenance': nextMaintenance?.toIso8601String(),
      'version': version,
    };
  }
}

class AIAnalysisResult {
  final String requestId;
  final String componentId;
  final String componentName;
  final String meshId;
  final String fault;
  final String severity;
  final double confidence;
  final List<Map<String, dynamic>> evidence;
  final List<String> recommendedActions;
  final List<String> warnings;
  final String timestamp;
  final int? processingTimeMs;
  
  AIAnalysisResult({
    required this.requestId,
    required this.componentId,
    required this.componentName,
    required this.meshId,
    required this.fault,
    required this.severity,
    required this.confidence,
    required this.evidence,
    required this.recommendedActions,
    required this.warnings,
    required this.timestamp,
    this.processingTimeMs,
  });
  
  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      requestId: json['request_id'],
      componentId: json['component_id'],
      componentName: json['component_name'],
      meshId: json['mesh_id'],
      fault: json['fault'],
      severity: json['severity'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      evidence: List<Map<String, dynamic>>.from(json['evidence'] ?? []),
      recommendedActions: List<String>.from(json['recommended_actions'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      timestamp: json['timestamp'],
      processingTimeMs: json['processing_time_ms'],
    );
  }
  
  factory AIAnalysisResult.demoSonar() {
    return AIAnalysisResult(
      requestId: 'demo-001',
      componentId: 'SONAR-001',
      componentName: 'Sonar Transducer Array',
      meshId: 'Mesh_042',
      fault: 'Casing fracture',
      severity: 'HIGH',
      confidence: 0.94,
      evidence: [
        {'type': 'keyword', 'keyword': 'sonar', 'matched_text': 'sonar', 'score': 0.98, 'component_id': 'SONAR-001'},
        {'type': 'phrase', 'keyword': 'abnormal vibration', 'matched_text': 'abnormal vibration', 'score': 0.95},
        {'type': 'phrase', 'keyword': 'casing fracture', 'matched_text': 'casing fracture', 'score': 0.98},
      ],
      recommendedActions: [
        'Inspect sonar transducer casing for visible fractures - power down system first',
        'Check vibration isolation mounts - replace if worn',
        'Run diagnostic: sonar --self-test',
        'If fracture confirmed, replace casing seal and schedule dry-dock inspection',
      ],
      warnings: ['Do not operate sonar with fractured casing - risk of water ingress'],
      timestamp: DateTime.now().toIso8601String(),
      processingTimeMs: 45,
    );
  }
}
