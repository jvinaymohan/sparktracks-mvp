import 'package:flutter/material.dart';
import '../models/achievement_model.dart';

class AchievementsProvider with ChangeNotifier {
  final List<Achievement> _achievements = [];
  final List<UserAchievement> _userAchievements = [];

  List<Achievement> get achievements => _achievements;
  List<UserAchievement> get userAchievements => _userAchievements;

  AchievementsProvider() {
    _initializeDefaultAchievements();
  }

  void _initializeDefaultAchievements() {
    _achievements.addAll([
      // Task Achievements
      Achievement(
        id: 'first_task',
        title: 'Getting Started',
        description: 'Complete your first task',
        iconName: 'star',
        category: AchievementCategory.tasks,
        tier: AchievementTier.bronze,
        requiredValue: 1,
        rewardPoints: 10,
      ),
      Achievement(
        id: 'task_master_10',
        title: 'Task Master',
        description: 'Complete 10 tasks',
        iconName: 'workspace_premium',
        category: AchievementCategory.tasks,
        tier: AchievementTier.silver,
        requiredValue: 10,
        rewardPoints: 50,
      ),
      Achievement(
        id: 'task_legend_50',
        title: 'Task Legend',
        description: 'Complete 50 tasks',
        iconName: 'military_tech',
        category: AchievementCategory.tasks,
        tier: AchievementTier.gold,
        requiredValue: 50,
        rewardPoints: 200,
      ),
      Achievement(
        id: 'task_champion_100',
        title: 'Task Champion',
        description: 'Complete 100 tasks',
        iconName: 'emoji_events',
        category: AchievementCategory.tasks,
        tier: AchievementTier.platinum,
        requiredValue: 100,
        rewardPoints: 500,
      ),
      
      // Points Achievements
      Achievement(
        id: 'points_100',
        title: 'Point Collector',
        description: 'Earn 100 points',
        iconName: 'toll',
        category: AchievementCategory.points,
        tier: AchievementTier.bronze,
        requiredValue: 100,
        rewardPoints: 10,
      ),
      Achievement(
        id: 'points_500',
        title: 'Point Hoarder',
        description: 'Earn 500 points',
        iconName: 'savings',
        category: AchievementCategory.points,
        tier: AchievementTier.silver,
        requiredValue: 500,
        rewardPoints: 50,
      ),
      Achievement(
        id: 'points_1000',
        title: 'Point Millionaire',
        description: 'Earn 1000 points',
        iconName: 'diamond',
        category: AchievementCategory.points,
        tier: AchievementTier.gold,
        requiredValue: 1000,
        rewardPoints: 100,
      ),
      
      // Streak Achievements
      Achievement(
        id: 'streak_3',
        title: 'On a Roll',
        description: 'Complete tasks for 3 days in a row',
        iconName: 'local_fire_department',
        category: AchievementCategory.streak,
        tier: AchievementTier.bronze,
        requiredValue: 3,
        rewardPoints: 25,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Complete tasks for 7 days in a row',
        iconName: 'whatshot',
        category: AchievementCategory.streak,
        tier: AchievementTier.silver,
        requiredValue: 7,
        rewardPoints: 100,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Unstoppable',
        description: 'Complete tasks for 30 days in a row',
        iconName: 'fireplace',
        category: AchievementCategory.streak,
        tier: AchievementTier.gold,
        requiredValue: 30,
        rewardPoints: 500,
      ),
      
      // Special Achievements
      Achievement(
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'Complete all assigned tasks in a week',
        iconName: 'verified',
        category: AchievementCategory.special,
        tier: AchievementTier.gold,
        requiredValue: 1,
        rewardPoints: 150,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete a task before 8 AM',
        iconName: 'light_mode',
        category: AchievementCategory.special,
        tier: AchievementTier.bronze,
        requiredValue: 1,
        rewardPoints: 20,
        isSecret: true,
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete a task after 10 PM',
        iconName: 'dark_mode',
        category: AchievementCategory.special,
        tier: AchievementTier.bronze,
        requiredValue: 1,
        rewardPoints: 20,
        isSecret: true,
      ),
    ]);
  }

  // Get achievements for a user
  List<Achievement> getAchievementsForUser(String userId) {
    final userAchievementIds = _userAchievements
        .where((ua) => ua.userId == userId)
        .map((ua) => ua.achievementId)
        .toSet();
    
    return _achievements.map((achievement) {
      if (userAchievementIds.contains(achievement.id)) {
        final userAchievement = _userAchievements.firstWhere(
          (ua) => ua.userId == userId && ua.achievementId == achievement.id,
        );
        return achievement.copyWith(unlockedAt: userAchievement.unlockedAt);
      }
      return achievement;
    }).toList();
  }

  // Check and unlock achievements
  void checkAchievements(String userId, {
    int? tasksCompleted,
    int? pointsEarned,
    int? streakDays,
    Map<String, dynamic>? special,
  }) {
    for (var achievement in _achievements) {
      // Skip if already unlocked
      if (_userAchievements.any((ua) => 
        ua.userId == userId && ua.achievementId == achievement.id
      )) {
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.category) {
        case AchievementCategory.tasks:
          if (tasksCompleted != null && tasksCompleted >= achievement.requiredValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.points:
          if (pointsEarned != null && pointsEarned >= achievement.requiredValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.streak:
          if (streakDays != null && streakDays >= achievement.requiredValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.special:
          if (special != null && special[achievement.id] == true) {
            shouldUnlock = true;
          }
          break;
      }

      if (shouldUnlock) {
        unlockAchievement(userId, achievement.id);
      }
    }
  }

  // Unlock achievement
  void unlockAchievement(String userId, String achievementId) {
    final userAchievement = UserAchievement(
      userId: userId,
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
      progress: 100,
    );
    
    _userAchievements.add(userAchievement);
    notifyListeners();
  }

  // Get progress for an achievement
  int getProgress(String userId, String achievementId, int currentValue) {
    final achievement = _achievements.firstWhere((a) => a.id == achievementId);
    return ((currentValue / achievement.requiredValue) * 100).clamp(0, 100).toInt();
  }

  // Get statistics
  Map<String, dynamic> getStats(String userId) {
    final unlocked = _userAchievements.where((ua) => ua.userId == userId).length;
    final total = _achievements.length;
    final totalPoints = _userAchievements
        .where((ua) => ua.userId == userId)
        .map((ua) => _achievements.firstWhere((a) => a.id == ua.achievementId).rewardPoints)
        .fold<int>(0, (sum, points) => sum + points);
    
    return {
      'unlocked': unlocked,
      'total': total,
      'percentage': total > 0 ? (unlocked / total * 100).toInt() : 0,
      'totalPoints': totalPoints,
    };
  }
}

