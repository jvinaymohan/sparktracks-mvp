import '../services/supermemory_service.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/task_model.dart';

/// Helper class for managing app-specific memories in Supermemory
/// Tracks user preferences, activities, and provides AI recommendations
class AppMemoryHelper {
  final SupermemoryService _supermemory;

  AppMemoryHelper(this._supermemory);

  // ==================== USER PREFERENCES ====================

  /// Track when a user browses classes
  Future<void> trackClassBrowsing({
    required String userId,
    required String category,
    required String className,
  }) async {
    await _supermemory.addMemory(
      content: 'User browsed $className in $category category',
      metadata: {
        'user_id': userId,
        'type': 'class_browsing',
        'category': category,
        'class_name': className,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track class enrollment
  Future<void> trackClassEnrollment({
    required String userId,
    required Class classItem,
  }) async {
    await _supermemory.addMemory(
      content: 'User enrolled in ${classItem.title} (${classItem.category}) with coach ${classItem.coachId}',
      metadata: {
        'user_id': userId,
        'type': 'enrollment',
        'class_id': classItem.id,
        'category': classItem.category,
        'coach_id': classItem.coachId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track task completion patterns
  Future<void> trackTaskCompletion({
    required String userId,
    required String childId,
    required Task task,
  }) async {
    await _supermemory.addMemory(
      content: 'Child completed task "${task.title}" in ${task.category ?? "general"} category',
      metadata: {
        'user_id': userId,
        'child_id': childId,
        'type': 'task_completion',
        'task_category': task.category,
        'priority': task.priority.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track user preferences (e.g., preferred class times, locations)
  Future<void> trackPreference({
    required String userId,
    required String preferenceType,
    required String preferenceValue,
  }) async {
    await _supermemory.addMemory(
      content: 'User prefers $preferenceValue for $preferenceType',
      metadata: {
        'user_id': userId,
        'type': 'preference',
        'preference_type': preferenceType,
        'preference_value': preferenceValue,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== AI RECOMMENDATIONS ====================

  /// Get personalized class recommendations
  Future<String?> getClassRecommendations(String userId) async {
    try {
      final result = await _supermemory.search(
        'What classes would you recommend for user $userId based on their browsing history and enrollments?',
      );
      
      if (result.results.isNotEmpty) {
        return result.results.first.content;
      }
      return null;
    } catch (e) {
      print('Error getting recommendations: $e');
      return null;
    }
  }

  /// Get insights about child's progress
  Future<String?> getChildProgressInsights({
    required String userId,
    required String childId,
  }) async {
    try {
      return await _supermemory.getInsights(
        'Based on the task completion history, what insights can you provide about child $childId for user $userId? What areas are they excelling in and where might they need support?',
      );
    } catch (e) {
      print('Error getting insights: $e');
      return null;
    }
  }

  /// Get coach recommendations based on user preferences
  Future<String?> getCoachRecommendations({
    required String userId,
    required String category,
    String? location,
  }) async {
    try {
      final locationQuery = location != null ? ' in $location area' : '';
      return await _supermemory.getInsights(
        'Based on user $userId preferences and history, recommend coaches for $category$locationQuery',
      );
    } catch (e) {
      print('Error getting coach recommendations: $e');
      return null;
    }
  }

  /// Get personalized onboarding tips
  Future<String?> getOnboardingTips(String userId, UserType userType) async {
    try {
      final roleDescription = userType == UserType.parent
          ? 'parent managing children and classes'
          : userType == UserType.coach
              ? 'coach offering classes'
              : 'child completing tasks';
      
      return await _supermemory.getInsights(
        'Provide helpful onboarding tips for a new $roleDescription (user $userId)',
      );
    } catch (e) {
      print('Error getting onboarding tips: $e');
      return null;
    }
  }

  // ==================== ANALYTICS ====================

  /// Get usage insights for parent
  Future<String?> getUsageInsights(String userId) async {
    try {
      return await _supermemory.getInsights(
        'Summarize the activity and usage patterns for user $userId. What are their main activities and interests?',
      );
    } catch (e) {
      print('Error getting usage insights: $e');
      return null;
    }
  }

  /// Search for specific information
  Future<List<SupermemoryItem>> searchUserHistory({
    required String userId,
    required String query,
  }) async {
    try {
      final result = await _supermemory.search(
        'For user $userId: $query',
      );
      return result.results;
    } catch (e) {
      print('Error searching history: $e');
      return [];
    }
  }
}

