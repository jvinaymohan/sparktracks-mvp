import 'package:cloud_firestore/cloud_firestore.dart';

/// Review model for coach ratings and feedback
class Review {
  final String id;
  final String coachId;
  final String parentId;
  final String parentName;
  final String? classId; // Optional - review for specific class or general
  final String? className;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final ReviewStatus status; // pending, approved, rejected
  final DateTime? approvedAt;
  final bool isVerified; // True if parent actually enrolled
  
  Review({
    required this.id,
    required this.coachId,
    required this.parentId,
    required this.parentName,
    this.classId,
    this.className,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.status,
    this.approvedAt,
    this.isVerified = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      parentId: json['parentId'] as String,
      parentName: json['parentName'] as String,
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: ReviewStatus.values.firstWhere(
        (e) => e.toString() == 'ReviewStatus.${json['status']}',
        orElse: () => ReviewStatus.pending,
      ),
      approvedAt: json['approvedAt'] != null 
          ? (json['approvedAt'] as Timestamp).toDate() 
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'parentId': parentId,
      'parentName': parentName,
      'classId': classId,
      'className': className,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'isVerified': isVerified,
    };
  }

  Review copyWith({
    String? id,
    String? coachId,
    String? parentId,
    String? parentName,
    String? classId,
    String? className,
    double? rating,
    String? comment,
    DateTime? createdAt,
    ReviewStatus? status,
    DateTime? approvedAt,
    bool? isVerified,
  }) {
    return Review(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

enum ReviewStatus {
  pending,
  approved,
  rejected,
}
