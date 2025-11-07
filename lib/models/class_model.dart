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

enum SkillLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('expert')
  expert,
  @JsonValue('all_levels')
  allLevels,
}

enum ClassLocationOption {
  @JsonValue('coach_location')
  coachLocation,
  @JsonValue('student_location')
  studentLocation,
  @JsonValue('online')
  online,
  @JsonValue('outdoor')
  outdoor,
  @JsonValue('flexible')
  flexible,
}

enum PricingModel {
  @JsonValue('per_session')
  perSession,
  @JsonValue('monthly')
  monthly,
  @JsonValue('package')
  package,
  @JsonValue('flexible')
  flexible,
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
  
  // New fields for enhanced class management (v3.0)
  final bool isPublic; // Public (anyone can join) vs Private (invite only)
  final bool isGroupClass; // Group class vs Individual 1-on-1
  final String paymentSchedule; // 'per_class', 'monthly', 'term'
  final bool makeUpClassesAllowed; // Allow students to schedule make-up classes
  final String? shareableLink; // Link to share for enrollment
  
  // v3.0: Category & Skill Level
  final String? subcategory; // e.g., 'Tennis', 'Piano', 'Math'
  final SkillLevel? skillLevel;
  
  // v3.0: Age Range
  final int? minAge;
  final int? maxAge;
  
  // v3.0: Class Size Management
  final int? minStudents; // Minimum to run class
  final int currentEnrollment; // Current enrolled count
  
  // v3.0: Location Options
  final ClassLocationOption? locationOption;
  final String? facilityName; // e.g., "Austin Tennis Center"
  final String? outdoorLocation; // e.g., "City Park Courts"
  final double? travelFee; // If coach travels to student
  final int? maxTravelDistance; // In miles
  
  // v3.0: Pricing Models
  final PricingModel? pricingModel;
  final double? monthlyPrice; // For monthly unlimited
  final double? packagePrice; // For package deals
  final int? packageSessions; // Number of sessions in package
  
  // v3.0: Trial Options
  final bool offersTrial;
  final double? trialPrice;
  final int? trialDuration; // In minutes
  
  // v3.0: Materials & Requirements
  final List<String> materials; // What students need to bring
  final List<String> prerequisites; // Required skills/experience
  
  // v3.0: What's Included
  final bool includesProgressReports;
  final bool includesHomework;
  final bool includesCertificate;
  final bool includesRecordings; // Video recordings of sessions
  
  // v3.0: Cancellation Policy
  final int cancellationHoursNotice; // Hours notice required
  final double cancellationFeePercent; // Percentage fee
  
  // v3.0: Recurring Schedule (enhanced)
  final List<int>? recurringWeekDays; // [1=Mon, 2=Tue, ..., 7=Sun]
  final int? dayOfMonth; // For monthly classes
  
  // v3.0: Performance Tracking
  final int? totalSessionsHeld;
  final double? averageAttendance;
  final double? studentRating;

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
    this.isPublic = false,
    this.isGroupClass = true,
    this.paymentSchedule = 'per_class',
    this.makeUpClassesAllowed = false,
    this.shareableLink,
    // v3.0 fields
    this.subcategory,
    this.skillLevel,
    this.minAge,
    this.maxAge,
    this.minStudents,
    this.currentEnrollment = 0,
    this.locationOption,
    this.facilityName,
    this.outdoorLocation,
    this.travelFee,
    this.maxTravelDistance,
    this.pricingModel,
    this.monthlyPrice,
    this.packagePrice,
    this.packageSessions,
    this.offersTrial = false,
    this.trialPrice,
    this.trialDuration,
    this.materials = const [],
    this.prerequisites = const [],
    this.includesProgressReports = false,
    this.includesHomework = false,
    this.includesCertificate = false,
    this.includesRecordings = false,
    this.cancellationHoursNotice = 24,
    this.cancellationFeePercent = 0.0,
    this.recurringWeekDays,
    this.dayOfMonth,
    this.totalSessionsHeld,
    this.averageAttendance,
    this.studentRating,
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
    bool? isPublic,
    bool? isGroupClass,
    String? paymentSchedule,
    bool? makeUpClassesAllowed,
    String? shareableLink,
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
      isPublic: isPublic ?? this.isPublic,
      isGroupClass: isGroupClass ?? this.isGroupClass,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      makeUpClassesAllowed: makeUpClassesAllowed ?? this.makeUpClassesAllowed,
      shareableLink: shareableLink ?? this.shareableLink,
    );
  }
}

