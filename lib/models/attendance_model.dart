import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

enum AttendanceStatus {
  @JsonValue('present')
  present,
  @JsonValue('absent')
  absent,
  @JsonValue('late')
  late,
  @JsonValue('excused')
  excused,
  @JsonValue('unmarked')
  unmarked,
}

@JsonSerializable()
class Attendance {
  final String id;
  final String classId;
  final String studentId;
  final DateTime classDate;
  final AttendanceStatus status;
  final DateTime? markedAt;
  final String? notes;
  final String markedBy; // coachId or system
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  Attendance({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.classDate,
    this.status = AttendanceStatus.unmarked,
    this.markedAt,
    this.notes,
    required this.markedBy,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  Attendance copyWith({
    String? id,
    String? classId,
    String? studentId,
    DateTime? classDate,
    AttendanceStatus? status,
    DateTime? markedAt,
    String? notes,
    String? markedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Attendance(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      classDate: classDate ?? this.classDate,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      notes: notes ?? this.notes,
      markedBy: markedBy ?? this.markedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class AttendanceSummary {
  final String studentId;
  final String classId;
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final int unmarkedCount;
  final double attendanceRate;
  final DateTime lastUpdated;

  AttendanceSummary({
    required this.studentId,
    required this.classId,
    required this.totalClasses,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
    this.unmarkedCount = 0,
    this.attendanceRate = 0.0,
    required this.lastUpdated,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) => _$AttendanceSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);
}
