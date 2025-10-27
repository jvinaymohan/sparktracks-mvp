import 'package:json_annotation/json_annotation.dart';

part 'class_model.g.dart';

enum ClassStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum ClassType {
  @JsonValue('one_time')
  oneTime,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

enum LocationType {
  @JsonValue('in_person')
  inPerson,
  @JsonValue('online')
  online,
}

enum Currency {
  @JsonValue('USD')
  usd,
  @JsonValue('EUR')
  eur,
  @JsonValue('GBP')
  gbp,
  @JsonValue('CAD')
  cad,
  @JsonValue('AUD')
  aud,
  @JsonValue('INR')
  inr,
}

@JsonSerializable()
class Class {
  final String id;
  final String title;
  final String description;
  final String coachId;
  final ClassType type;
  final LocationType locationType;
  final String? location;
  final String? meetingLink;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double price;
  final Currency currency;
  final int maxStudents;
  final List<String> enrolledStudentIds;
  final ClassStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool isPromoted;
  final String? category;
  final List<String> tags;
  final Map<String, dynamic> requirements;
  final Map<String, dynamic> metadata;

  Class({
    required this.id,
    required this.title,
    required this.description,
    required this.coachId,
    required this.type,
    required this.locationType,
    this.location,
    this.meetingLink,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.price,
    required this.currency,
    required this.maxStudents,
    this.enrolledStudentIds = const [],
    this.status = ClassStatus.scheduled,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.isPromoted = false,
    this.category,
    this.tags = const [],
    this.requirements = const {},
    this.metadata = const {},
  });

  factory Class.fromJson(Map<String, dynamic> json) => _$ClassFromJson(json);
  Map<String, dynamic> toJson() => _$ClassToJson(this);

  Class copyWith({
    String? id,
    String? title,
    String? description,
    String? coachId,
    ClassType? type,
    LocationType? locationType,
    String? location,
    String? meetingLink,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? price,
    Currency? currency,
    int? maxStudents,
    List<String>? enrolledStudentIds,
    ClassStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    bool? isPromoted,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? metadata,
  }) {
    return Class(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coachId: coachId ?? this.coachId,
      type: type ?? this.type,
      locationType: locationType ?? this.locationType,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      maxStudents: maxStudents ?? this.maxStudents,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isPromoted: isPromoted ?? this.isPromoted,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      requirements: requirements ?? this.requirements,
      metadata: metadata ?? this.metadata,
    );
  }
}
