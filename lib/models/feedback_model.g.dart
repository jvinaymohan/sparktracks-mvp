// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackSubmission _$FeedbackSubmissionFromJson(Map<String, dynamic> json) =>
    FeedbackSubmission(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userType: json['userType'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$FeedbackCategoryEnumMap, json['category']),
      rating: (json['rating'] as num).toInt(),
      status:
          $enumDecodeNullable(_$FeedbackStatusEnumMap, json['status']) ??
          FeedbackStatus.pending,
      submittedAt: FeedbackSubmission._dateTimeFromJson(json['submittedAt']),
      reviewedAt: FeedbackSubmission._dateTimeFromJsonNullable(
        json['reviewedAt'],
      ),
      reviewedBy: json['reviewedBy'] as String?,
      adminNotes: json['adminNotes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FeedbackSubmissionToJson(
  FeedbackSubmission instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userEmail': instance.userEmail,
  'userType': instance.userType,
  'title': instance.title,
  'description': instance.description,
  'category': _$FeedbackCategoryEnumMap[instance.category]!,
  'rating': instance.rating,
  'status': _$FeedbackStatusEnumMap[instance.status]!,
  'submittedAt': FeedbackSubmission._dateTimeToJson(instance.submittedAt),
  'reviewedAt': FeedbackSubmission._dateTimeToJsonNullable(instance.reviewedAt),
  'reviewedBy': instance.reviewedBy,
  'adminNotes': instance.adminNotes,
  'metadata': instance.metadata,
};

const _$FeedbackCategoryEnumMap = {
  FeedbackCategory.general: 'general',
  FeedbackCategory.bug: 'bug',
  FeedbackCategory.feature: 'feature',
  FeedbackCategory.ui: 'ui',
  FeedbackCategory.performance: 'performance',
  FeedbackCategory.support: 'support',
};

const _$FeedbackStatusEnumMap = {
  FeedbackStatus.pending: 'pending',
  FeedbackStatus.reviewed: 'reviewed',
  FeedbackStatus.inProgress: 'inProgress',
  FeedbackStatus.resolved: 'resolved',
};
