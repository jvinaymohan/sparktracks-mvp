// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$AdminRoleEnumMap, json['role']),
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$AdminRoleEnumMap[instance.role]!,
  'permissions': instance.permissions,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'isActive': instance.isActive,
  'metadata': instance.metadata,
};

const _$AdminRoleEnumMap = {
  AdminRole.superAdmin: 'super_admin',
  AdminRole.admin: 'admin',
  AdminRole.moderator: 'moderator',
  AdminRole.support: 'support',
};

BetaSignupRequest _$BetaSignupRequestFromJson(Map<String, dynamic> json) =>
    BetaSignupRequest(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'pending',
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      processedBy: json['processedBy'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BetaSignupRequestToJson(BetaSignupRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
      'processedAt': instance.processedAt?.toIso8601String(),
      'processedBy': instance.processedBy,
      'notes': instance.notes,
    };

SystemSettings _$SystemSettingsFromJson(
  Map<String, dynamic> json,
) => SystemSettings(
  id: json['id'] as String,
  maintenanceMode: json['maintenanceMode'] as bool? ?? false,
  maintenanceMessage: json['maintenanceMessage'] as String?,
  allowNewRegistrations: json['allowNewRegistrations'] as bool? ?? true,
  requireEmailVerification: json['requireEmailVerification'] as bool? ?? false,
  maxChildrenPerParent: (json['maxChildrenPerParent'] as num?)?.toInt() ?? 10,
  maxClassesPerCoach: (json['maxClassesPerCoach'] as num?)?.toInt() ?? 50,
  featureFlags:
      (json['featureFlags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  updatedBy: json['updatedBy'] as String,
);

Map<String, dynamic> _$SystemSettingsToJson(SystemSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maintenanceMode': instance.maintenanceMode,
      'maintenanceMessage': instance.maintenanceMessage,
      'allowNewRegistrations': instance.allowNewRegistrations,
      'requireEmailVerification': instance.requireEmailVerification,
      'maxChildrenPerParent': instance.maxChildrenPerParent,
      'maxClassesPerCoach': instance.maxClassesPerCoach,
      'featureFlags': instance.featureFlags,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };
