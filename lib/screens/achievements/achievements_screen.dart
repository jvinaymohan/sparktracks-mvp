import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/achievements_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../models/achievement_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Consumer3<AchievementsProvider, AuthProvider, TasksProvider>(
        builder: (context, achievementsProvider, authProvider, tasksProvider, _) {
          final userId = authProvider.currentUser?.id ?? '';
          final achievements = achievementsProvider.getAchievementsForUser(userId);
          final stats = achievementsProvider.getStats(userId);
          
          // Calculate user progress
          final myTasks = tasksProvider.tasks.where((t) => 
            t.assignedTo == userId && t.status == TaskStatus.approved
          ).toList();
          final tasksCompleted = myTasks.length;
          final pointsEarned = myTasks.fold<double>(0, (sum, t) => sum + t.rewardAmount).toInt();
          
          // Auto-check achievements
          achievementsProvider.checkAchievements(
            userId,
            tasksCompleted: tasksCompleted,
            pointsEarned: pointsEarned,
          );
          
          return Column(
            children: [
              // Stats Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      '${stats['unlocked']}/${stats['total']}',
                      style: AppTheme.headline3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Achievements Unlocked',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    LinearProgressIndicator(
                      value: stats['percentage'] / 100,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      '${stats['percentage']}% Complete • ${stats['totalPoints']} bonus points earned',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Achievement List
              Expanded(
                child: DefaultTabController(
                  length: 5,
                  child: Column(
                    children: [
                      const TabBar(
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'All'),
                          Tab(text: 'Tasks'),
                          Tab(text: 'Points'),
                          Tab(text: 'Streaks'),
                          Tab(text: 'Special'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAchievementsList(achievements, tasksCompleted, pointsEarned),
                            _buildAchievementsList(
                              achievements.where((a) => a.category == AchievementCategory.tasks).toList(),
                              tasksCompleted,
                              pointsEarned,
                            ),
                            _buildAchievementsList(
                              achievements.where((a) => a.category == AchievementCategory.points).toList(),
                              tasksCompleted,
                              pointsEarned,
                            ),
                            _buildAchievementsList(
                              achievements.where((a) => a.category == AchievementCategory.streak).toList(),
                              tasksCompleted,
                              pointsEarned,
                            ),
                            _buildAchievementsList(
                              achievements.where((a) => a.category == AchievementCategory.special).toList(),
                              tasksCompleted,
                              pointsEarned,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements, int tasksCompleted, int pointsEarned) {
    if (achievements.isEmpty) {
      return const Center(child: Text('No achievements in this category'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement, tasksCompleted, pointsEarned);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int tasksCompleted, int pointsEarned) {
    final isUnlocked = achievement.isUnlocked;
    final isSecret = achievement.isSecret && !isUnlocked;
    
    // Calculate progress
    int currentValue = 0;
    if (achievement.category == AchievementCategory.tasks) {
      currentValue = tasksCompleted;
    } else if (achievement.category == AchievementCategory.points) {
      currentValue = pointsEarned;
    }
    final progress = (currentValue / achievement.requiredValue).clamp(0.0, 1.0);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: isUnlocked ? 4 : 1,
      child: Container(
        decoration: isUnlocked
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: _getTierColors(achievement.tier),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.white : AppTheme.neutral200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(achievement.iconName),
                  size: 32,
                  color: isUnlocked ? _getTierColors(achievement.tier)[0] : AppTheme.neutral400,
                ),
              ),
              
              const SizedBox(width: AppTheme.spacingM),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isSecret ? '???' : achievement.title,
                            style: AppTheme.headline6.copyWith(
                              color: isUnlocked ? Colors.white : AppTheme.neutral900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSecret ? 'Secret achievement' : achievement.description,
                      style: AppTheme.bodySmall.copyWith(
                        color: isUnlocked ? Colors.white70 : AppTheme.neutral600,
                      ),
                    ),
                    if (!isUnlocked && !isSecret) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.neutral200,
                        valueColor: AlwaysStoppedAnimation<Color>(_getTierColors(achievement.tier)[0]),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currentValue / ${achievement.requiredValue}',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                    if (achievement.rewardPoints > 0) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: 14,
                            color: isUnlocked ? Colors.white : AppTheme.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${achievement.rewardPoints} points',
                            style: AppTheme.bodySmall.copyWith(
                              color: isUnlocked ? Colors.white : AppTheme.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getTierColors(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return [const Color(0xFFCD7F32), const Color(0xFF8B5A2B)];
      case AchievementTier.silver:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case AchievementTier.gold:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
      case AchievementTier.platinum:
        return [const Color(0xFFE5E4E2), const Color(0xFF9BA9B4)];
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'toll':
        return Icons.toll;
      case 'savings':
        return Icons.savings;
      case 'diamond':
        return Icons.diamond;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'fireplace':
        return Icons.fireplace;
      case 'verified':
        return Icons.verified;
      case 'light_mode':
        return Icons.light_mode;
      case 'dark_mode':
        return Icons.dark_mode;
      default:
        return Icons.emoji_events;
    }
  }
}

