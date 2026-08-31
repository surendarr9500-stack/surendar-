import '../entities/component.dart';

abstract class ComponentRepository {
  Future<List<ComponentEntity>> getAllComponents();
  Future<ComponentEntity?> getComponentById(String id);
  Future<ComponentEntity?> getComponentByMeshId(String meshId);
  Future<List<ComponentEntity>> getComponentsByStatus(String status);
  Future<void> updateComponentStatus(String id, String status);
  Future<List<ComponentEntity>> searchComponents(String query);
}

abstract class DiagnosticRepository {
  Future<List<DiagnosticEntity>> getAllDiagnostics();
  Future<DiagnosticEntity?> getDiagnosticById(String id);
  Future<List<DiagnosticEntity>> getDiagnosticsByComponent(String componentId);
  Future<String> createDiagnostic(DiagnosticEntity diagnostic);
  Future<void> updateDiagnostic(String id, Map<String, dynamic> updates);
  Future<void> deleteDiagnostic(String id);
}

abstract class AuthRepository {
  Future<UserEntity> login(String username, String password, String deviceId);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<bool> canLoginOffline(String username, String password);
}
