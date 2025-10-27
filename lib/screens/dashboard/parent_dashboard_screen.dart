import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
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
  
  // Mock data - in real app, this would come from providers/services
  final List<Student> _children = [
    Student(
      id: '1',
      userId: 'child1',
      parentId: 'parent1',
      name: 'Emma Johnson',
      email: 'emma@example.com',
      dateOfBirth: DateTime(2015, 3, 15),
      enrolledAt: DateTime.now().subtract(const Duration(days: 30)),
      colorCode: '#FF6B6B',
    ),
    Student(
      id: '2',
      userId: 'child2',
      parentId: 'parent1',
      name: 'Liam Johnson',
      email: 'liam@example.com',
      dateOfBirth: DateTime(2013, 7, 22),
      enrolledAt: DateTime.now().subtract(const Duration(days: 45)),
      colorCode: '#4ECDC4',
    ),
  ];

  final List<Task> _recentTasks = [
    Task(
      id: '1',
      title: 'Complete Math Homework',
      description: 'Finish pages 45-50 in math workbook',
      parentId: 'parent1',
      childId: 'child1',
      status: TaskStatus.completed,
      rewardAmount: 5.0,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Practice Piano',
      description: 'Practice for 30 minutes daily',
      parentId: 'parent1',
      childId: 'child2',
      status: TaskStatus.pending,
      rewardAmount: 3.0,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

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
                  _children.length.toString(),
                  Icons.child_care,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Active Tasks',
                  _recentTasks.where((t) => t.status == TaskStatus.pending).length.toString(),
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
                  _recentTasks.where((t) => t.status == TaskStatus.completed).length.toString(),
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
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: AppTheme.headline6,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ..._recentTasks.take(3).map((task) => _buildActivityCard(task)),
        ],
      ),
    );
  }

  Widget _buildChildrenTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _children.length,
      itemBuilder: (context, index) {
        final child = _children[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(int.parse(child.colorCode!.replaceFirst('#', '0xFF'))),
              child: Text(
                child.name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(child.name),
            subtitle: Text(child.email),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Profile'),
                ),
                const PopupMenuItem(
                  value: 'tasks',
                  child: Text('View Tasks'),
                ),
                const PopupMenuItem(
                  value: 'classes',
                  child: Text('View Classes'),
                ),
              ],
              onSelected: (value) {
                // TODO: Handle menu selection
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _recentTasks.length,
      itemBuilder: (context, index) {
        final task = _recentTasks[index];
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
                    Icon(Icons.attach_money, size: 16, color: AppTheme.successColor),
                    Text('\$${task.rewardAmount.toStringAsFixed(2)}'),
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
                      // TODO: Approve task
                    },
                  )
                : null,
          ),
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
