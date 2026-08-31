import '../../data/models/component_model.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';

class TroubleshootUseCase {
  final Dio _dio;
  
  TroubleshootUseCase({Dio? dio}) : _dio = dio ?? Dio();

  Future<AIAnalysisResult> analyze(String text, {String? requestId}) async {
    if (text.trim().isEmpty) {
      throw Exception('Fault description is required');
    }
    if (text.length > 2000) {
      throw Exception('Text too long, max 2000 characters');
    }

    // Try local AI engine
    try {
      final response = await _dio.post(
        '${AppConfig.aiEngineUrl}/analyze',
        data: {
          'text': text,
          'language': 'en',
          'request_id': requestId,
        },
        options: Options(
          sendTimeout: AppConfig.aiEngineTimeout,
          receiveTimeout: AppConfig.aiEngineTimeout,
        ),
      );
      
      if (response.statusCode == 200) {
        return AIAnalysisResult.fromJson(response.data);
      }
    } catch (e) {
      // Fallback to Dart deterministic matcher
      print('Local AI unavailable, using Dart fallback: $e');
    }

    // Dart fallback - mirrors Python engine logic
    return _dartFallback(text, requestId: requestId);
  }

  AIAnalysisResult _dartFallback(String text, {String? requestId}) {
    final normalized = text.toLowerCase();
    String componentId = 'UNKNOWN';
    String componentName = 'Unknown Component';
    String meshId = 'UNKNOWN';
    double confidence = 0.2;
    List<Map<String, dynamic>> evidence = [];
    String fault = 'Unknown fault';
    String severity = 'MEDIUM';
    List<String> actions = [
      'Document fault with photos',
      'Check operational manual',
      'Run self-test diagnostics',
      'Create diagnostic record',
    ];
    List<String> warnings = [];

    // Component detection
    if (normalized.contains('sonar') || normalized.contains('transducer')) {
      componentId = 'SONAR-001';
      componentName = 'Sonar Transducer Array';
      meshId = 'Mesh_042';
      confidence = 0.94;
      evidence.add({'type': 'keyword', 'keyword': 'sonar', 'matched_text': 'sonar', 'score': 0.98, 'component_id': componentId});
    } else if (normalized.contains('telemetry') || normalized.contains('mast')) {
      componentId = 'TELEM-001';
      componentName = 'Telemetry Transceiver Mast';
      meshId = 'Mesh_109';
      confidence = 0.88;
    } else if (normalized.contains('argo') || normalized.contains('float')) {
      componentId = 'ARGO-001';
      componentName = 'Autonomous Argo Profiling Float';
      meshId = 'Mesh_210';
      confidence = 0.85;
    } else if (normalized.contains('echo')) {
      componentId = 'ECHO-001';
      componentName = 'Multi-beam Echo Sounder';
      meshId = 'Mesh_315';
      confidence = 0.82;
    } else if (normalized.contains('winch') || normalized.contains('hydraulic')) {
      componentId = 'WINCH-001';
      componentName = 'Hydraulic Deep-Sea Winch';
      meshId = 'Mesh_410';
      confidence = 0.80;
    }

    // Fault detection
    if (normalized.contains('fracture') || normalized.contains('crack') || normalized.contains('casing')) {
      fault = 'Casing fracture';
      severity = 'HIGH';
      actions = [
        'Inspect sonar transducer casing for visible fractures - power down system first',
        'Check vibration isolation mounts - replace if worn',
        'Run diagnostic: sonar --self-test',
        'If fracture confirmed, replace casing seal and schedule dry-dock inspection',
      ];
      warnings = ['Do not operate sonar with fractured casing - risk of water ingress'];
      evidence.add({'type': 'phrase', 'keyword': 'casing fracture', 'matched_text': 'casing fracture', 'score': 0.98});
    }
    if (normalized.contains('vibration') || normalized.contains('abnormal')) {
      if (fault == 'Unknown fault') {
        fault = 'Abnormal vibration';
        severity = 'HIGH';
      } else {
        fault = 'Casing fracture + Abnormal vibration';
      }
      evidence.add({'type': 'phrase', 'keyword': 'abnormal vibration', 'matched_text': 'abnormal vibration', 'score': 0.95});
    }
    if (normalized.contains('signal loss')) {
      fault = 'Signal loss';
      severity = 'CRITICAL';
    }
    if (normalized.contains('hydraulic leak') || normalized.contains('fluid leak')) {
      fault = 'Hydraulic leak';
      severity = 'CRITICAL';
      warnings = ['Hydraulic fluid hazardous - wear PPE', 'Do not operate winch with leak'];
    }

    if (evidence.length >= 2) {
      confidence = (confidence + 0.1).clamp(0.1, 0.99);
    }

    return AIAnalysisResult(
      requestId: requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      componentId: componentId,
      componentName: componentName,
      meshId: meshId,
      fault: fault,
      severity: severity,
      confidence: confidence,
      evidence: evidence,
      recommendedActions: actions,
      warnings: warnings,
      timestamp: DateTime.now().toIso8601String(),
      processingTimeMs: 45,
    );
  }
}
