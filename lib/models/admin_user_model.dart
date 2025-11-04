import 'package:json_annotation/json_annotation.dart';

part 'admin_user_model.g.dart';

enum AdminRole {
  @JsonValue('super_admin')
  superAdmin,
  @JsonValue('admin')
  admin,
  @JsonValue('moderator')
  moderator,
  @JsonValue('support')
  support,
}

@JsonSerializable()
class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.permissions = const [],
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.metadata = const {},
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);
  Map<String, dynamic> toJson() => _$AdminUserToJson(this);

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    AdminRole? role,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class BetaSignupRequest {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? message;
  final DateTime createdAt;
  final String status; // pending, approved, rejected
  final DateTime? processedAt;
  final String? processedBy;
  final String? notes;

  BetaSignupRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.message,
    required this.createdAt,
    this.status = 'pending',
    this.processedAt,
    this.processedBy,
    this.notes,
  });

  factory BetaSignupRequest.fromJson(Map<String, dynamic> json) => _$BetaSignupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BetaSignupRequestToJson(this);

  BetaSignupRequest copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? message,
    DateTime? createdAt,
    String? status,
    DateTime? processedAt,
    String? processedBy,
    String? notes,
  }) {
    return BetaSignupRequest(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
    );
  }
}

@JsonSerializable()
class SystemSettings {
  final String id;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final bool allowNewRegistrations;
  final bool requireEmailVerification;
  final int maxChildrenPerParent;
  final int maxClassesPerCoach;
  final Map<String, bool> featureFlags;
  final DateTime updatedAt;
  final String updatedBy;

  SystemSettings({
    required this.id,
    this.maintenanceMode = false,
    this.maintenanceMessage,
    this.allowNewRegistrations = true,
    this.requireEmailVerification = false,
    this.maxChildrenPerParent = 10,
    this.maxClassesPerCoach = 50,
    this.featureFlags = const {},
    required this.updatedAt,
    required this.updatedBy,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) => _$SystemSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SystemSettingsToJson(this);
}

