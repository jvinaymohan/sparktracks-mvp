import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'roadmap_item_model.g.dart';

enum ItemType {
  @JsonValue('feature')
  feature,
  @JsonValue('improvement')
  improvement,
  @JsonValue('bugFix')
  bugFix,
  @JsonValue('enhancement')
  enhancement,
  @JsonValue('technical')
  technical,
}

enum Priority {
  @JsonValue('critical')
  critical,
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low,
}

enum RoadmapStatus {
  @JsonValue('backlog')
  backlog,
  @JsonValue('planned')
  planned,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class RoadmapItem {
  final String id;
  final String title;
  final String? description;
  final ItemType type;
  final Priority priority;
  final RoadmapStatus status;
  final String? targetVersion; // e.g., "v3.0", "v2.6"
  final String? linkedFeedbackId; // Link to user feedback if applicable
  final String? assignedTo;
  final List<String> tags; // e.g., ["parent-feature", "ui-improvement"]
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? targetDate;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? completedAt;
  final String createdBy; // Admin who created it
  final String? notes; // Internal notes
  final Map<String, dynamic> metadata;

  RoadmapItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.priority,
    this.status = RoadmapStatus.backlog,
    this.targetVersion,
    this.linkedFeedbackId,
    this.assignedTo,
    this.tags = const [],
    this.targetDate,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.notes,
    this.metadata = const {},
  });

  factory RoadmapItem.fromJson(Map<String, dynamic> json) => _$RoadmapItemFromJson(json);
  Map<String, dynamic> toJson() => _$RoadmapItemToJson(this);

  RoadmapItem copyWith({
    String? id,
    String? title,
    String? description,
    ItemType? type,
    Priority? priority,
    RoadmapStatus? status,
    String? targetVersion,
    String? linkedFeedbackId,
    String? assignedTo,
    List<String>? tags,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? completedAt,
    String? createdBy,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return RoadmapItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetVersion: targetVersion ?? this.targetVersion,
      linkedFeedbackId: linkedFeedbackId ?? this.linkedFeedbackId,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  static DateTime _dateTimeFromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  static dynamic _dateTimeToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  static dynamic _dateTimeToJsonNullable(DateTime? dateTime) =>
      dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

