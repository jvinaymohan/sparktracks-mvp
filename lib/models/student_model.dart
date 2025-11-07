import 'package:json_annotation/json_annotation.dart';

part 'student_model.g.dart';

enum StudentStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('graduated')
  graduated,
}

@JsonSerializable()
class Student {
  final String id;
  final String userId;
  final String parentId;
  final String? coachId;
  final String? createdByCoachId; // Track which coach created this student (for privacy)
  final String name;
  final String email;
  final String? phone;
  final DateTime dateOfBirth;
  final String? avatar;
  final StudentStatus status;
  final DateTime enrolledAt;
  final DateTime? lastActiveAt;
  final String? colorCode; // For parent's color coding system
  final Map<String, dynamic> preferences;
  final List<String> classIds;
  final List<String> taskIds;
  final Map<String, dynamic> metadata;

  Student({
    required this.id,
    required this.userId,
    required this.parentId,
    this.coachId,
    this.createdByCoachId,
    required this.name,
    required this.email,
    this.phone,
    required this.dateOfBirth,
    this.avatar,
    this.status = StudentStatus.active,
    required this.enrolledAt,
    this.lastActiveAt,
    this.colorCode,
    this.preferences = const {},
    this.classIds = const [],
    this.taskIds = const [],
    this.metadata = const {},
  });

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);

  Student copyWith({
    String? id,
    String? userId,
    String? parentId,
    String? coachId,
    String? createdByCoachId,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? avatar,
    StudentStatus? status,
    DateTime? enrolledAt,
    DateTime? lastActiveAt,
    String? colorCode,
    Map<String, dynamic>? preferences,
    List<String>? classIds,
    List<String>? taskIds,
    Map<String, dynamic>? metadata,
  }) {
    return Student(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      coachId: coachId ?? this.coachId,
      createdByCoachId: createdByCoachId ?? this.createdByCoachId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      colorCode: colorCode ?? this.colorCode,
      preferences: preferences ?? this.preferences,
      classIds: classIds ?? this.classIds,
      taskIds: taskIds ?? this.taskIds,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class StudentEnrollment {
  final String id;
  final String studentId;
  final String classId;
  final DateTime enrolledAt;
  final DateTime? unenrolledAt;
  final String enrolledBy; // parentId or coachId
  final bool isActive;
  final Map<String, dynamic> metadata;

  StudentEnrollment({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.enrolledAt,
    this.unenrolledAt,
    required this.enrolledBy,
    this.isActive = true,
    this.metadata = const {},
  });

  factory StudentEnrollment.fromJson(Map<String, dynamic> json) => _$StudentEnrollmentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentEnrollmentToJson(this);
}
