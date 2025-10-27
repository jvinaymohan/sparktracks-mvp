import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

enum TaskPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String description;
  final String parentId;
  final String childId;
  final String? coachId;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final double rewardAmount;
  final String? completionNotes;
  final String? approvalNotes;
  final List<String> imageUrls;
  final String? category;
  final List<String> tags;
  final bool isRecurring;
  final String? recurringPattern; // daily, weekly, monthly
  final Map<String, dynamic> metadata;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.parentId,
    required this.childId,
    this.coachId,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.approvedAt,
    this.rewardAmount = 0.0,
    this.completionNotes,
    this.approvalNotes,
    this.imageUrls = const [],
    this.category,
    this.tags = const [],
    this.isRecurring = false,
    this.recurringPattern,
    this.metadata = const {},
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? parentId,
    String? childId,
    String? coachId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? approvedAt,
    double? rewardAmount,
    String? completionNotes,
    String? approvalNotes,
    List<String>? imageUrls,
    String? category,
    List<String>? tags,
    bool? isRecurring,
    String? recurringPattern,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      coachId: coachId ?? this.coachId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      completionNotes: completionNotes ?? this.completionNotes,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      metadata: metadata ?? this.metadata,
    );
  }
}
