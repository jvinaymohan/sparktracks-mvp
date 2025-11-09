import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/classes_provider.dart';
import '../../utils/app_theme.dart';
import 'admin_users_tab.dart';
import 'admin_notifications_tab.dart';
import 'admin_analytics_tab.dart';
import 'admin_feedback_tab.dart';
import 'admin_roadmap_tab.dart';
import 'admin_release_notes_tab.dart';
import 'admin_settings_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminOverviewTab(),
    const AdminUsersTab(),
    const AdminNotificationsTab(),
    const AdminAnalyticsTab(),
    const AdminFeedbackTab(),
    const AdminRoadmapTab(),
    const AdminReleaseNotesTab(),
    const AdminSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final admin = adminProvider.currentAdmin;

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/admin/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              setState(() {});
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(admin.name),
                  subtitle: Text(admin.email),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
                onTap: () {
                  adminProvider.logoutAdmin();
                  context.go('/admin/login');
                },
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.feedback),
                label: Text('Feedback'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Roadmap'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Releases'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          // Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Overview Tab
class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  
  Future<Map<String, int>> _getRealTimeStats() async {
    try {
      // Get real counts from Firestore
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final childrenSnapshot = await FirebaseFirestore.instance.collection('children').get();
      final tasksSnapshot = await FirebaseFirestore.instance.collection('tasks').get();
      final classesSnapshot = await FirebaseFirestore.instance.collection('classes').get();
      
      final users = usersSnapshot.docs;
      final parents = users.where((doc) => doc.data()['type'] == 'parent').length;
      final coaches = users.where((doc) => doc.data()['type'] == 'coach').length;
      final children = childrenSnapshot.docs.length;
      
      // Calculate "new this week" (users created in last 7 days)
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final newThisWeek = users.where((doc) {
        final createdAt = doc.data()['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(oneWeekAgo);
        }
        return false;
      }).length;
      
      // Calculate "active today" (any activity today)
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final activeToday = users.where((doc) {
        final lastActive = doc.data()['lastActive'];
        if (lastActive is Timestamp) {
          return lastActive.toDate().isAfter(todayStart);
        }
        return false;
      }).length;
      
      return {
        'totalUsers': users.length,
        'parents': parents,
        'coaches': coaches,
        'children': children,
        'tasks': tasksSnapshot.docs.length,
        'classes': classesSnapshot.docs.length,
        'activeToday': activeToday,
        'newThisWeek': newThisWeek,
      };
    } catch (e) {
      print('Error fetching admin stats: $e');
      return {
        'totalUsers': 0,
        'parents': 0,
        'coaches': 0,
        'children': 0,
        'tasks': 0,
        'classes': 0,
        'activeToday': 0,
        'newThisWeek': 0,
      };
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getRealTimeStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? {};
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('System Overview', style: AppTheme.headline4),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {}),
                    tooltip: 'Refresh Stats',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Statistics cards
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Total Users',
                    stats['totalUsers']?.toString() ?? '0',
                    Icons.people,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Parents',
                    stats['parents']?.toString() ?? '0',
                    Icons.family_restroom,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    'Children',
                    stats['children']?.toString() ?? '0',
                    Icons.child_care,
                    AppTheme.warningColor,
                  ),
                  _buildStatCard(
                    'Coaches',
                    stats['coaches']?.toString() ?? '0',
                    Icons.school,
                    AppTheme.infoColor,
                  ),
                  _buildStatCard(
                    'Total Tasks',
                    stats['tasks']?.toString() ?? '0',
                    Icons.assignment,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Total Classes',
                    stats['classes']?.toString() ?? '0',
                    Icons.class_,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    'Active Today',
                    stats['activeToday']?.toString() ?? '0',
                    Icons.timeline,
                    AppTheme.warningColor,
                  ),
                  _buildStatCard(
                    'New This Week',
                    stats['newThisWeek']?.toString() ?? '0',
                    Icons.trending_up,
                    AppTheme.successColor,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // System status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Status', style: AppTheme.headline6),
                      const SizedBox(height: 16),
                      _buildStatusRow('Database', 'Connected', AppTheme.successColor),
                      _buildStatusRow('Firebase Auth', 'Active', AppTheme.successColor),
                      _buildStatusRow('Storage', 'Active', AppTheme.successColor),
                      _buildStatusRow('Notifications', 'Active', AppTheme.successColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.headline4.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String service, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service, style: AppTheme.bodyLarge),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(status, style: TextStyle(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

