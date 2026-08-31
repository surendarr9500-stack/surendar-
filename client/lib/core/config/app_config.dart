class AppConfig {
  static const String appName = 'Capacity Connect';
  static const String appVersion = '1.0.0';
  static const String apiVersion = 'v1';
  
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
  
  static const String aiEngineUrl = String.fromEnvironment(
    'AI_ENGINE_URL',
    defaultValue: 'http://127.0.0.1:8001',
  );
  
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const bool isDevelopment = environment == 'development';
  static const bool isProduction = environment == 'production';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration aiEngineTimeout = Duration(seconds: 10);
  
  // Offline policy
  static const Duration offlineSessionMaxDuration = Duration(hours: 72);
  static const Duration offlineDeviceMaxWithoutOnline = Duration(days: 7);
  static const Duration sessionInactivityTimeout = Duration(minutes: 15);
  
  // Sync
  static const int syncBatchSize = 50;
  static const int syncMaxRetries = 5;
  static const Duration syncRetryBaseDelay = Duration(seconds: 1);
  
  // Storage
  static const int maxLogFileSizeMB = 10;
  static const int maxBackupCount = 3;
  
  // Security
  static const int bcryptRounds = 12;
  static const int jwtAccessTokenExpiryMinutes = 15;
  static const int jwtRefreshTokenExpiryDays = 7;
}
