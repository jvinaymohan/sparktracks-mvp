import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserType {
  @JsonValue('parent')
  parent,
  @JsonValue('child')
  child,
  @JsonValue('coach')
  coach,
}

enum NotificationType {
  @JsonValue('email')
  email,
  @JsonValue('sms')
  sms,
  @JsonValue('push')
  push,
}

@JsonSerializable(explicitToJson: true)
class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final String? phone;
  final String? avatar;
  final String? parentId;
  final List<String> childIds;
  final String? coachId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool emailVerified;
  final bool isActive;
  final Map<String, dynamic> preferences;
  final NotificationPreferences notificationPreferences;
  final PaymentProfile paymentProfile;
  final List<String> badges;
  final int level;
  final int xp;
  final int coins;
  final int streak;
  final DateTime? lastActiveAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    this.phone,
    this.avatar,
    this.parentId,
    this.childIds = const [],
    this.coachId,
    required this.createdAt,
    required this.updatedAt,
    this.emailVerified = false,
    this.isActive = true,
    this.preferences = const {},
    required this.notificationPreferences,
    required this.paymentProfile,
    this.badges = const [],
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.streak = 0,
    this.lastActiveAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserType? type,
    String? phone,
    String? avatar,
    String? parentId,
    List<String>? childIds,
    String? coachId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    bool? isActive,
    Map<String, dynamic>? preferences,
    NotificationPreferences? notificationPreferences,
    PaymentProfile? paymentProfile,
    List<String>? badges,
    int? level,
    int? xp,
    int? coins,
    int? streak,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      parentId: parentId ?? this.parentId,
      childIds: childIds ?? this.childIds,
      coachId: coachId ?? this.coachId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      paymentProfile: paymentProfile ?? this.paymentProfile,
      badges: badges ?? this.badges,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

@JsonSerializable()
class NotificationPreferences {
  final bool emailEnabled;
  final bool smsEnabled;
  final bool pushEnabled;
  final List<NotificationType> enabledTypes;
  final String preferredTime; // "morning", "afternoon", "evening"
  final String timezone;
  final Map<String, bool> notificationSettings;

  NotificationPreferences({
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.pushEnabled = true,
    this.enabledTypes = const [NotificationType.email, NotificationType.push],
    this.preferredTime = 'morning',
    this.timezone = 'UTC',
    this.notificationSettings = const {
      'weekly_summary': true,
      'payment_reminders': true,
      'class_reminders': true,
      'achievement_alerts': true,
      'security_alerts': true,
    },
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  NotificationPreferences copyWith({
    bool? emailEnabled,
    bool? smsEnabled,
    bool? pushEnabled,
    List<NotificationType>? enabledTypes,
    String? preferredTime,
    String? timezone,
    Map<String, bool>? notificationSettings,
  }) {
    return NotificationPreferences(
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      preferredTime: preferredTime ?? this.preferredTime,
      timezone: timezone ?? this.timezone,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

@JsonSerializable()
class PaymentProfile {
  final String currency;
  final double pointsToDollarRatio;
  final double moneyGiven;
  final double moneyEarned;
  final double moneyDue;
  final double moneySpent;
  final double availableBalance;
  final List<PaymentLedgerEntry> paymentLedger;
  final Map<String, dynamic> paymentSettings;

  PaymentProfile({
    this.currency = 'USD',
    this.pointsToDollarRatio = 100.0,
    this.moneyGiven = 0.0,
    this.moneyEarned = 0.0,
    this.moneyDue = 0.0,
    this.moneySpent = 0.0,
    this.availableBalance = 0.0,
    this.paymentLedger = const [],
    this.paymentSettings = const {
      'auto_deduct': true,
      'require_notes': true,
      'max_payment_retries': 3,
    },
  });

  factory PaymentProfile.fromJson(Map<String, dynamic> json) =>
      _$PaymentProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentProfileToJson(this);

  PaymentProfile copyWith({
    String? currency,
    double? pointsToDollarRatio,
    double? moneyGiven,
    double? moneyEarned,
    double? moneyDue,
    double? moneySpent,
    double? availableBalance,
    List<PaymentLedgerEntry>? paymentLedger,
    Map<String, dynamic>? paymentSettings,
  }) {
    return PaymentProfile(
      currency: currency ?? this.currency,
      pointsToDollarRatio: pointsToDollarRatio ?? this.pointsToDollarRatio,
      moneyGiven: moneyGiven ?? this.moneyGiven,
      moneyEarned: moneyEarned ?? this.moneyEarned,
      moneyDue: moneyDue ?? this.moneyDue,
      moneySpent: moneySpent ?? this.moneySpent,
      availableBalance: availableBalance ?? this.availableBalance,
      paymentLedger: paymentLedger ?? this.paymentLedger,
      paymentSettings: paymentSettings ?? this.paymentSettings,
    );
  }
}

@JsonSerializable()
class PaymentLedgerEntry {
  final String id;
  final String userId;
  final String? classId;
  final double amount;
  final DateTime date;
  final String note;
  final PaymentType type;
  final PaymentStatus status;
  final String? transactionId;

  PaymentLedgerEntry({
    required this.id,
    required this.userId,
    this.classId,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
    required this.status,
    this.transactionId,
  });

  factory PaymentLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$PaymentLedgerEntryFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentLedgerEntryToJson(this);
}

enum PaymentType {
  @JsonValue('regular')
  regular,
  @JsonValue('bonus')
  bonus,
  @JsonValue('class_payment')
  classPayment,
  @JsonValue('refund')
  refund,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('failed')
  failed,
} 