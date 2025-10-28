import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../models/student_model.dart';
import '../../models/task_model.dart';
import '../../models/class_model.dart';
import '../../models/payment_model.dart';
import '../../utils/app_theme.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Tasks are now managed by TasksProvider

  final List<Class> _upcomingClasses = [
    Class(
      id: '1',
      title: 'Soccer Training',
      description: 'Weekly soccer practice',
      coachId: 'coach1',
      type: ClassType.weekly,
      locationType: LocationType.inPerson,
      location: 'Community Field',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      durationMinutes: 60,
      price: 25.0,
      currency: Currency.usd,
      maxStudents: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.child_care), text: 'Children'),
            Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            Tab(icon: Icon(Icons.school), text: 'Classes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.stars),
            tooltip: 'Points Settings',
            onPressed: () => context.push('/points-settings'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.feedback),
            onPressed: () => context.go('/feedback'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/notification-settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildChildrenTab(),
          _buildTasksTab(),
          _buildClassesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create-task'),
        icon: const Icon(Icons.add),
        label: const Text('Create Task'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<ChildrenProvider, TasksProvider>(
      builder: (context, childrenProvider, tasksProvider, child) {
        final children = childrenProvider.children;
        final tasks = tasksProvider.tasks;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Children',
                      children.length.toString(),
                      Icons.child_care,
                      AppTheme.primaryColor,
                    ),
                  ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Active Tasks',
                  tasks.where((t) => t.status == TaskStatus.pending).length.toString(),
                  Icons.assignment,
                  AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed Tasks',
                  tasks.where((t) => t.status == TaskStatus.completed).length.toString(),
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Upcoming Classes',
                  _upcomingClasses.length.toString(),
                  Icons.school,
                  AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Financial Ledger Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/financial-ledger?userType=parent'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Financial Ledger'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: AppTheme.headline6,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...tasks.take(3).map((task) => _buildActivityCard(task)),
        ],
      ),
        );
      },
    );
  }

  Widget _buildChildrenTab() {
    return Consumer<ChildrenProvider>(
      builder: (context, childrenProvider, child) {
        final children = childrenProvider.children;
        return Column(
          children: [
            // Add Child Button
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/add-child'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Child'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  ),
                ),
              ),
            ),
            // Children List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final childItem = children[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(childItem.colorCode!.replaceFirst('#', '0xFF'))),
                    child: Text(
                      childItem.name[0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(childItem.name),
                  subtitle: Text(childItem.email),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'tasks',
                        child: Row(
                          children: [
                            Icon(Icons.assignment, size: 20),
                            SizedBox(width: 8),
                            Text('View Tasks'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'classes',
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 20),
                            SizedBox(width: 8),
                            Text('View Classes'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/edit-child');
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
        );
      },
    );
  }

  Widget _buildTasksTab() {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        final tasks = tasksProvider.tasks;
        
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: AppTheme.neutral400),
                const SizedBox(height: AppTheme.spacingL),
                Text('No tasks yet', style: AppTheme.headline6),
                const SizedBox(height: AppTheme.spacingS),
                Text('Create your first task!', style: AppTheme.bodyMedium),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTaskStatusColor(task.status),
              child: Icon(
                _getTaskStatusIcon(task.status),
                color: Colors.white,
              ),
            ),
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars, size: 16, color: AppTheme.warningColor),
                    Text('${task.rewardAmount.toInt()} points'),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                    Text(_formatDate(task.dueDate)),
                  ],
                ),
              ],
            ),
            trailing: task.status == TaskStatus.completed
                ? IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      tasksProvider.approveTask(task.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task approved!')),
                      );
                    },
                  )
                : null,
          ),
        );
      },
    );
      },
    );
  }

  Widget _buildClassesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _upcomingClasses.length,
      itemBuilder: (context, index) {
        final classItem = _upcomingClasses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.school, color: Colors.white),
            ),
            title: Text(classItem.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(classItem.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppTheme.neutral600),
                    Text(classItem.location ?? 'Online'),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                    Text(_formatTime(classItem.startTime)),
                  ],
                ),
              ],
            ),
            trailing: Text('\$${classItem.price.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: AppTheme.headline4.copyWith(color: color),
            ),
            Text(
              title,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTaskStatusColor(task.status),
          child: Icon(
            _getTaskStatusIcon(task.status),
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(task.title),
        subtitle: Text('${task.status.name} - \$${task.rewardAmount.toStringAsFixed(2)}'),
        trailing: Text(_formatDate(task.updatedAt)),
      ),
    );
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppTheme.warningColor;
      case TaskStatus.inProgress:
        return AppTheme.infoColor;
      case TaskStatus.completed:
        return AppTheme.successColor;
      case TaskStatus.approved:
        return AppTheme.successColor;
      case TaskStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  IconData _getTaskStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending;
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.completed:
        return Icons.check;
      case TaskStatus.approved:
        return Icons.check_circle;
      case TaskStatus.rejected:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Task'),
        content: const Text('Task creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Create task
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
