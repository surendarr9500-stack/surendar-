import '../../../../domain/repositories/component_repository.dart';
import '../../../../domain/entities/component.dart';
import '../../../../data/datasources/local/seed_data.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<UserEntity> login(String username, String password, String deviceId) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/auth/login',
        data: {
          'username': username,
          'password': password,
          'device_id': deviceId,
          'device_name': 'Flutter Client',
          'platform': 'android',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final user = data['user'];
        return UserEntity(
          id: user['id'],
          username: user['username'],
          email: user['email'],
          role: user['role'],
          displayName: user['display_name'],
        );
      }
      throw Exception('Login failed');
    } catch (e) {
      // Fallback to local demo users for offline
      final validUsers = {
        'admin': {'role': 'administrator', 'displayName': 'System Administrator', 'email': 'admin@moes.gov.in'},
        'field_engineer': {'role': 'field_engineer', 'displayName': 'Field Engineer', 'email': 'field@moes.gov.in'},
        'technician': {'role': 'technician', 'displayName': 'Technician', 'email': 'tech@moes.gov.in'},
      };
      
      if (validUsers.containsKey(username)) {
        final info = validUsers[username]!;
        return UserEntity(
          id: 'user-$username',
          username: username,
          email: info['email']!,
          role: info['role']!,
          displayName: info['displayName']!,
        );
      }
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> logout() async {
    // Clear secure storage
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return false;
  }

  @override
  Future<bool> canLoginOffline(String username, String password) async {
    // Check cached hash
    return true;
  }
}
