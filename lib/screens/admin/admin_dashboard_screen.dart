import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/classes_provider.dart';
import '../../utils/app_theme.dart';

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
    const AdminBetaSignupsTab(),
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
            itemBuilder: (context) => [
              PopupMenuItem(
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
                icon: Icon(Icons.email),
                label: Text('Beta Signups'),
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
class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<AdminProvider, UserProvider, TasksProvider, ClassesProvider>(
      builder: (context, adminProvider, userProvider, tasksProvider, classesProvider, _) {
        final stats = adminProvider.getUserStatistics();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Overview', style: AppTheme.headline4),
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
                    stats['total']?.toString() ?? '0',
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
                    tasksProvider.tasks.length.toString(),
                    Icons.assignment,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Total Classes',
                    classesProvider.classes.length.toString(),
                    Icons.class_,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    'Beta Pending',
                    stats['beta_pending']?.toString() ?? '0',
                    Icons.pending,
                    AppTheme.warningColor,
                  ),
                  _buildStatCard(
                    'Beta Approved',
                    stats['beta_approved']?.toString() ?? '0',
                    Icons.check_circle,
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

// Users Tab - Placeholder
class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('User Management - Coming in next implementation'),
    );
  }
}

// Beta Signups Tab - Placeholder
class AdminBetaSignupsTab extends StatelessWidget {
  const AdminBetaSignupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Beta Signups Management - Coming in next implementation'),
    );
  }
}

// Settings Tab - Placeholder
class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('System Settings - Coming in next implementation'),
    );
  }
}

