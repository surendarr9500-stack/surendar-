import 'package:equatable/equatable.dart';

class ComponentEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String manufacturer;
  final String model;
  final String meshId;
  final double x, y, z;
  final String status;
  final String installationLocation;
  final List<String> possibleFaults;
  final List<String> maintenanceProcedures;
  final DateTime? lastInspection;
  final DateTime? nextMaintenance;
  final int version;

  const ComponentEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.manufacturer,
    required this.model,
    required this.meshId,
    required this.x,
    required this.y,
    required this.z,
    required this.status,
    required this.installationLocation,
    required this.possibleFaults,
    required this.maintenanceProcedures,
    this.lastInspection,
    this.nextMaintenance,
    this.version = 1,
  });

  @override
  List<Object?> get props => [id, meshId, status, version];
}

class DiagnosticEntity extends Equatable {
  final String id;
  final String componentId;
  final String reportedBy;
  final String title;
  final String description;
  final String severity;
  final String status;
  final DateTime createdAt;
  final String syncStatus;
  final int version;

  const DiagnosticEntity({
    required this.id,
    required this.componentId,
    required this.reportedBy,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.syncStatus,
    this.version = 1,
  });

  @override
  List<Object?> get props => [id, componentId, status, version];
}

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String role;
  final String displayName;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.displayName,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, username, role];
}
