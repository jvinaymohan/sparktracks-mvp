import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'student_progress_model.g.dart';

/// Student Progress Tracking Model (v3.0)
/// Comprehensive progress tracking for coach-student relationship

@JsonSerializable()
class StudentProgress {
  final String id;
  final String studentId;
  final String coachId;
  final String? classId;
  
  // Overall Progress
  final int overallScore; // 0-100
  final String skillLevel; // 'beginner', 'intermediate', 'advanced'
  final double attendanceRate; // 0-100%
  final int totalSessionsAttended;
  final int totalSessionsScheduled;
  
  // Skill Assessments (specific to specialization)
  final Map<String, SkillAssessment> skillAssessments; // e.g., {'forehand': {rating: 4, notes: '...'}}
  
  // Goals & Milestones
  final List<StudentGoal> goals;
  final List<Milestone> milestones;
  
  // Coach Notes
  final List<CoachNote> notes;
  
  // Performance Trends
  final Map<String, double> performanceTrends; // e.g., {'month_1': 60, 'month_2': 75}
  
  // Timestamps
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime lastUpdated;
  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;

  StudentProgress({
    required this.id,
    required this.studentId,
    required this.coachId,
    this.classId,
    this.overallScore = 0,
    this.skillLevel = 'beginner',
    this.attendanceRate = 0,
    this.totalSessionsAttended = 0,
    this.totalSessionsScheduled = 0,
    this.skillAssessments = const {},
    this.goals = const [],
    this.milestones = const [],
    this.notes = const [],
    this.performanceTrends = const {},
    required this.lastUpdated,
    required this.createdAt,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) => _$StudentProgressFromJson(json);
  Map<String, dynamic> toJson() => _$StudentProgressToJson(this);

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static Timestamp _toTimestamp(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class SkillAssessment {
  final String skillName;
  final int rating; // 1-5 stars
  final String? notes;
  final DateTime assessedDate;
  final String trend; // 'improving', 'stable', 'needs_work'

  SkillAssessment({
    required this.skillName,
    required this.rating,
    this.notes,
    required this.assessedDate,
    this.trend = 'stable',
  });

  factory SkillAssessment.fromJson(Map<String, dynamic> json) => _$SkillAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$SkillAssessmentToJson(this);
}

@JsonSerializable()
class StudentGoal {
  final String id;
  final String goalText;
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdDate;
  final String? targetDate;

  StudentGoal({
    required this.id,
    required this.goalText,
    this.isCompleted = false,
    this.completedDate,
    required this.createdDate,
    this.targetDate,
  });

  factory StudentGoal.fromJson(Map<String, dynamic> json) => _$StudentGoalFromJson(json);
  Map<String, dynamic> toJson() => _$StudentGoalToJson(this);
}

@JsonSerializable()
class Milestone {
  final String id;
  final String title;
  final String? description;
  final DateTime achievedDate;
  final String category; // 'skill', 'attendance', 'performance'

  Milestone({
    required this.id,
    required this.title,
    this.description,
    required this.achievedDate,
    required this.category,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);
  Map<String, dynamic> toJson() => _$MilestoneToJson(this);
}

@JsonSerializable()
class CoachNote {
  final String id;
  final String noteText;
  final DateTime date;
  final String category; // 'positive', 'needs_improvement', 'milestone', 'general'
  final bool isPrivate; // Only visible to coach

  CoachNote({
    required this.id,
    required this.noteText,
    required this.date,
    this.category = 'general',
    this.isPrivate = false,
  });

  factory CoachNote.fromJson(Map<String, dynamic> json) => _$CoachNoteFromJson(json);
  Map<String, dynamic> toJson() => _$CoachNoteToJson(this);
}

/// Student Grouping Helper
class StudentGrouping {
  static const String bySkillLevel = 'skill_level';
  static const String byClass = 'class';
  static const String byAge = 'age';
  static const String byPaymentStatus = 'payment';
  static const String custom = 'custom';
  
  static List<String> get allGroupingTypes => [
    bySkillLevel,
    byClass,
    byAge,
    byPaymentStatus,
    custom,
  ];
  
  static String getGroupingName(String type) {
    switch (type) {
      case bySkillLevel:
        return 'By Skill Level';
      case byClass:
        return 'By Class';
      case byAge:
        return 'By Age';
      case byPaymentStatus:
        return 'By Payment Status';
      case custom:
        return 'Custom Groups';
      default:
        return 'Unknown';
    }
  }
  
  static IconData getGroupingIcon(String type) {
    switch (type) {
      case bySkillLevel:
        return Icons.bar_chart;
      case byClass:
        return Icons.class_;
      case byAge:
        return Icons.cake;
      case byPaymentStatus:
        return Icons.payment;
      case custom:
        return Icons.label;
      default:
        return Icons.group;
    }
  }
}

