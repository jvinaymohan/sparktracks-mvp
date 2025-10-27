// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  parentId: json['parentId'] as String,
  childId: json['childId'] as String,
  coachId: json['coachId'] as String?,
  status:
      $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
      TaskStatus.pending,
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.medium,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0.0,
  completionNotes: json['completionNotes'] as String?,
  approvalNotes: json['approvalNotes'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category: json['category'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringPattern: json['recurringPattern'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'parentId': instance.parentId,
  'childId': instance.childId,
  'coachId': instance.coachId,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'rewardAmount': instance.rewardAmount,
  'completionNotes': instance.completionNotes,
  'approvalNotes': instance.approvalNotes,
  'imageUrls': instance.imageUrls,
  'category': instance.category,
  'tags': instance.tags,
  'isRecurring': instance.isRecurring,
  'recurringPattern': instance.recurringPattern,
  'metadata': instance.metadata,
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.completed: 'completed',
  TaskStatus.approved: 'approved',
  TaskStatus.rejected: 'rejected',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
};
