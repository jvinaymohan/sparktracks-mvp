import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'coach_update_model.g.dart';

/// Coach Update/Announcement Model (v3.0)
/// For coaches to post updates, announcements, and homework to students

enum UpdateType {
  @JsonValue('general')
  general,
  @JsonValue('class_cancelled')
  classCancelled,
  @JsonValue('homework')
  homework,
  @JsonValue('performance')
  performance,
  @JsonValue('achievement')
  achievement,
}

@JsonSerializable()
class CoachUpdate {
  final String id;
  final String coachId;
  final String coachName;
  final UpdateType type;
  final String title;
  final String message;
  final List<String> attachmentUrls;
  
  // Recipients
  final List<String> recipientStudentIds; // Empty = all students
  final List<String> recipientClassIds; // Specific classes
  
  // Engagement
  final int viewCount;
  final List<String> viewedByIds;
  final Map<String, String> reactions; // {studentId: emoji}
  
  // Homework specific
  final DateTime? dueDate;
  final bool? requiresSubmission;
  final List<String> submittedByIds;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;
  
  final bool isPinned;
  final bool sendNotification;

  CoachUpdate({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.type,
    required this.title,
    required this.message,
    this.attachmentUrls = const [],
    this.recipientStudentIds = const [],
    this.recipientClassIds = const [],
    this.viewCount = 0,
    this.viewedByIds = const [],
    this.reactions = const {},
    this.dueDate,
    this.requiresSubmission,
    this.submittedByIds = const [],
    required this.createdAt,
    this.isPinned = false,
    this.sendNotification = true,
  });

  factory CoachUpdate.fromJson(Map<String, dynamic> json) => _$CoachUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$CoachUpdateToJson(this);

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _toTimestamp(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class HomeworkAssignment {
  final String id;
  final String coachId;
  final String title;
  final String instructions;
  final List<String> attachmentUrls;
  final List<String> assignedToStudentIds;
  final List<String> assignedToClassIds;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime dueDate;
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;
  
  final int totalAssigned;
  final int totalSubmitted;
  final List<HomeworkSubmission> submissions;

  HomeworkAssignment({
    required this.id,
    required this.coachId,
    required this.title,
    required this.instructions,
    this.attachmentUrls = const [],
    this.assignedToStudentIds = const [],
    this.assignedToClassIds = const [],
    required this.dueDate,
    required this.createdAt,
    this.totalAssigned = 0,
    this.totalSubmitted = 0,
    this.submissions = const [],
  });

  factory HomeworkAssignment.fromJson(Map<String, dynamic> json) => _$HomeworkAssignmentFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkAssignmentToJson(this);

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _toTimestamp(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class HomeworkSubmission {
  final String id;
  final String studentId;
  final String studentName;
  final String homeworkId;
  final String? submissionText;
  final List<String> attachmentUrls;
  
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime submittedAt;
  
  final String? grade; // 'A', 'B', 'C', 'Pass', 'Needs Revision'
  final String? coachFeedback;

  HomeworkSubmission({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.homeworkId,
    this.submissionText,
    this.attachmentUrls = const [],
    required this.submittedAt,
    this.grade,
    this.coachFeedback,
  });

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) => _$HomeworkSubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkSubmissionToJson(this);

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _toTimestamp(DateTime date) => Timestamp.fromDate(date);
}

