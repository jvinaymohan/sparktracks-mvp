// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'makeup_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MakeupClass _$MakeupClassFromJson(Map<String, dynamic> json) => MakeupClass(
  id: json['id'] as String,
  originalClassId: json['originalClassId'] as String,
  enrollmentId: json['enrollmentId'] as String,
  studentId: json['studentId'] as String,
  parentId: json['parentId'] as String,
  coachId: json['coachId'] as String,
  missedDate: DateTime.parse(json['missedDate'] as String),
  missedReason: json['missedReason'] as String,
  proposedDate: json['proposedDate'] == null
      ? null
      : DateTime.parse(json['proposedDate'] as String),
  proposedTime: json['proposedTime'] == null
      ? null
      : DateTime.parse(json['proposedTime'] as String),
  status:
      $enumDecodeNullable(_$MakeupStatusEnumMap, json['status']) ??
      MakeupStatus.requested,
  requestedAt: DateTime.parse(json['requestedAt'] as String),
  respondedAt: json['respondedAt'] == null
      ? null
      : DateTime.parse(json['respondedAt'] as String),
  responseMessage: json['responseMessage'] as String?,
  scheduledDate: json['scheduledDate'] == null
      ? null
      : DateTime.parse(json['scheduledDate'] as String),
  meetingLink: json['meetingLink'] as String?,
  notificationSent: json['notificationSent'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MakeupClassToJson(MakeupClass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalClassId': instance.originalClassId,
      'enrollmentId': instance.enrollmentId,
      'studentId': instance.studentId,
      'parentId': instance.parentId,
      'coachId': instance.coachId,
      'missedDate': instance.missedDate.toIso8601String(),
      'missedReason': instance.missedReason,
      'proposedDate': instance.proposedDate?.toIso8601String(),
      'proposedTime': instance.proposedTime?.toIso8601String(),
      'status': _$MakeupStatusEnumMap[instance.status]!,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'responseMessage': instance.responseMessage,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'meetingLink': instance.meetingLink,
      'notificationSent': instance.notificationSent,
      'metadata': instance.metadata,
    };

const _$MakeupStatusEnumMap = {
  MakeupStatus.requested: 'requested',
  MakeupStatus.approved: 'approved',
  MakeupStatus.denied: 'denied',
  MakeupStatus.scheduled: 'scheduled',
  MakeupStatus.completed: 'completed',
  MakeupStatus.cancelled: 'cancelled',
};
