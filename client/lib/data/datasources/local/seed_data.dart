import '../../data/models/component_model.dart';
import '../../../core/constants/app_constants.dart';

/// Seed data service - provides demo data for offline-first operation
/// In production, this would use Drift DB, but for scaffold we provide in-memory seed
class SeedDataService {
  static List<ComponentModel> components = [];
  static List<Map<String, dynamic>> courses = [];
  static List<Map<String, dynamic>> diagnostics = [];
  static List<Map<String, dynamic>> knowledgeBase = [];
  
  static Future<void> initialize() async {
    components = [
      ComponentModel(
        id: 'SONAR-001',
        name: 'Sonar Transducer Array',
        category: 'Sonar',
        description: 'High-frequency sonar transducer array for seabed mapping and underwater object detection. Critical for oceanographic surveys.',
        manufacturer: 'Kongsberg Maritime',
        model: 'EM-2040',
        meshId: 'Mesh_042',
        x: 10.5, y: 2.3, z: 1.8,
        status: 'NORMAL',
        installationLocation: 'Bow Hull Mount',
        possibleFaults: ['Casing fracture', 'Abnormal vibration', 'Transducer failure', 'Calibration drift', 'Water ingress'],
        maintenanceProcedures: ['Inspect casing for fractures', 'Check vibration isolation mounts', 'Run self-test diagnostic', 'Calibrate transducer array', 'Check sealing'],
        trainingReferences: ['Sonar Operations Course', 'Transducer Maintenance'],
        documentationReferences: ['SONAR-001-Manual-v2.1', 'SONAR-Troubleshooting-Guide'],
        lastInspection: DateTime.now().subtract(const Duration(days: 30)),
        nextMaintenance: DateTime.now().add(const Duration(days: 60)),
        version: 1,
      ),
      ComponentModel(
        id: 'TELEM-001',
        name: 'Telemetry Transceiver Mast',
        category: 'Telemetry',
        description: 'High-gain telemetry mast for satellite and RF communication with research vessel and shore station.',
        manufacturer: 'Cobham SATCOM',
        model: 'SAILOR 900',
        meshId: 'Mesh_109',
        x: 5.2, y: 8.1, z: 12.5,
        status: 'NORMAL',
        installationLocation: 'Main Mast Top',
        possibleFaults: ['Signal loss', 'Mast corrosion', 'Transceiver failure', 'Antenna misalignment', 'Cable damage'],
        maintenanceProcedures: ['Check signal strength', 'Inspect mast for corrosion', 'Test transceiver', 'Verify antenna alignment', 'Check cable integrity'],
        trainingReferences: ['Telemetry Systems Course'],
        documentationReferences: ['TELEM-001-Manual'],
        lastInspection: DateTime.now().subtract(const Duration(days: 15)),
        nextMaintenance: DateTime.now().add(const Duration(days: 75)),
        version: 1,
      ),
      ComponentModel(
        id: 'ARGO-001',
        name: 'Autonomous Argo Profiling Float',
        category: 'Argo',
        description: 'Autonomous profiling float for measuring temperature, salinity, and pressure in deep ocean.',
        manufacturer: 'Teledyne Webb',
        model: 'APEX',
        meshId: 'Mesh_210',
        x: -3.5, y: 1.2, z: 0.5,
        status: 'NORMAL',
        installationLocation: 'Aft Deck Storage',
        possibleFaults: ['Buoyancy failure', 'Sensor drift', 'Battery low', 'Communication failure', 'Pressure housing leak'],
        maintenanceProcedures: ['Test buoyancy engine', 'Calibrate CTD sensors', 'Check battery voltage', 'Test Iridium communication', 'Inspect pressure housing'],
        trainingReferences: ['Argo Float Maintenance'],
        documentationReferences: ['ARGO-001-Manual'],
        lastInspection: DateTime.now().subtract(const Duration(days: 10)),
        nextMaintenance: DateTime.now().add(const Duration(days: 90)),
        version: 1,
      ),
      ComponentModel(
        id: 'ECHO-001',
        name: 'Multi-beam Echo Sounder',
        category: 'Echo Sounder',
        description: 'Multi-beam echo sounder for high-resolution bathymetric mapping.',
        manufacturer: 'Kongsberg',
        model: 'EM-304',
        meshId: 'Mesh_315',
        x: 8.0, y: 0.5, z: -2.0,
        status: 'NORMAL',
        installationLocation: 'Hull Mount Midship',
        possibleFaults: ['Echo loss', 'Calibration error', 'Beam failure', 'Motion sensor error', 'Sound velocity error'],
        maintenanceProcedures: ['Check echo returns', 'Run calibration', 'Test beamforming', 'Verify motion reference unit', 'Update sound velocity profile'],
        trainingReferences: ['Echo Sounder Operations'],
        documentationReferences: ['ECHO-001-Manual'],
        lastInspection: DateTime.now().subtract(const Duration(days: 20)),
        nextMaintenance: DateTime.now().add(const Duration(days: 50)),
        version: 1,
      ),
      ComponentModel(
        id: 'WINCH-001',
        name: 'Hydraulic Deep-Sea Winch',
        category: 'Winch',
        description: 'Hydraulic winch for deploying and recovering deep-sea instrumentation and sampling equipment.',
        manufacturer: 'Dynacon',
        model: 'D-2000',
        meshId: 'Mesh_410',
        x: -8.5, y: 2.0, z: 3.0,
        status: 'NORMAL',
        installationLocation: 'Aft Deck Port Side',
        possibleFaults: ['Hydraulic leak', 'Cable tension high', 'Motor overheat', 'Brake failure', 'Spooling issue'],
        maintenanceProcedures: ['Check hydraulic fluid level', 'Inspect cable for wear', 'Monitor motor temperature', 'Test brake system', 'Check spooling mechanism'],
        trainingReferences: ['Winch Operations and Safety'],
        documentationReferences: ['WINCH-001-Manual', 'Winch-Safety-Procedures'],
        lastInspection: DateTime.now().subtract(const Duration(days: 5)),
        nextMaintenance: DateTime.now().add(const Duration(days: 30)),
        version: 1,
      ),
    ];
    
    courses = [
      {
        'id': 'course-001',
        'title': 'Sonar Operations and Maintenance',
        'description': 'Comprehensive training on sonar transducer operations, troubleshooting, and maintenance for oceanographic surveys.',
        'category': 'Sonar',
        'difficulty': 'intermediate',
        'duration_minutes': 240,
        'progress': 82,
        'modules': [
          {
            'id': 'mod-001',
            'title': 'Sonar Fundamentals',
            'lessons': [
              {'id': 'les-001', 'title': 'Sonar Transducer Overview', 'type': 'video', 'duration': 30, 'completed': true},
              {'id': 'les-002', 'title': 'Installation and Calibration', 'type': 'document', 'duration': 45, 'completed': true},
            ]
          },
          {
            'id': 'mod-002',
            'title': 'Troubleshooting',
            'lessons': [
              {'id': 'les-003', 'title': 'Vibration and Fracture Diagnostics', 'type': 'video', 'duration': 60, 'completed': false},
              {'id': 'les-004', 'title': 'Quiz: Sonar Troubleshooting', 'type': 'quiz', 'duration': 20, 'completed': false},
            ]
          }
        ]
      },
      {
        'id': 'course-002',
        'title': 'Telemetry Systems',
        'description': 'Training on telemetry transceiver operations and signal troubleshooting.',
        'category': 'Telemetry',
        'difficulty': 'beginner',
        'duration_minutes': 180,
        'progress': 45,
        'modules': []
      },
      {
        'id': 'course-003',
        'title': 'Argo Float Maintenance',
        'description': 'Autonomous Argo profiling float maintenance and deployment procedures.',
        'category': 'Argo',
        'difficulty': 'advanced',
        'duration_minutes': 300,
        'progress': 0,
        'modules': []
      }
    ];
    
    diagnostics = [
      {
        'id': 'diag-001',
        'component_id': 'SONAR-001',
        'title': 'Sonar abnormal vibration',
        'description': 'Sonar transducer showing abnormal vibration during survey',
        'severity': 'HIGH',
        'status': 'OPEN',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'sync_status': 'PENDING',
      }
    ];
    
    knowledgeBase = [
      {
        'id': 'kb-001',
        'title': 'Sonar Transducer Array - Casing Fracture',
        'content': 'Sonar transducer casing fracture is critical fault...',
        'component_id': 'SONAR-001',
      }
    ];
  }
  
  static ComponentModel? getComponentByMeshId(String meshId) {
    try {
      return components.firstWhere((c) => c.meshId == meshId);
    } catch (e) {
      return null;
    }
  }
  
  static ComponentModel? getComponentById(String id) {
    try {
      return components.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
