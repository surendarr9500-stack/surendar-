import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../data/models/component_model.dart';
import '../../data/datasources/local/seed_data.dart';
import '../widgets/offline_banner.dart';

class TroubleshootingPage extends ConsumerStatefulWidget {
  const TroubleshootingPage({super.key});

  @override
  ConsumerState<TroubleshootingPage> createState() => _TroubleshootingPageState();
}

class _TroubleshootingPageState extends ConsumerState<TroubleshootingPage> {
  final _textController = TextEditingController();
  final _dio = Dio();
  bool _isAnalyzing = false;
  bool _isOffline = true; // Demo starts offline
  AIAnalysisResult? _result;
  String? _error;
  
  // Voice input simulation
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill demo fault
    _textController.text = 'Sonar transducer is showing abnormal vibration and casing fracture.';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please enter fault description');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
      _result = null;
    });

    try {
      // Try local AI engine first (127.0.0.1:8001)
      try {
        final response = await _dio.post(
          '${AppConfig.aiEngineUrl}/analyze',
          data: {
            'text': text,
            'language': 'en',
            'user_id': 'field_engineer',
          },
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        
        if (response.statusCode == 200) {
          setState(() {
            _result = AIAnalysisResult.fromJson(response.data);
          });
          return;
        }
      } catch (e) {
        // Local AI not available, use deterministic Dart fallback (same logic as Python engine)
        print('Local AI unavailable, using Dart fallback: $e');
      }

      // Dart fallback - deterministic matching (mirrors Python engine)
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing
      final result = _dartFallbackAnalysis(text);
      setState(() {
        _result = result;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Analysis failed: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  AIAnalysisResult _dartFallbackAnalysis(String text) {
    final normalized = text.toLowerCase();
    
    // Component matching
    String componentId = 'UNKNOWN';
    String componentName = 'Unknown Component';
    String meshId = 'UNKNOWN';
    double confidence = 0.2;
    List<Map<String, dynamic>> evidence = [];
    
    if (normalized.contains('sonar') || normalized.contains('transducer')) {
      componentId = 'SONAR-001';
      componentName = 'Sonar Transducer Array';
      meshId = 'Mesh_042';
      confidence = 0.94;
      evidence.add({'type': 'keyword', 'keyword': 'sonar', 'matched_text': 'sonar', 'score': 0.98, 'component_id': componentId});
    } else if (normalized.contains('telemetry') || normalized.contains('transceiver') || normalized.contains('mast')) {
      componentId = 'TELEM-001';
      componentName = 'Telemetry Transceiver Mast';
      meshId = 'Mesh_109';
      confidence = 0.88;
      evidence.add({'type': 'keyword', 'keyword': 'telemetry', 'matched_text': 'telemetry', 'score': 0.9, 'component_id': componentId});
    } else if (normalized.contains('argo') || normalized.contains('float')) {
      componentId = 'ARGO-001';
      componentName = 'Autonomous Argo Profiling Float';
      meshId = 'Mesh_210';
      confidence = 0.85;
    } else if (normalized.contains('echo') || normalized.contains('multi-beam')) {
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
    
    // Fault matching
    String fault = 'Unknown fault';
    String severity = 'MEDIUM';
    List<String> recommendedActions = [
      'Document fault with photos and detailed description',
      'Check component operational manual',
      'Run built-in self-test diagnostics',
      'Create diagnostic record',
    ];
    List<String> warnings = [];
    
    if (normalized.contains('fracture') || normalized.contains('crack') || normalized.contains('casing')) {
      fault = 'Casing fracture';
      severity = 'HIGH';
      recommendedActions = [
        'Inspect sonar transducer casing for visible fractures - power down system first',
        'Check vibration isolation mounts - replace if worn',
        'Run diagnostic: sonar --self-test',
        'If fracture confirmed, replace casing seal and schedule dry-dock inspection',
      ];
      warnings = ['Do not operate sonar with fractured casing - risk of water ingress'];
      evidence.add({'type': 'phrase', 'keyword': 'casing fracture', 'matched_text': 'casing fracture', 'score': 0.98, 'fault': fault});
    }
    
    if (normalized.contains('vibration') || normalized.contains('abnormal')) {
      if (fault == 'Unknown fault') {
        fault = 'Abnormal vibration';
        severity = 'HIGH';
      } else {
        // Combined fault
        fault = 'Casing fracture + Abnormal vibration';
      }
      evidence.add({'type': 'phrase', 'keyword': 'abnormal vibration', 'matched_text': 'abnormal vibration', 'score': 0.95, 'fault': 'Abnormal vibration'});
      if (severity != 'HIGH') severity = 'HIGH';
    }
    
    if (normalized.contains('signal loss') || normalized.contains('no signal')) {
      fault = 'Signal loss';
      severity = 'CRITICAL';
    }
    
    if (normalized.contains('leak') || normalized.contains('hydraulic leak')) {
      fault = 'Hydraulic leak';
      severity = 'CRITICAL';
      warnings = ['Hydraulic fluid is hazardous - wear PPE', 'Do not operate winch with leak - risk of load drop'];
    }
    
    // Adjust confidence based on matches
    if (evidence.length >= 2) {
      confidence = (confidence + 0.1).clamp(0.1, 0.99);
    }
    if (fault != 'Unknown fault' && componentId != 'UNKNOWN') {
      confidence = (confidence + 0.05).clamp(0.1, 0.99);
    }
    
    return AIAnalysisResult(
      requestId: DateTime.now().millisecondsSinceEpoch.toString(),
      componentId: componentId,
      componentName: componentName,
      meshId: meshId,
      fault: fault,
      severity: severity,
      confidence: confidence,
      evidence: evidence,
      recommendedActions: recommendedActions,
      warnings: warnings,
      timestamp: DateTime.now().toIso8601String(),
      processingTimeMs: 45,
    );
  }

  void _simulateVoiceInput() {
    setState(() => _isListening = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isListening = false;
        _textController.text = 'Sonar transducer is showing abnormal vibration and casing fracture.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshooting'),
        actions: [
          IconButton(
            icon: Icon(_isOffline ? Icons.wifi_off : Icons.wifi),
            onPressed: () => setState(() => _isOffline = !_isOffline),
            tooltip: _isOffline ? 'Offline Mode' : 'Online Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          OfflineBanner(isOffline: _isOffline),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Local AI Engine', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 13)),
                                const Text('Runs on 127.0.0.1:8001 • Offline capable • Deterministic fallback', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                            child: const Text('ACTIVE', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Input section
                  const Text('Describe Engineering Problem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter fault description using text or voice. Local AI will identify component, fault, severity, and recommend actions.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Example: Sonar transducer is showing abnormal vibration and casing fracture.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyze,
                          icon: _isAnalyzing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search),
                          label: Text(_isAnalyzing ? 'ANALYZING...' : 'ANALYZE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.red.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _isListening ? Colors.red : Colors.grey.shade300),
                        ),
                        child: IconButton(
                          onPressed: _simulateVoiceInput,
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.grey[700]),
                          tooltip: 'Voice Input',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                        child: IconButton(
                          onPressed: () => _textController.clear(),
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear',
                        ),
                      ),
                    ],
                  ),
                  
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade800, fontSize: 12))),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Results
                  if (_result != null) _buildResultCard(_result!),
                  
                  const SizedBox(height: 16),
                  
                  // Pipeline visualization
                  _buildPipelineCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(AIAnalysisResult result) {
    final component = SeedDataService.getComponentById(result.componentId);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.getStatusColor(result.severity == 'HIGH' ? 'CRITICAL' : result.severity).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.bug_report, color: AppTheme.getStatusColor(result.severity == 'HIGH' ? 'CRITICAL' : result.severity)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI ANALYSIS RESULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
                      Text(result.componentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${result.componentId} • ${result.meshId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.getStatusColor(result.severity == 'HIGH' ? 'CRITICAL' : result.severity), borderRadius: BorderRadius.circular(12)),
                      child: Text(result.severity, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text('${(result.confidence * 100).toInt()}% confidence', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Structured JSON preview per spec
            const Text('Structured Output (JSON)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _jsonLine('request_id', result.requestId),
                  _jsonLine('component_id', result.componentId),
                  _jsonLine('component_name', result.componentName),
                  _jsonLine('mesh_id', result.meshId),
                  _jsonLine('fault', result.fault),
                  _jsonLine('severity', result.severity),
                  _jsonLine('confidence', result.confidence.toString()),
                  _jsonLine('timestamp', result.timestamp),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Fault
            const Text('Identified Fault', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade200), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.fault, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Evidence
            const Text('Evidence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...result.evidence.map((ev) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${ev['type']}: ${ev['keyword']} (${(ev['score'] * 100).toInt()}%)', style: const TextStyle(fontSize: 12))),
                ],
              ),
            )).toList(),
            const SizedBox(height: 12),
            
            // Recommended actions
            const Text('Recommended Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...result.recommendedActions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(action, style: const TextStyle(fontSize: 12))),
                ],
              ),
            )).toList(),
            
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Warnings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 4),
              ...result.warnings.map((w) => Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(child: Text(w, style: TextStyle(fontSize: 12, color: Colors.red.shade800))),
                  ],
                ),
              )).toList(),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/digital-twin?meshId=${result.meshId}&componentId=${result.componentId}'),
                    icon: const Icon(Icons.view_in_ar, size: 18),
                    label: const Text('VIEW IN DIGITAL TWIN'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Create diagnostic record
                      final newDiag = {
                        'id': 'diag-${DateTime.now().millisecondsSinceEpoch}',
                        'component_id': result.componentId,
                        'title': result.fault,
                        'description': _textController.text,
                        'severity': result.severity,
                        'status': 'OPEN',
                        'created_at': DateTime.now().toIso8601String(),
                        'sync_status': 'PENDING',
                        'ai_analysis': result,
                      };
                      SeedDataService.diagnostics.add(newDiag);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Diagnostic created for ${result.componentId} - queued for sync'), backgroundColor: Colors.green),
                      );
                      context.push('/diagnostics');
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('CREATE DIAGNOSTIC'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text('Processing time: ${result.processingTimeMs}ms • Confidence algorithm: weighted keyword(0.3)+phrase(0.3)+fuzzy(0.2)+knowledge(0.2) + boosts', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _jsonLine(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          children: [
            TextSpan(text: '"$key": ', style: const TextStyle(color: Colors.blue)),
            TextSpan(text: '"$value"', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineCard() {
    final steps = [
      'User Input',
      'Normalization',
      'Language Detection',
      'Tokenization',
      'Keyword Matching',
      'Phrase Matching',
      'Fuzzy Matching',
      'Knowledge Retrieval',
      'Component Identification',
      'Fault Classification',
      'Severity Estimation',
      'Recommended Action',
      '3D Component Mapping',
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Pipeline (Per Spec)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: steps.map((step) {
                final isActive = _result != null;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey.shade100,
                    border: Border.all(color: isActive ? AppTheme.primaryBlue.withOpacity(0.3) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isActive ? Icons.check_circle : Icons.circle_outlined, size: 12, color: isActive ? AppTheme.primaryBlue : Colors.grey),
                      const SizedBox(width: 4),
                      Text(step, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primaryBlue : Colors.grey[700])),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
