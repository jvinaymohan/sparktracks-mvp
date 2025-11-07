// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Class _$ClassFromJson(Map<String, dynamic> json) => Class(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  coachId: json['coachId'] as String,
  type: $enumDecode(_$ClassTypeEnumMap, json['type']),
  locationType: $enumDecode(_$LocationTypeEnumMap, json['locationType']),
  location: json['location'] as String?,
  meetingLink: json['meetingLink'] as String?,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  currency: $enumDecode(_$CurrencyEnumMap, json['currency']),
  maxStudents: (json['maxStudents'] as num).toInt(),
  enrolledStudentIds:
      (json['enrolledStudentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$ClassStatusEnumMap, json['status']) ??
      ClassStatus.scheduled,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  isPromoted: json['isPromoted'] as bool? ?? false,
  category: json['category'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  requirements: json['requirements'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  isPublic: json['isPublic'] as bool? ?? false,
  isGroupClass: json['isGroupClass'] as bool? ?? true,
  paymentSchedule: json['paymentSchedule'] as String? ?? 'per_class',
  makeUpClassesAllowed: json['makeUpClassesAllowed'] as bool? ?? false,
  shareableLink: json['shareableLink'] as String?,
  subcategory: json['subcategory'] as String?,
  skillLevel: $enumDecodeNullable(_$SkillLevelEnumMap, json['skillLevel']),
  minAge: (json['minAge'] as num?)?.toInt(),
  maxAge: (json['maxAge'] as num?)?.toInt(),
  minStudents: (json['minStudents'] as num?)?.toInt(),
  currentEnrollment: (json['currentEnrollment'] as num?)?.toInt() ?? 0,
  locationOption: $enumDecodeNullable(
    _$ClassLocationOptionEnumMap,
    json['locationOption'],
  ),
  facilityName: json['facilityName'] as String?,
  outdoorLocation: json['outdoorLocation'] as String?,
  travelFee: (json['travelFee'] as num?)?.toDouble(),
  maxTravelDistance: (json['maxTravelDistance'] as num?)?.toInt(),
  pricingModel: $enumDecodeNullable(
    _$PricingModelEnumMap,
    json['pricingModel'],
  ),
  monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble(),
  packagePrice: (json['packagePrice'] as num?)?.toDouble(),
  packageSessions: (json['packageSessions'] as num?)?.toInt(),
  offersTrial: json['offersTrial'] as bool? ?? false,
  trialPrice: (json['trialPrice'] as num?)?.toDouble(),
  trialDuration: (json['trialDuration'] as num?)?.toInt(),
  materials:
      (json['materials'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  prerequisites:
      (json['prerequisites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  includesProgressReports: json['includesProgressReports'] as bool? ?? false,
  includesHomework: json['includesHomework'] as bool? ?? false,
  includesCertificate: json['includesCertificate'] as bool? ?? false,
  includesRecordings: json['includesRecordings'] as bool? ?? false,
  cancellationHoursNotice:
      (json['cancellationHoursNotice'] as num?)?.toInt() ?? 24,
  cancellationFeePercent:
      (json['cancellationFeePercent'] as num?)?.toDouble() ?? 0.0,
  recurringWeekDays: (json['recurringWeekDays'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
  totalSessionsHeld: (json['totalSessionsHeld'] as num?)?.toInt(),
  averageAttendance: (json['averageAttendance'] as num?)?.toDouble(),
  studentRating: (json['studentRating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ClassToJson(Class instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'coachId': instance.coachId,
  'type': _$ClassTypeEnumMap[instance.type]!,
  'locationType': _$LocationTypeEnumMap[instance.locationType]!,
  'location': instance.location,
  'meetingLink': instance.meetingLink,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'price': instance.price,
  'currency': _$CurrencyEnumMap[instance.currency]!,
  'maxStudents': instance.maxStudents,
  'enrolledStudentIds': instance.enrolledStudentIds,
  'status': _$ClassStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'cancellationReason': instance.cancellationReason,
  'isPromoted': instance.isPromoted,
  'category': instance.category,
  'tags': instance.tags,
  'requirements': instance.requirements,
  'metadata': instance.metadata,
  'isPublic': instance.isPublic,
  'isGroupClass': instance.isGroupClass,
  'paymentSchedule': instance.paymentSchedule,
  'makeUpClassesAllowed': instance.makeUpClassesAllowed,
  'shareableLink': instance.shareableLink,
  'subcategory': instance.subcategory,
  'skillLevel': _$SkillLevelEnumMap[instance.skillLevel],
  'minAge': instance.minAge,
  'maxAge': instance.maxAge,
  'minStudents': instance.minStudents,
  'currentEnrollment': instance.currentEnrollment,
  'locationOption': _$ClassLocationOptionEnumMap[instance.locationOption],
  'facilityName': instance.facilityName,
  'outdoorLocation': instance.outdoorLocation,
  'travelFee': instance.travelFee,
  'maxTravelDistance': instance.maxTravelDistance,
  'pricingModel': _$PricingModelEnumMap[instance.pricingModel],
  'monthlyPrice': instance.monthlyPrice,
  'packagePrice': instance.packagePrice,
  'packageSessions': instance.packageSessions,
  'offersTrial': instance.offersTrial,
  'trialPrice': instance.trialPrice,
  'trialDuration': instance.trialDuration,
  'materials': instance.materials,
  'prerequisites': instance.prerequisites,
  'includesProgressReports': instance.includesProgressReports,
  'includesHomework': instance.includesHomework,
  'includesCertificate': instance.includesCertificate,
  'includesRecordings': instance.includesRecordings,
  'cancellationHoursNotice': instance.cancellationHoursNotice,
  'cancellationFeePercent': instance.cancellationFeePercent,
  'recurringWeekDays': instance.recurringWeekDays,
  'dayOfMonth': instance.dayOfMonth,
  'totalSessionsHeld': instance.totalSessionsHeld,
  'averageAttendance': instance.averageAttendance,
  'studentRating': instance.studentRating,
};

const _$ClassTypeEnumMap = {
  ClassType.oneTime: 'one_time',
  ClassType.weekly: 'weekly',
  ClassType.monthly: 'monthly',
};

const _$LocationTypeEnumMap = {
  LocationType.inPerson: 'in_person',
  LocationType.online: 'online',
};

const _$CurrencyEnumMap = {
  Currency.usd: 'USD',
  Currency.eur: 'EUR',
  Currency.gbp: 'GBP',
  Currency.cad: 'CAD',
  Currency.aud: 'AUD',
  Currency.inr: 'INR',
};

const _$ClassStatusEnumMap = {
  ClassStatus.scheduled: 'scheduled',
  ClassStatus.ongoing: 'ongoing',
  ClassStatus.completed: 'completed',
  ClassStatus.cancelled: 'cancelled',
};

const _$SkillLevelEnumMap = {
  SkillLevel.beginner: 'beginner',
  SkillLevel.intermediate: 'intermediate',
  SkillLevel.advanced: 'advanced',
  SkillLevel.expert: 'expert',
  SkillLevel.allLevels: 'all_levels',
};

const _$ClassLocationOptionEnumMap = {
  ClassLocationOption.coachLocation: 'coach_location',
  ClassLocationOption.studentLocation: 'student_location',
  ClassLocationOption.online: 'online',
  ClassLocationOption.outdoor: 'outdoor',
  ClassLocationOption.flexible: 'flexible',
};

const _$PricingModelEnumMap = {
  PricingModel.perSession: 'per_session',
  PricingModel.monthly: 'monthly',
  PricingModel.package: 'package',
  PricingModel.flexible: 'flexible',
};
