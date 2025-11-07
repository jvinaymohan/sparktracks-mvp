// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentProgress _$StudentProgressFromJson(
  Map<String, dynamic> json,
) => StudentProgress(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  coachId: json['coachId'] as String,
  classId: json['classId'] as String?,
  overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
  skillLevel: json['skillLevel'] as String? ?? 'beginner',
  attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0,
  totalSessionsAttended: (json['totalSessionsAttended'] as num?)?.toInt() ?? 0,
  totalSessionsScheduled:
      (json['totalSessionsScheduled'] as num?)?.toInt() ?? 0,
  skillAssessments:
      (json['skillAssessments'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SkillAssessment.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  goals:
      (json['goals'] as List<dynamic>?)
          ?.map((e) => StudentGoal.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  milestones:
      (json['milestones'] as List<dynamic>?)
          ?.map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  notes:
      (json['notes'] as List<dynamic>?)
          ?.map((e) => CoachNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  performanceTrends:
      (json['performanceTrends'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  lastUpdated: StudentProgress._fromTimestamp(json['lastUpdated']),
  createdAt: StudentProgress._fromTimestamp(json['createdAt']),
);

Map<String, dynamic> _$StudentProgressToJson(StudentProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'coachId': instance.coachId,
      'classId': instance.classId,
      'overallScore': instance.overallScore,
      'skillLevel': instance.skillLevel,
      'attendanceRate': instance.attendanceRate,
      'totalSessionsAttended': instance.totalSessionsAttended,
      'totalSessionsScheduled': instance.totalSessionsScheduled,
      'skillAssessments': instance.skillAssessments,
      'goals': instance.goals,
      'milestones': instance.milestones,
      'notes': instance.notes,
      'performanceTrends': instance.performanceTrends,
      'lastUpdated': StudentProgress._toTimestamp(instance.lastUpdated),
      'createdAt': StudentProgress._toTimestamp(instance.createdAt),
    };

SkillAssessment _$SkillAssessmentFromJson(Map<String, dynamic> json) =>
    SkillAssessment(
      skillName: json['skillName'] as String,
      rating: (json['rating'] as num).toInt(),
      notes: json['notes'] as String?,
      assessedDate: DateTime.parse(json['assessedDate'] as String),
      trend: json['trend'] as String? ?? 'stable',
    );

Map<String, dynamic> _$SkillAssessmentToJson(SkillAssessment instance) =>
    <String, dynamic>{
      'skillName': instance.skillName,
      'rating': instance.rating,
      'notes': instance.notes,
      'assessedDate': instance.assessedDate.toIso8601String(),
      'trend': instance.trend,
    };

StudentGoal _$StudentGoalFromJson(Map<String, dynamic> json) => StudentGoal(
  id: json['id'] as String,
  goalText: json['goalText'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedDate: json['completedDate'] == null
      ? null
      : DateTime.parse(json['completedDate'] as String),
  createdDate: DateTime.parse(json['createdDate'] as String),
  targetDate: json['targetDate'] as String?,
);

Map<String, dynamic> _$StudentGoalToJson(StudentGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalText': instance.goalText,
      'isCompleted': instance.isCompleted,
      'completedDate': instance.completedDate?.toIso8601String(),
      'createdDate': instance.createdDate.toIso8601String(),
      'targetDate': instance.targetDate,
    };

Milestone _$MilestoneFromJson(Map<String, dynamic> json) => Milestone(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  achievedDate: DateTime.parse(json['achievedDate'] as String),
  category: json['category'] as String,
);

Map<String, dynamic> _$MilestoneToJson(Milestone instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'achievedDate': instance.achievedDate.toIso8601String(),
  'category': instance.category,
};

CoachNote _$CoachNoteFromJson(Map<String, dynamic> json) => CoachNote(
  id: json['id'] as String,
  noteText: json['noteText'] as String,
  date: DateTime.parse(json['date'] as String),
  category: json['category'] as String? ?? 'general',
  isPrivate: json['isPrivate'] as bool? ?? false,
);

Map<String, dynamic> _$CoachNoteToJson(CoachNote instance) => <String, dynamic>{
  'id': instance.id,
  'noteText': instance.noteText,
  'date': instance.date.toIso8601String(),
  'category': instance.category,
  'isPrivate': instance.isPrivate,
};
