import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? username;
  final String? role;
  final String? errorMessage;
  final bool isOffline;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.username,
    this.role,
    this.errorMessage,
    this.isOffline = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? username,
    String? role,
    String? errorMessage,
    bool? isOffline,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAdmin => role == AppConstants.roleAdministrator;
  bool get isFieldEngineer => role == AppConstants.roleFieldEngineer;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    await Future.delayed(const Duration(seconds: 1));
    
    final validUsers = {
      'admin': {'password': 'Admin@123', 'role': 'administrator'},
      'field_engineer': {'password': 'Field@123', 'role': 'field_engineer'},
      'technician': {'password': 'Tech@123', 'role': 'technician'},
      'training_officer': {'password': 'Training@123', 'role': 'training_officer'},
      'supervisor': {'password': 'Supervisor@123', 'role': 'supervisor'},
    };

    if (validUsers.containsKey(username) && validUsers[username]!['password'] == password) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: 'user-${username.hashCode}',
        username: username,
        role: validUsers[username]!['role'],
        errorMessage: null,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid credentials. Try demo: field_engineer / Field@123',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void setOffline(bool offline) {
    state = state.copyWith(isOffline: offline);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
