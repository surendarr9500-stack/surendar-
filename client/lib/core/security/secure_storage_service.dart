import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Convenience methods
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
    required String username,
    required String role,
  }) async {
    await Future.wait([
      write(AppConstants.keyAccessToken, accessToken),
      write(AppConstants.keyRefreshToken, refreshToken),
      write(AppConstants.keyUserId, userId),
      write(AppConstants.keyDeviceId, deviceId),
      write(AppConstants.keyUsername, username),
      write(AppConstants.keyUserRole, role),
    ]);
  }

  Future<Map<String, String?>> getTokens() async {
    final results = await Future.wait([
      read(AppConstants.keyAccessToken),
      read(AppConstants.keyRefreshToken),
      read(AppConstants.keyUserId),
      read(AppConstants.keyDeviceId),
      read(AppConstants.keyUsername),
      read(AppConstants.keyUserRole),
    ]);
    return {
      AppConstants.keyAccessToken: results[0],
      AppConstants.keyRefreshToken: results[1],
      AppConstants.keyUserId: results[2],
      AppConstants.keyDeviceId: results[3],
      AppConstants.keyUsername: results[4],
      AppConstants.keyUserRole: results[5],
    };
  }

  Future<void> saveLastSyncAt(String isoTimestamp) async {
    await write(AppConstants.keyLastSyncAt, isoTimestamp);
  }

  Future<String?> getLastSyncAt() async {
    return await read(AppConstants.keyLastSyncAt);
  }

  Future<void> saveLastOnlineAt(DateTime dt) async {
    await write(AppConstants.keyLastOnlineAt, dt.toIso8601String());
  }

  Future<DateTime?> getLastOnlineAt() async {
    final str = await read(AppConstants.keyLastOnlineAt);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }
}
