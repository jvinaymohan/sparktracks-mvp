// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$UserTypeEnumMap, json['type']),
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  parentId: json['parentId'] as String?,
  childIds:
      (json['childIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  coachId: json['coachId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  emailVerified: json['emailVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
  notificationPreferences: NotificationPreferences.fromJson(
    json['notificationPreferences'] as Map<String, dynamic>,
  ),
  paymentProfile: PaymentProfile.fromJson(
    json['paymentProfile'] as Map<String, dynamic>,
  ),
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  level: (json['level'] as num?)?.toInt() ?? 1,
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'type': _$UserTypeEnumMap[instance.type]!,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'parentId': instance.parentId,
  'childIds': instance.childIds,
  'coachId': instance.coachId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'emailVerified': instance.emailVerified,
  'isActive': instance.isActive,
  'preferences': instance.preferences,
  'notificationPreferences': instance.notificationPreferences.toJson(),
  'paymentProfile': instance.paymentProfile.toJson(),
  'badges': instance.badges,
  'level': instance.level,
  'xp': instance.xp,
  'coins': instance.coins,
  'streak': instance.streak,
  'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
};

const _$UserTypeEnumMap = {
  UserType.parent: 'parent',
  UserType.child: 'child',
  UserType.coach: 'coach',
  UserType.admin: 'admin',
};

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => NotificationPreferences(
  emailEnabled: json['emailEnabled'] as bool? ?? true,
  smsEnabled: json['smsEnabled'] as bool? ?? false,
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  enabledTypes:
      (json['enabledTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$NotificationTypeEnumMap, e))
          .toList() ??
      const [NotificationType.email, NotificationType.push],
  preferredTime: json['preferredTime'] as String? ?? 'morning',
  timezone: json['timezone'] as String? ?? 'UTC',
  notificationSettings:
      (json['notificationSettings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {
        'weekly_summary': true,
        'payment_reminders': true,
        'class_reminders': true,
        'achievement_alerts': true,
        'security_alerts': true,
      },
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  NotificationPreferences instance,
) => <String, dynamic>{
  'emailEnabled': instance.emailEnabled,
  'smsEnabled': instance.smsEnabled,
  'pushEnabled': instance.pushEnabled,
  'enabledTypes': instance.enabledTypes
      .map((e) => _$NotificationTypeEnumMap[e]!)
      .toList(),
  'preferredTime': instance.preferredTime,
  'timezone': instance.timezone,
  'notificationSettings': instance.notificationSettings,
};

const _$NotificationTypeEnumMap = {
  NotificationType.email: 'email',
  NotificationType.sms: 'sms',
  NotificationType.push: 'push',
};

PaymentProfile _$PaymentProfileFromJson(Map<String, dynamic> json) =>
    PaymentProfile(
      currency: json['currency'] as String? ?? 'USD',
      pointsToDollarRatio:
          (json['pointsToDollarRatio'] as num?)?.toDouble() ?? 100.0,
      moneyGiven: (json['moneyGiven'] as num?)?.toDouble() ?? 0.0,
      moneyEarned: (json['moneyEarned'] as num?)?.toDouble() ?? 0.0,
      moneyDue: (json['moneyDue'] as num?)?.toDouble() ?? 0.0,
      moneySpent: (json['moneySpent'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      paymentLedger:
          (json['paymentLedger'] as List<dynamic>?)
              ?.map(
                (e) => PaymentLedgerEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      paymentSettings:
          json['paymentSettings'] as Map<String, dynamic>? ??
          const {
            'auto_deduct': true,
            'require_notes': true,
            'max_payment_retries': 3,
          },
    );

Map<String, dynamic> _$PaymentProfileToJson(PaymentProfile instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'pointsToDollarRatio': instance.pointsToDollarRatio,
      'moneyGiven': instance.moneyGiven,
      'moneyEarned': instance.moneyEarned,
      'moneyDue': instance.moneyDue,
      'moneySpent': instance.moneySpent,
      'availableBalance': instance.availableBalance,
      'paymentLedger': instance.paymentLedger,
      'paymentSettings': instance.paymentSettings,
    };

PaymentLedgerEntry _$PaymentLedgerEntryFromJson(Map<String, dynamic> json) =>
    PaymentLedgerEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      classId: json['classId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
      type: $enumDecode(_$PaymentTypeEnumMap, json['type']),
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$PaymentLedgerEntryToJson(PaymentLedgerEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'classId': instance.classId,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'note': instance.note,
      'type': _$PaymentTypeEnumMap[instance.type]!,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'transactionId': instance.transactionId,
    };

const _$PaymentTypeEnumMap = {
  PaymentType.regular: 'regular',
  PaymentType.bonus: 'bonus',
  PaymentType.classPayment: 'class_payment',
  PaymentType.refund: 'refund',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.failed: 'failed',
};
