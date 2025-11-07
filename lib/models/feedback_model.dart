import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'feedback_model.g.dart';

enum FeedbackCategory {
  @JsonValue('general')
  general,
  @JsonValue('bug')
  bug,
  @JsonValue('feature')
  feature,
  @JsonValue('ui')
  ui,
  @JsonValue('performance')
  performance,
  @JsonValue('support')
  support,
}

enum FeedbackStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('reviewed')
  reviewed,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('resolved')
  resolved,
}

@JsonSerializable()
class FeedbackSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userType; // 'parent', 'child', 'coach'
  final String title;
  final String? description;
  final FeedbackCategory category;
  final int rating; // 1-5 stars
  final FeedbackStatus status;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime submittedAt;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? adminNotes;
  final Map<String, dynamic> metadata;

  FeedbackSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userType,
    required this.title,
    this.description,
    required this.category,
    required this.rating,
    this.status = FeedbackStatus.pending,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.adminNotes,
    this.metadata = const {},
  });

  factory FeedbackSubmission.fromJson(Map<String, dynamic> json) => _$FeedbackSubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackSubmissionToJson(this);

  FeedbackSubmission copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userType,
    String? title,
    String? description,
    FeedbackCategory? category,
    int? rating,
    FeedbackStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? adminNotes,
    Map<String, dynamic>? metadata,
  }) {
    return FeedbackSubmission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userType: userType ?? this.userType,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      adminNotes: adminNotes ?? this.adminNotes,
      metadata: metadata ?? this.metadata,
    );
  }

  static DateTime _dateTimeFromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    return DateTime.now();
  }

  static dynamic _dateTimeToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

  static DateTime? _dateTimeFromJsonNullable(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    return null;
  }

  static dynamic _dateTimeToJsonNullable(DateTime? dateTime) => 
      dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

