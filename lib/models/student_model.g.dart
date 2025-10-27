// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: json['id'] as String,
  userId: json['userId'] as String,
  parentId: json['parentId'] as String,
  coachId: json['coachId'] as String?,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  avatar: json['avatar'] as String?,
  status:
      $enumDecodeNullable(_$StudentStatusEnumMap, json['status']) ??
      StudentStatus.active,
  enrolledAt: DateTime.parse(json['enrolledAt'] as String),
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  colorCode: json['colorCode'] as String?,
  preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
  classIds:
      (json['classIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  taskIds:
      (json['taskIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'parentId': instance.parentId,
  'coachId': instance.coachId,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'avatar': instance.avatar,
  'status': _$StudentStatusEnumMap[instance.status]!,
  'enrolledAt': instance.enrolledAt.toIso8601String(),
  'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
  'colorCode': instance.colorCode,
  'preferences': instance.preferences,
  'classIds': instance.classIds,
  'taskIds': instance.taskIds,
  'metadata': instance.metadata,
};

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'active',
  StudentStatus.inactive: 'inactive',
  StudentStatus.suspended: 'suspended',
  StudentStatus.graduated: 'graduated',
};

StudentEnrollment _$StudentEnrollmentFromJson(Map<String, dynamic> json) =>
    StudentEnrollment(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
      unenrolledAt: json['unenrolledAt'] == null
          ? null
          : DateTime.parse(json['unenrolledAt'] as String),
      enrolledBy: json['enrolledBy'] as String,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$StudentEnrollmentToJson(StudentEnrollment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'classId': instance.classId,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'unenrolledAt': instance.unenrolledAt?.toIso8601String(),
      'enrolledBy': instance.enrolledBy,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };
