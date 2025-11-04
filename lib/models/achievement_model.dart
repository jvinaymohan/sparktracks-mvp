import 'package:json_annotation/json_annotation.dart';

part 'achievement_model.g.dart';

enum AchievementCategory {
  @JsonValue('tasks')
  tasks,
  @JsonValue('points')
  points,
  @JsonValue('streak')
  streak,
  @JsonValue('special')
  special,
}

enum AchievementTier {
  @JsonValue('bronze')
  bronze,
  @JsonValue('silver')
  silver,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum,
}

@JsonSerializable()
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementCategory category;
  final AchievementTier tier;
  final int requiredValue; // Tasks completed, points earned, etc.
  final int rewardPoints;
  final bool isSecret; // Hidden until unlocked
  final DateTime? unlockedAt;
  final Map<String, dynamic> metadata;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.iconName = 'emoji_events',
    required this.category,
    this.tier = AchievementTier.bronze,
    required this.requiredValue,
    this.rewardPoints = 0,
    this.isSecret = false,
    this.unlockedAt,
    this.metadata = const {},
  });

  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementCategory? category,
    AchievementTier? tier,
    int? requiredValue,
    int? rewardPoints,
    bool? isSecret,
    DateTime? unlockedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      requiredValue: requiredValue ?? this.requiredValue,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isSecret: isSecret ?? this.isSecret,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class UserAchievement {
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final int progress;
  final bool notified;

  UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.progress = 0,
    this.notified = false,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) => _$UserAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);
}

