// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapItem _$RoadmapItemFromJson(Map<String, dynamic> json) => RoadmapItem(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$ItemTypeEnumMap, json['type']),
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  status:
      $enumDecodeNullable(_$RoadmapStatusEnumMap, json['status']) ??
      RoadmapStatus.backlog,
  targetVersion: json['targetVersion'] as String?,
  linkedFeedbackId: json['linkedFeedbackId'] as String?,
  assignedTo: json['assignedTo'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  targetDate: RoadmapItem._dateTimeFromJsonNullable(json['targetDate']),
  createdAt: RoadmapItem._dateTimeFromJson(json['createdAt']),
  completedAt: RoadmapItem._dateTimeFromJsonNullable(json['completedAt']),
  createdBy: json['createdBy'] as String,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$RoadmapItemToJson(RoadmapItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ItemTypeEnumMap[instance.type]!,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'status': _$RoadmapStatusEnumMap[instance.status]!,
      'targetVersion': instance.targetVersion,
      'linkedFeedbackId': instance.linkedFeedbackId,
      'assignedTo': instance.assignedTo,
      'tags': instance.tags,
      'targetDate': RoadmapItem._dateTimeToJsonNullable(instance.targetDate),
      'createdAt': RoadmapItem._dateTimeToJson(instance.createdAt),
      'completedAt': RoadmapItem._dateTimeToJsonNullable(instance.completedAt),
      'createdBy': instance.createdBy,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$ItemTypeEnumMap = {
  ItemType.feature: 'feature',
  ItemType.improvement: 'improvement',
  ItemType.bugFix: 'bugFix',
  ItemType.enhancement: 'enhancement',
  ItemType.technical: 'technical',
};

const _$PriorityEnumMap = {
  Priority.critical: 'critical',
  Priority.high: 'high',
  Priority.medium: 'medium',
  Priority.low: 'low',
};

const _$RoadmapStatusEnumMap = {
  RoadmapStatus.backlog: 'backlog',
  RoadmapStatus.planned: 'planned',
  RoadmapStatus.inProgress: 'inProgress',
  RoadmapStatus.completed: 'completed',
  RoadmapStatus.cancelled: 'cancelled',
};
