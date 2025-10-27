// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
  id: json['id'] as String,
  classId: json['classId'] as String,
  studentId: json['studentId'] as String,
  classDate: DateTime.parse(json['classDate'] as String),
  status:
      $enumDecodeNullable(_$AttendanceStatusEnumMap, json['status']) ??
      AttendanceStatus.unmarked,
  markedAt: json['markedAt'] == null
      ? null
      : DateTime.parse(json['markedAt'] as String),
  notes: json['notes'] as String?,
  markedBy: json['markedBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'studentId': instance.studentId,
      'classDate': instance.classDate.toIso8601String(),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'markedAt': instance.markedAt?.toIso8601String(),
      'notes': instance.notes,
      'markedBy': instance.markedBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late: 'late',
  AttendanceStatus.excused: 'excused',
  AttendanceStatus.unmarked: 'unmarked',
};

AttendanceSummary _$AttendanceSummaryFromJson(Map<String, dynamic> json) =>
    AttendanceSummary(
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      totalClasses: (json['totalClasses'] as num).toInt(),
      presentCount: (json['presentCount'] as num?)?.toInt() ?? 0,
      absentCount: (json['absentCount'] as num?)?.toInt() ?? 0,
      lateCount: (json['lateCount'] as num?)?.toInt() ?? 0,
      excusedCount: (json['excusedCount'] as num?)?.toInt() ?? 0,
      unmarkedCount: (json['unmarkedCount'] as num?)?.toInt() ?? 0,
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$AttendanceSummaryToJson(AttendanceSummary instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'classId': instance.classId,
      'totalClasses': instance.totalClasses,
      'presentCount': instance.presentCount,
      'absentCount': instance.absentCount,
      'lateCount': instance.lateCount,
      'excusedCount': instance.excusedCount,
      'unmarkedCount': instance.unmarkedCount,
      'attendanceRate': instance.attendanceRate,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
