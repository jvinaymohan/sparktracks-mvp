import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';

class AdminAnalyticsTab extends StatefulWidget {
  const AdminAnalyticsTab({super.key});

  @override
  State<AdminAnalyticsTab> createState() => _AdminAnalyticsTabState();
}

class _AdminAnalyticsTabState extends State<AdminAnalyticsTab> {
  String _timeRange = '7days'; // 7days, 30days, 90days, all

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getAnalyticsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Platform Analytics', style: AppTheme.headline4),
                  Row(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: '7days', label: Text('7 Days')),
                          ButtonSegment(value: '30days', label: Text('30 Days')),
                          ButtonSegment(value: '90days', label: Text('90 Days')),
                          ButtonSegment(value: 'all', label: Text('All Time')),
                        ],
                        selected: <String>{_timeRange},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _timeRange = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => setState(() {}),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Growth Metrics
              Text('Growth Metrics', style: AppTheme.headline6),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard(
                    'New Users',
                    data['newUsers']?.toString() ?? '0',
                    Icons.person_add,
                    AppTheme.successColor,
                    '+${data['userGrowth'] ?? 0}%',
                  ),
                  _buildMetricCard(
                    'New Classes',
                    data['newClasses']?.toString() ?? '0',
                    Icons.class_,
                    AppTheme.primaryColor,
                    '+${data['classGrowth'] ?? 0}%',
                  ),
                  _buildMetricCard(
                    'Tasks Created',
                    data['newTasks']?.toString() ?? '0',
                    Icons.assignment,
                    AppTheme.warningColor,
                    '+${data['taskGrowth'] ?? 0}%',
                  ),
                  _buildMetricCard(
                    'Enrollments',
                    data['enrollments']?.toString() ?? '0',
                    Icons.people,
                    AppTheme.infoColor,
                    '+${data['enrollmentGrowth'] ?? 0}%',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // User Distribution
              Text('User Distribution', style: AppTheme.headline6),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDistributionCard(
                      'Parents',
                      data['parents'] ?? 0,
                      data['totalUsers'] ?? 1,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDistributionCard(
                      'Children',
                      data['children'] ?? 0,
                      data['totalUsers'] ?? 1,
                      AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDistributionCard(
                      'Coaches',
                      data['coaches'] ?? 0,
                      data['totalUsers'] ?? 1,
                      AppTheme.successColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Engagement Metrics
              Text('Engagement Metrics', style: AppTheme.headline6),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  _buildEngagementCard(
                    'Avg Tasks/Child',
                    data['avgTasksPerChild']?.toStringAsFixed(1) ?? '0.0',
                    Icons.assignment_turned_in,
                    AppTheme.primaryColor,
                  ),
                  _buildEngagementCard(
                    'Task Completion Rate',
                    '${data['taskCompletionRate'] ?? 0}%',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                  _buildEngagementCard(
                    'Active Coaches',
                    data['activeCoaches']?.toString() ?? '0',
                    Icons.school,
                    AppTheme.infoColor,
                  ),
                  _buildEngagementCard(
                    'Classes/Coach',
                    data['avgClassesPerCoach']?.toStringAsFixed(1) ?? '0.0',
                    Icons.class_,
                    AppTheme.warningColor,
                  ),
                  _buildEngagementCard(
                    'Enrollment Rate',
                    '${data['enrollmentRate'] ?? 0}%',
                    Icons.people,
                    AppTheme.primaryColor,
                  ),
                  _buildEngagementCard(
                    'Avg Class Size',
                    data['avgClassSize']?.toStringAsFixed(1) ?? '0.0',
                    Icons.groups,
                    AppTheme.successColor,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Popular Categories
              Text('Popular Class Categories', style: AppTheme.headline6),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: _buildCategoryList(data['categories'] as Map<String, int>? ?? {}),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getAnalyticsData() async {
    try {
      DateTime startDate;
      switch (_timeRange) {
        case '7days':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '30days':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '90days':
          startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        default:
          startDate = DateTime(2020); // All time
      }

      // Get users
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = usersSnapshot.docs;
      final parents = users.where((doc) => doc.data()['type'] == 'parent').length;
      final coaches = users.where((doc) => doc.data()['type'] == 'coach').length;

      final newUsers = users.where((doc) {
        final createdAt = doc.data()['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(startDate);
        }
        return false;
      }).length;

      // Get children
      final childrenSnapshot = await FirebaseFirestore.instance.collection('children').get();
      final children = childrenSnapshot.docs.length;

      // Get classes
      final classesSnapshot = await FirebaseFirestore.instance.collection('classes').get();
      final classes = classesSnapshot.docs;
      final newClasses = classes.where((doc) {
        final createdAt = doc.data()['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(startDate);
        }
        return false;
      }).length;

      // Get tasks
      final tasksSnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      final tasks = tasksSnapshot.docs;
      final newTasks = tasks.where((doc) {
        final createdAt = doc.data()['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(startDate);
        }
        return false;
      }).length;

      final completedTasks = tasks.where((doc) => doc.data()['status'] == 'completed').length;
      final taskCompletionRate = tasks.isNotEmpty ? (completedTasks / tasks.length * 100).round() : 0;

      // Get enrollments
      final enrollmentsSnapshot = await FirebaseFirestore.instance.collection('enrollments').get();
      final enrollments = enrollmentsSnapshot.docs;
      final newEnrollments = enrollments.where((doc) {
        final createdAt = doc.data()['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(startDate);
        }
        return false;
      }).length;

      // Calculate engagement metrics
      final avgTasksPerChild = children > 0 ? tasks.length / children : 0.0;
      final activeCoaches = coaches; // Simplified for now
      final avgClassesPerCoach = coaches > 0 ? classes.length / coaches : 0.0;
      final enrollmentRate = classes.isNotEmpty ? (enrollments.length / classes.length * 100).round() : 0;
      
      // Calculate average class size
      double totalEnrolled = 0;
      for (final classDoc in classes) {
        final enrolledIds = classDoc.data()['enrolledStudentIds'] as List? ?? [];
        totalEnrolled += enrolledIds.length;
      }
      final avgClassSize = classes.isNotEmpty ? totalEnrolled / classes.length : 0.0;

      // Category distribution
      final categories = <String, int>{};
      for (final classDoc in classes) {
        final category = classDoc.data()['category'] as String? ?? 'Other';
        categories[category] = (categories[category] ?? 0) + 1;
      }

      return {
        'totalUsers': users.length,
        'parents': parents,
        'children': children,
        'coaches': coaches,
        'newUsers': newUsers,
        'newClasses': newClasses,
        'newTasks': newTasks,
        'enrollments': enrollments.length,
        'newEnrollments': newEnrollments,
        'userGrowth': 0, // Would calculate from previous period
        'classGrowth': 0,
        'taskGrowth': 0,
        'enrollmentGrowth': 0,
        'avgTasksPerChild': avgTasksPerChild,
        'taskCompletionRate': taskCompletionRate,
        'activeCoaches': activeCoaches,
        'avgClassesPerCoach': avgClassesPerCoach,
        'enrollmentRate': enrollmentRate,
        'avgClassSize': avgClassSize,
        'categories': categories,
      };
    } catch (e) {
      print('Error fetching analytics: $e');
      return {};
    }
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, String change) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headline4.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            Text(label, style: AppTheme.bodySmall, textAlign: TextAlign.center),
            if (change != '+0%')
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionCard(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: AppTheme.headline3.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTheme.bodyLarge),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: color.withOpacity(0.1),
              color: color,
            ),
            const SizedBox(height: 8),
            Text('$percentage% of total', style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(label, style: AppTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryList(Map<String, int> categories) {
    if (categories.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No class data available yet')),
        ),
      ];
    }

    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalClasses = categories.values.fold<int>(0, (sum, count) => sum + count);

    return sortedCategories.map((entry) {
      final percentage = totalClasses > 0 ? (entry.value / totalClasses * 100).round() : 0;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(entry.key, style: AppTheme.bodyLarge),
            ),
            Expanded(
              flex: 3,
              child: LinearProgressIndicator(
                value: totalClasses > 0 ? entry.value / totalClasses : 0,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: Text(
                '${entry.value} ($percentage%)',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

