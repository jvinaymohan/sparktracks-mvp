// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  coachId: json['coachId'] as String,
  parentId: json['parentId'] as String,
  parentName: json['parentName'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isFlagged: json['isFlagged'] as bool? ?? false,
  flagReason: json['flagReason'] as String?,
  classId: json['classId'] as String?,
  className: json['className'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'coachId': instance.coachId,
  'parentId': instance.parentId,
  'parentName': instance.parentName,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isFlagged': instance.isFlagged,
  'flagReason': instance.flagReason,
  'classId': instance.classId,
  'className': instance.className,
  'tags': instance.tags,
};
