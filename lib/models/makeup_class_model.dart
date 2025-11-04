import 'package:json_annotation/json_annotation.dart';

part 'makeup_class_model.g.dart';

enum MakeupStatus {
  @JsonValue('requested')
  requested,
  @JsonValue('approved')
  approved,
  @JsonValue('denied')
  denied,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class MakeupClass {
  final String id;
  final String originalClassId;
  final String enrollmentId;
  final String studentId;
  final String parentId;
  final String coachId;
  final DateTime missedDate;
  final String missedReason;
  final DateTime? proposedDate;
  final DateTime? proposedTime;
  final MakeupStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? responseMessage;
  final DateTime? scheduledDate;
  final String? meetingLink;
  final bool notificationSent;
  final Map<String, dynamic> metadata;

  MakeupClass({
    required this.id,
    required this.originalClassId,
    required this.enrollmentId,
    required this.studentId,
    required this.parentId,
    required this.coachId,
    required this.missedDate,
    required this.missedReason,
    this.proposedDate,
    this.proposedTime,
    this.status = MakeupStatus.requested,
    required this.requestedAt,
    this.respondedAt,
    this.responseMessage,
    this.scheduledDate,
    this.meetingLink,
    this.notificationSent = false,
    this.metadata = const {},
  });

  factory MakeupClass.fromJson(Map<String, dynamic> json) => _$MakeupClassFromJson(json);
  Map<String, dynamic> toJson() => _$MakeupClassToJson(this);

  MakeupClass copyWith({
    String? id,
    String? originalClassId,
    String? enrollmentId,
    String? studentId,
    String? parentId,
    String? coachId,
    DateTime? missedDate,
    String? missedReason,
    DateTime? proposedDate,
    DateTime? proposedTime,
    MakeupStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? responseMessage,
    DateTime? scheduledDate,
    String? meetingLink,
    bool? notificationSent,
    Map<String, dynamic>? metadata,
  }) {
    return MakeupClass(
      id: id ?? this.id,
      originalClassId: originalClassId ?? this.originalClassId,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      studentId: studentId ?? this.studentId,
      parentId: parentId ?? this.parentId,
      coachId: coachId ?? this.coachId,
      missedDate: missedDate ?? this.missedDate,
      missedReason: missedReason ?? this.missedReason,
      proposedDate: proposedDate ?? this.proposedDate,
      proposedTime: proposedTime ?? this.proposedTime,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      meetingLink: meetingLink ?? this.meetingLink,
      notificationSent: notificationSent ?? this.notificationSent,
      metadata: metadata ?? this.metadata,
    );
  }
}

