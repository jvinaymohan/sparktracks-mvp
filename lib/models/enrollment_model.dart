import 'package:json_annotation/json_annotation.dart';

part 'enrollment_model.g.dart';

enum EnrollmentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('waitlist')
  waitlist,
}

@JsonSerializable()
class Enrollment {
  final String id;
  final String classId;
  final String studentId;
  final String parentId;
  final EnrollmentStatus status;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double amountPaid;
  final double amountDue;
  final DateTime? lastPaymentDate;
  final DateTime? nextPaymentDate;
  final int attendanceCount;
  final int absenceCount;
  final List<String> makeUpClassIds;
  final Map<String, dynamic> metadata;

  Enrollment({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.parentId,
    this.status = EnrollmentStatus.pending,
    required this.enrolledAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.amountPaid = 0.0,
    this.amountDue = 0.0,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.attendanceCount = 0,
    this.absenceCount = 0,
    this.makeUpClassIds = const [],
    this.metadata = const {},
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) => _$EnrollmentFromJson(json);
  Map<String, dynamic> toJson() => _$EnrollmentToJson(this);

  Enrollment copyWith({
    String? id,
    String? classId,
    String? studentId,
    String? parentId,
    EnrollmentStatus? status,
    DateTime? enrolledAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    double? amountPaid,
    double? amountDue,
    DateTime? lastPaymentDate,
    DateTime? nextPaymentDate,
    int? attendanceCount,
    int? absenceCount,
    List<String>? makeUpClassIds,
    Map<String, dynamic>? metadata,
  }) {
    return Enrollment(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      absenceCount: absenceCount ?? this.absenceCount,
      makeUpClassIds: makeUpClassIds ?? this.makeUpClassIds,
      metadata: metadata ?? this.metadata,
    );
  }
}

