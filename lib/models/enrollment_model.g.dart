// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enrollment _$EnrollmentFromJson(Map<String, dynamic> json) => Enrollment(
  id: json['id'] as String,
  classId: json['classId'] as String,
  studentId: json['studentId'] as String,
  parentId: json['parentId'] as String,
  status:
      $enumDecodeNullable(_$EnrollmentStatusEnumMap, json['status']) ??
      EnrollmentStatus.pending,
  enrolledAt: DateTime.parse(json['enrolledAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
  amountDue: (json['amountDue'] as num?)?.toDouble() ?? 0.0,
  lastPaymentDate: json['lastPaymentDate'] == null
      ? null
      : DateTime.parse(json['lastPaymentDate'] as String),
  nextPaymentDate: json['nextPaymentDate'] == null
      ? null
      : DateTime.parse(json['nextPaymentDate'] as String),
  attendanceCount: (json['attendanceCount'] as num?)?.toInt() ?? 0,
  absenceCount: (json['absenceCount'] as num?)?.toInt() ?? 0,
  makeUpClassIds:
      (json['makeUpClassIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$EnrollmentToJson(Enrollment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'studentId': instance.studentId,
      'parentId': instance.parentId,
      'status': _$EnrollmentStatusEnumMap[instance.status]!,
      'enrolledAt': instance.enrolledAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'amountPaid': instance.amountPaid,
      'amountDue': instance.amountDue,
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'nextPaymentDate': instance.nextPaymentDate?.toIso8601String(),
      'attendanceCount': instance.attendanceCount,
      'absenceCount': instance.absenceCount,
      'makeUpClassIds': instance.makeUpClassIds,
      'metadata': instance.metadata,
    };

const _$EnrollmentStatusEnumMap = {
  EnrollmentStatus.pending: 'pending',
  EnrollmentStatus.active: 'active',
  EnrollmentStatus.completed: 'completed',
  EnrollmentStatus.cancelled: 'cancelled',
  EnrollmentStatus.rejected: 'rejected',
  EnrollmentStatus.waitlist: 'waitlist',
};
