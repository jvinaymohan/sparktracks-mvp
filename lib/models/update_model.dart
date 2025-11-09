import 'package:cloud_firestore/cloud_firestore.dart';

/// Update/Announcement model for coach-to-parent/student communication
class Update {
  final String id;
  final String coachId;
  final String coachName;
  final String title;
  final String message;
  final DateTime createdAt;
  final UpdateScope scope; // specific_class or all_classes
  final String? classId; // Required if scope is specific_class
  final String? className;
  final List<String> recipientIds; // Parent/student IDs who should see this
  final bool isUrgent;
  
  Update({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.scope,
    this.classId,
    this.className,
    required this.recipientIds,
    this.isUrgent = false,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      coachName: json['coachName'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      scope: UpdateScope.values.firstWhere(
        (e) => e.toString() == 'UpdateScope.${json['scope']}',
        orElse: () => UpdateScope.specificClass,
      ),
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      recipientIds: List<String>.from(json['recipientIds'] as List),
      isUrgent: json['isUrgent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'coachName': coachName,
      'title': title,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'scope': scope.toString().split('.').last,
      'classId': classId,
      'className': className,
      'recipientIds': recipientIds,
      'isUrgent': isUrgent,
    };
  }
}

enum UpdateScope {
  specificClass,
  allClasses,
}

