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
