class AppConstants {
  // Roles
  static const String roleAdministrator = 'administrator';
  static const String roleTrainingOfficer = 'training_officer';
  static const String roleFieldEngineer = 'field_engineer';
  static const String roleTechnician = 'technician';
  static const String roleSupervisor = 'supervisor';
  
  static const List<String> allRoles = [
    roleAdministrator,
    roleTrainingOfficer,
    roleFieldEngineer,
    roleTechnician,
    roleSupervisor,
  ];
  
  // Component Status
  static const String statusNormal = 'NORMAL';
  static const String statusWarning = 'WARNING';
  static const String statusDegraded = 'DEGRADED';
  static const String statusCritical = 'CRITICAL';
  static const String statusMaintenance = 'MAINTENANCE';
  static const String statusOffline = 'OFFLINE';
  static const String statusUnknown = 'UNKNOWN';
  
  static const List<String> componentStatuses = [
    statusNormal,
    statusWarning,
    statusDegraded,
    statusCritical,
    statusMaintenance,
    statusOffline,
    statusUnknown,
  ];
  
  // Sync Status
  static const String syncPending = 'PENDING';
  static const String syncSyncing = 'SYNCING';
  static const String syncSynced = 'SYNCED';
  static const String syncFailed = 'FAILED';
  static const String syncConflict = 'CONFLICT';
  
  // Diagnostic Status
  static const String diagnosticOpen = 'OPEN';
  static const String diagnosticInProgress = 'IN_PROGRESS';
  static const String diagnosticResolved = 'RESOLVED';
  static const String diagnosticClosed = 'CLOSED';
  
  // Severity
  static const String severityLow = 'LOW';
  static const String severityMedium = 'MEDIUM';
  static const String severityHigh = 'HIGH';
  static const String severityCritical = 'CRITICAL';
  
  // Demo Components
  static const List<Map<String, String>> demoComponents = [
    {
      'id': 'SONAR-001',
      'name': 'Sonar Transducer Array',
      'mesh_id': 'Mesh_042',
      'category': 'Sonar',
    },
    {
      'id': 'TELEM-001',
      'name': 'Telemetry Transceiver Mast',
      'mesh_id': 'Mesh_109',
      'category': 'Telemetry',
    },
    {
      'id': 'ARGO-001',
      'name': 'Autonomous Argo Profiling Float',
      'mesh_id': 'Mesh_210',
      'category': 'Argo',
    },
    {
      'id': 'ECHO-001',
      'name': 'Multi-beam Echo Sounder',
      'mesh_id': 'Mesh_315',
      'category': 'Echo Sounder',
    },
    {
      'id': 'WINCH-001',
      'name': 'Hydraulic Deep-Sea Winch',
      'mesh_id': 'Mesh_410',
      'category': 'Winch',
    },
  ];
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyDeviceId = 'device_id';
  static const String keyUsername = 'username';
  static const String keyUserRole = 'user_role';
  static const String keyLastSyncAt = 'last_sync_at';
  static const String keyEncryptionKey = 'encryption_key';
  static const String keyOfflineLoginEnabled = 'offline_login_enabled';
  static const String keyLastOnlineAt = 'last_online_at';
  
  // Audit Events
  static const String auditLogin = 'LOGIN';
  static const String auditLogout = 'LOGOUT';
  static const String auditDocumentAccess = 'DOCUMENT_ACCESS';
  static const String auditTrainingCompleted = 'TRAINING_COMPLETED';
  static const String auditDiagnosticCreated = 'DIAGNOSTIC_CREATED';
  static const String auditDiagnosticUpdated = 'DIAGNOSTIC_UPDATED';
  static const String auditAiAnalysis = 'AI_ANALYSIS';
  static const String auditComponentInspected = 'COMPONENT_INSPECTED';
  static const String auditSyncStarted = 'SYNC_STARTED';
  static const String auditSyncCompleted = 'SYNC_COMPLETED';
  static const String auditSyncFailed = 'SYNC_FAILED';
  static const String auditAdminAction = 'ADMIN_ACTION';
}
