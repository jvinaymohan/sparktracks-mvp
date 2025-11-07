// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachUpdate _$CoachUpdateFromJson(Map<String, dynamic> json) => CoachUpdate(
  id: json['id'] as String,
  coachId: json['coachId'] as String,
  coachName: json['coachName'] as String,
  type: $enumDecode(_$UpdateTypeEnumMap, json['type']),
  title: json['title'] as String,
  message: json['message'] as String,
  attachmentUrls:
      (json['attachmentUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  recipientStudentIds:
      (json['recipientStudentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  recipientClassIds:
      (json['recipientClassIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  viewedByIds:
      (json['viewedByIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  requiresSubmission: json['requiresSubmission'] as bool?,
  submittedByIds:
      (json['submittedByIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: CoachUpdate._fromTimestamp(json['createdAt']),
  isPinned: json['isPinned'] as bool? ?? false,
  sendNotification: json['sendNotification'] as bool? ?? true,
);

Map<String, dynamic> _$CoachUpdateToJson(CoachUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachId': instance.coachId,
      'coachName': instance.coachName,
      'type': _$UpdateTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'attachmentUrls': instance.attachmentUrls,
      'recipientStudentIds': instance.recipientStudentIds,
      'recipientClassIds': instance.recipientClassIds,
      'viewCount': instance.viewCount,
      'viewedByIds': instance.viewedByIds,
      'reactions': instance.reactions,
      'dueDate': instance.dueDate?.toIso8601String(),
      'requiresSubmission': instance.requiresSubmission,
      'submittedByIds': instance.submittedByIds,
      'createdAt': CoachUpdate._toTimestamp(instance.createdAt),
      'isPinned': instance.isPinned,
      'sendNotification': instance.sendNotification,
    };

const _$UpdateTypeEnumMap = {
  UpdateType.general: 'general',
  UpdateType.classCancelled: 'class_cancelled',
  UpdateType.homework: 'homework',
  UpdateType.performance: 'performance',
  UpdateType.achievement: 'achievement',
};

HomeworkAssignment _$HomeworkAssignmentFromJson(Map<String, dynamic> json) =>
    HomeworkAssignment(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      title: json['title'] as String,
      instructions: json['instructions'] as String,
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      assignedToStudentIds:
          (json['assignedToStudentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      assignedToClassIds:
          (json['assignedToClassIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dueDate: HomeworkAssignment._fromTimestamp(json['dueDate']),
      createdAt: HomeworkAssignment._fromTimestamp(json['createdAt']),
      totalAssigned: (json['totalAssigned'] as num?)?.toInt() ?? 0,
      totalSubmitted: (json['totalSubmitted'] as num?)?.toInt() ?? 0,
      submissions:
          (json['submissions'] as List<dynamic>?)
              ?.map(
                (e) => HomeworkSubmission.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HomeworkAssignmentToJson(HomeworkAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachId': instance.coachId,
      'title': instance.title,
      'instructions': instance.instructions,
      'attachmentUrls': instance.attachmentUrls,
      'assignedToStudentIds': instance.assignedToStudentIds,
      'assignedToClassIds': instance.assignedToClassIds,
      'dueDate': HomeworkAssignment._toTimestamp(instance.dueDate),
      'createdAt': HomeworkAssignment._toTimestamp(instance.createdAt),
      'totalAssigned': instance.totalAssigned,
      'totalSubmitted': instance.totalSubmitted,
      'submissions': instance.submissions,
    };

HomeworkSubmission _$HomeworkSubmissionFromJson(Map<String, dynamic> json) =>
    HomeworkSubmission(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      homeworkId: json['homeworkId'] as String,
      submissionText: json['submissionText'] as String?,
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      submittedAt: HomeworkSubmission._fromTimestamp(json['submittedAt']),
      grade: json['grade'] as String?,
      coachFeedback: json['coachFeedback'] as String?,
    );

Map<String, dynamic> _$HomeworkSubmissionToJson(HomeworkSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'homeworkId': instance.homeworkId,
      'submissionText': instance.submissionText,
      'attachmentUrls': instance.attachmentUrls,
      'submittedAt': HomeworkSubmission._toTimestamp(instance.submittedAt),
      'grade': instance.grade,
      'coachFeedback': instance.coachFeedback,
    };
