// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playdate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playdate _$PlaydateFromJson(Map<String, dynamic> json) => Playdate(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  organizerId: json['organizerId'] as String,
  organizerName: json['organizerName'] as String,
  activityType: json['activityType'] as String,
  location: json['location'] as String,
  locationAddress: json['locationAddress'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  startTime: Playdate._fromTimestamp(json['startTime']),
  endTime: Playdate._fromTimestamp(json['endTime']),
  invites:
      (json['invites'] as List<dynamic>?)
          ?.map((e) => PlaydateInvite.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 20,
  currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 1,
  needsTransportation: json['needsTransportation'] as bool? ?? false,
  transportationOffers:
      (json['transportationOffers'] as List<dynamic>?)
          ?.map((e) => TransportationOffer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  hasSharedExpenses: json['hasSharedExpenses'] as bool? ?? false,
  expenseIds:
      (json['expenseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$PlaydateStatusEnumMap, json['status']) ??
      PlaydateStatus.upcoming,
  cancellationReason: json['cancellationReason'] as String?,
  createdAt: Playdate._fromTimestamp(json['createdAt']),
  updatedAt: Playdate._fromTimestampNullable(json['updatedAt']),
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PlaydateToJson(Playdate instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'organizerId': instance.organizerId,
  'organizerName': instance.organizerName,
  'activityType': instance.activityType,
  'location': instance.location,
  'locationAddress': instance.locationAddress,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'startTime': Playdate._toTimestamp(instance.startTime),
  'endTime': Playdate._toTimestamp(instance.endTime),
  'invites': instance.invites.map((e) => e.toJson()).toList(),
  'maxParticipants': instance.maxParticipants,
  'currentParticipants': instance.currentParticipants,
  'needsTransportation': instance.needsTransportation,
  'transportationOffers': instance.transportationOffers
      .map((e) => e.toJson())
      .toList(),
  'hasSharedExpenses': instance.hasSharedExpenses,
  'expenseIds': instance.expenseIds,
  'status': _$PlaydateStatusEnumMap[instance.status]!,
  'cancellationReason': instance.cancellationReason,
  'createdAt': Playdate._toTimestamp(instance.createdAt),
  'updatedAt': Playdate._toTimestampNullable(instance.updatedAt),
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
};

const _$PlaydateStatusEnumMap = {
  PlaydateStatus.upcoming: 'upcoming',
  PlaydateStatus.confirmed: 'confirmed',
  PlaydateStatus.inProgress: 'in_progress',
  PlaydateStatus.completed: 'completed',
  PlaydateStatus.cancelled: 'cancelled',
};

PlaydateInvite _$PlaydateInviteFromJson(Map<String, dynamic> json) =>
    PlaydateInvite(
      parentId: json['parentId'] as String,
      parentName: json['parentName'] as String,
      childIds: (json['childIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      childNames: (json['childNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status:
          $enumDecodeNullable(_$RSVPStatusEnumMap, json['status']) ??
          RSVPStatus.pending,
      notes: json['notes'] as String?,
      invitedAt: DateTime.parse(json['invitedAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$PlaydateInviteToJson(PlaydateInvite instance) =>
    <String, dynamic>{
      'parentId': instance.parentId,
      'parentName': instance.parentName,
      'childIds': instance.childIds,
      'childNames': instance.childNames,
      'status': _$RSVPStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'invitedAt': instance.invitedAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

const _$RSVPStatusEnumMap = {
  RSVPStatus.pending: 'pending',
  RSVPStatus.accepted: 'accepted',
  RSVPStatus.declined: 'declined',
  RSVPStatus.maybe: 'maybe',
};

TransportationOffer _$TransportationOfferFromJson(Map<String, dynamic> json) =>
    TransportationOffer(
      parentId: json['parentId'] as String,
      parentName: json['parentName'] as String,
      direction: json['direction'] as String,
      availableSeats: (json['availableSeats'] as num).toInt(),
      route:
          (json['route'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      vehicleInfo: json['vehicleInfo'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      acceptedByParentIds:
          (json['acceptedByParentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TransportationOfferToJson(
  TransportationOffer instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'parentName': instance.parentName,
  'direction': instance.direction,
  'availableSeats': instance.availableSeats,
  'route': instance.route,
  'vehicleInfo': instance.vehicleInfo,
  'phoneNumber': instance.phoneNumber,
  'acceptedByParentIds': instance.acceptedByParentIds,
};

SharedExpense _$SharedExpenseFromJson(Map<String, dynamic> json) =>
    SharedExpense(
      id: json['id'] as String,
      playdateId: json['playdateId'] as String,
      paidById: json['paidById'] as String,
      paidByName: json['paidByName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String,
      category: json['category'] as String,
      date: SharedExpense._fromTimestamp(json['date']),
      receiptUrl: json['receiptUrl'] as String?,
      splitType:
          $enumDecodeNullable(_$SplitTypeEnumMap, json['splitType']) ??
          SplitType.equal,
      splits: (json['splits'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      paidStatus: Map<String, bool>.from(json['paidStatus'] as Map),
      createdAt: SharedExpense._fromTimestamp(json['createdAt']),
    );

Map<String, dynamic> _$SharedExpenseToJson(SharedExpense instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playdateId': instance.playdateId,
      'paidById': instance.paidById,
      'paidByName': instance.paidByName,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'description': instance.description,
      'category': instance.category,
      'date': SharedExpense._toTimestamp(instance.date),
      'receiptUrl': instance.receiptUrl,
      'splitType': _$SplitTypeEnumMap[instance.splitType]!,
      'splits': instance.splits,
      'paidStatus': instance.paidStatus,
      'createdAt': SharedExpense._toTimestamp(instance.createdAt),
    };

const _$SplitTypeEnumMap = {
  SplitType.equal: 'equal',
  SplitType.custom: 'custom',
  SplitType.percentage: 'percentage',
  SplitType.perChild: 'per_child',
};

ParentBalance _$ParentBalanceFromJson(Map<String, dynamic> json) =>
    ParentBalance(
      parent1Id: json['parent1Id'] as String,
      parent2Id: json['parent2Id'] as String,
      balance: (json['balance'] as num).toDouble(),
      relatedExpenseIds: (json['relatedExpenseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      updatedAt: ParentBalance._fromTimestamp(json['updatedAt']),
    );

Map<String, dynamic> _$ParentBalanceToJson(ParentBalance instance) =>
    <String, dynamic>{
      'parent1Id': instance.parent1Id,
      'parent2Id': instance.parent2Id,
      'balance': instance.balance,
      'relatedExpenseIds': instance.relatedExpenseIds,
      'updatedAt': ParentBalance._toTimestamp(instance.updatedAt),
    };
