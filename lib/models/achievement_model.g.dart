// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  iconName: json['iconName'] as String? ?? 'emoji_events',
  category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
  tier:
      $enumDecodeNullable(_$AchievementTierEnumMap, json['tier']) ??
      AchievementTier.bronze,
  requiredValue: (json['requiredValue'] as num).toInt(),
  rewardPoints: (json['rewardPoints'] as num?)?.toInt() ?? 0,
  isSecret: json['isSecret'] as bool? ?? false,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'tier': _$AchievementTierEnumMap[instance.tier]!,
      'requiredValue': instance.requiredValue,
      'rewardPoints': instance.rewardPoints,
      'isSecret': instance.isSecret,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$AchievementCategoryEnumMap = {
  AchievementCategory.tasks: 'tasks',
  AchievementCategory.points: 'points',
  AchievementCategory.streak: 'streak',
  AchievementCategory.special: 'special',
};

const _$AchievementTierEnumMap = {
  AchievementTier.bronze: 'bronze',
  AchievementTier.silver: 'silver',
  AchievementTier.gold: 'gold',
  AchievementTier.platinum: 'platinum',
};

UserAchievement _$UserAchievementFromJson(Map<String, dynamic> json) =>
    UserAchievement(
      userId: json['userId'] as String,
      achievementId: json['achievementId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      notified: json['notified'] as bool? ?? false,
    );

Map<String, dynamic> _$UserAchievementToJson(UserAchievement instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'achievementId': instance.achievementId,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
      'progress': instance.progress,
      'notified': instance.notified,
    };
