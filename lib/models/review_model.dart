import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

/// Represents a review/rating for a coach
@JsonSerializable(explicitToJson: true)
class Review {
  final String id;
  final String coachId;
  final String parentId;
  final String parentName;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFlagged; // For moderation
  final String? flagReason;
  
  // Additional context
  final String? classId; // If review is for a specific class
  final String? className;
  final List<String> tags; // e.g., ['punctual', 'knowledgeable', 'patient']

  Review({
    required this.id,
    required this.coachId,
    required this.parentId,
    required this.parentName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isFlagged = false,
    this.flagReason,
    this.classId,
    this.className,
    this.tags = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp conversion
    if (json['createdAt'] is Timestamp) {
      json['createdAt'] = (json['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (json['updatedAt'] is Timestamp) {
      json['updatedAt'] = (json['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    
    return _$ReviewFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  Review copyWith({
    String? id,
    String? coachId,
    String? parentId,
    String? parentName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFlagged,
    String? flagReason,
    String? classId,
    String? className,
    List<String>? tags,
  }) {
    return Review(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFlagged: isFlagged ?? this.isFlagged,
      flagReason: flagReason ?? this.flagReason,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      tags: tags ?? this.tags,
    );
  }
}

/// Aggregated rating statistics for a coach
class CoachRatingStats {
  final String coachId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // e.g., {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}
  final List<String> commonTags;

  CoachRatingStats({
    required this.coachId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.commonTags,
  });

  factory CoachRatingStats.empty(String coachId) {
    return CoachRatingStats(
      coachId: coachId,
      averageRating: 0.0,
      totalReviews: 0,
      ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      commonTags: [],
    );
  }

  factory CoachRatingStats.fromReviews(String coachId, List<Review> reviews) {
    if (reviews.isEmpty) {
      return CoachRatingStats.empty(coachId);
    }

    final totalRating = reviews.fold<double>(0, (total, review) => total + review.rating);
    final averageRating = totalRating / reviews.length;

    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      final roundedRating = review.rating.round();
      distribution[roundedRating] = (distribution[roundedRating] ?? 0) + 1;
    }

    // Count tag frequency
    final tagCounts = <String, int>{};
    for (var review in reviews) {
      for (var tag in review.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Get top 5 most common tags
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final commonTags = sortedTags.take(5).map((e) => e.key).toList();

    return CoachRatingStats(
      coachId: coachId,
      averageRating: averageRating,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
      commonTags: commonTags,
    );
  }

  String get displayRating => averageRating.toStringAsFixed(1);
}

/// Common review tags
class ReviewTags {
  static const String punctual = 'Punctual';
  static const String knowledgeable = 'Knowledgeable';
  static const String patient = 'Patient';
  static const String engaging = 'Engaging';
  static const String organized = 'Organized';
  static const String responsive = 'Responsive';
  static const String professional = 'Professional';
  static const String creative = 'Creative';
  static const String motivating = 'Motivating';
  static const String goodWithKids = 'Good with Kids';
  static const String clearCommunicator = 'Clear Communicator';
  static const String flexible = 'Flexible';

  static List<String> get all => [
    punctual,
    knowledgeable,
    patient,
    engaging,
    organized,
    responsive,
    professional,
    creative,
    motivating,
    goodWithKids,
    clearCommunicator,
    flexible,
  ];
}

