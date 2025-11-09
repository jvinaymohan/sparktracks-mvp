import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';

class AdminNotificationsTab extends StatefulWidget {
  const AdminNotificationsTab({super.key});

  @override
  State<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends State<AdminNotificationsTab> {
  String _filter = 'all'; // all, users, classes, tasks

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.neutral50,
          child: Row(
            children: [
              Text('System Notifications', style: AppTheme.headline5),
              const Spacer(),
              // Filter chips
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filter == 'all',
                    onSelected: (selected) => setState(() => _filter = 'all'),
                  ),
                  FilterChip(
                    label: const Text('New Users'),
                    selected: _filter == 'users',
                    onSelected: (selected) => setState(() => _filter = 'users'),
                  ),
                  FilterChip(
                    label: const Text('Classes'),
                    selected: _filter == 'classes',
                    onSelected: (selected) => setState(() => _filter = 'classes'),
                  ),
                  FilterChip(
                    label: const Text('Tasks'),
                    selected: _filter == 'tasks',
                    onSelected: (selected) => setState(() => _filter = 'tasks'),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        
        // Notifications stream
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getRecentActivity(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _getRecentActivity() async {
    final notifications = <Map<String, dynamic>>[];
    
    try {
      // Get new users from last 7 days
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        notifications.add({
          'type': 'user',
          'title': 'New ${data['type']} registered',
          'subtitle': data['name'] ?? 'Unknown',
          'timestamp': (data['createdAt'] as Timestamp).toDate(),
          'icon': Icons.person_add,
          'color': AppTheme.successColor,
        });
      }

      // Get new classes from last 7 days
      final classesSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      for (final doc in classesSnapshot.docs) {
        final data = doc.data();
        notifications.add({
          'type': 'class',
          'title': 'New class created',
          'subtitle': data['title'] ?? 'Untitled',
          'timestamp': (data['createdAt'] as Timestamp).toDate(),
          'icon': Icons.class_,
          'color': AppTheme.primaryColor,
        });
      }

      // Get new tasks from last 7 days
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      for (final doc in tasksSnapshot.docs) {
        final data = doc.data();
        notifications.add({
          'type': 'task',
          'title': 'New task created',
          'subtitle': data['title'] ?? 'Untitled',
          'timestamp': (data['createdAt'] as Timestamp).toDate(),
          'icon': Icons.assignment,
          'color': AppTheme.warningColor,
        });
      }

      // Sort all notifications by timestamp
      notifications.sort((a, b) => 
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      // Filter based on selection
      if (_filter != 'all') {
        return notifications.where((n) => 
          (_filter == 'users' && n['type'] == 'user') ||
          (_filter == 'classes' && n['type'] == 'class') ||
          (_filter == 'tasks' && n['type'] == 'task')
        ).toList();
      }

      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final timestamp = notification['timestamp'] as DateTime;
    final timeAgo = _getTimeAgo(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (notification['color'] as Color).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification['icon'] as IconData,
            color: notification['color'] as Color,
          ),
        ),
        title: Text(notification['title'] as String),
        subtitle: Text(notification['subtitle'] as String),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeAgo,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(timestamp),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppTheme.neutral400),
          const SizedBox(height: 16),
          Text('No recent notifications', style: AppTheme.headline6),
          const SizedBox(height: 8),
          Text(
            'Activity from the last 7 days will appear here',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

