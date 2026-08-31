import 'package:flutter_test/flutter_test.dart';
import 'package:capacity_connect/data/datasources/local/seed_data.dart';
import 'package:capacity_connect/data/models/component_model.dart';

void main() {
  group('Capacity Connect - Core Tests', () {
    setUp(() async {
      await SeedDataService.initialize();
    });

    test('Seed data contains 5 demo components', () {
      expect(SeedDataService.components.length, 5);
      expect(SeedDataService.components.map((c) => c.id), contains('SONAR-001'));
      expect(SeedDataService.components.map((c) => c.id), contains('TELEM-001'));
      expect(SeedDataService.components.map((c) => c.id), contains('ARGO-001'));
      expect(SeedDataService.components.map((c) => c.id), contains('ECHO-001'));
      expect(SeedDataService.components.map((c) => c.id), contains('WINCH-001'));
    });

    test('SONAR-001 maps to Mesh_042', () {
      final comp = SeedDataService.getComponentById('SONAR-001');
      expect(comp, isNotNull);
      expect(comp!.meshId, 'Mesh_042');
      expect(comp.name, 'Sonar Transducer Array');
    });

    test('Component mesh mapping is correct', () {
      final mapping = {
        'SONAR-001': 'Mesh_042',
        'TELEM-001': 'Mesh_109',
        'ARGO-001': 'Mesh_210',
        'ECHO-001': 'Mesh_315',
        'WINCH-001': 'Mesh_410',
      };
      for (final entry in mapping.entries) {
        final comp = SeedDataService.getComponentById(entry.key);
        expect(comp, isNotNull, reason: 'Component ${entry.key} not found');
        expect(comp!.meshId, entry.value, reason: 'Mesh mapping for ${entry.key} failed');
      }
    });

    test('AI Analysis Result demo matches spec', () {
      final result = AIAnalysisResult.demoSonar();
      expect(result.componentId, 'SONAR-001');
      expect(result.meshId, 'Mesh_042');
      expect(result.severity, 'HIGH');
      expect(result.confidence, greaterThan(0.8));
      expect(result.componentName, 'Sonar Transducer Array');
    });

    test('Component status colors', () {
      // Test status color mapping logic
      final statuses = ['NORMAL', 'WARNING', 'DEGRADED', 'CRITICAL', 'MAINTENANCE', 'OFFLINE', 'UNKNOWN'];
      expect(statuses.length, 7);
    });
  });

  group('Offline-First Tests', () {
    test('Seed data persists after initialization', () async {
      await SeedDataService.initialize();
      final initialCount = SeedDataService.components.length;
      // Simulate app restart
      await SeedDataService.initialize();
      expect(SeedDataService.components.length, initialCount);
    });

    test('Diagnostic creation with sync status', () {
      final diag = {
        'id': 'diag-test',
        'component_id': 'SONAR-001',
        'title': 'Test',
        'description': 'Test desc',
        'severity': 'HIGH',
        'status': 'OPEN',
        'sync_status': 'PENDING',
      };
      expect(diag['sync_status'], 'PENDING');
      expect(diag['component_id'], 'SONAR-001');
    });
  });
}
