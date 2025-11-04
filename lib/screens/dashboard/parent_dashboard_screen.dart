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
import '../../utils/dev_utils.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Tasks are now managed by TasksProvider

  final List<Class> _upcomingClasses = [];

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
            icon: const Icon(Icons.bug_report),
            tooltip: 'Dev Tools (Clear Data)',
            onPressed: () => DevUtils.showDebugMenu(context),
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
    return Consumer3<ChildrenProvider, TasksProvider, AuthProvider>(
      builder: (context, childrenProvider, tasksProvider, authProvider, child) {
        final currentParentId = authProvider.currentUser?.id ?? '';
        
        // Filter to only show this parent's data
        final children = childrenProvider.children.where((child) => child.parentId == currentParentId).toList();
        final tasks = tasksProvider.tasks.where((task) => task.parentId == currentParentId).toList();
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
    return Consumer2<ChildrenProvider, AuthProvider>(
      builder: (context, childrenProvider, authProvider, child) {
        final currentParentId = authProvider.currentUser?.id ?? '';
        
        // Filter children to only show this parent's children
        final children = childrenProvider.children.where((child) => child.parentId == currentParentId).toList();
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
    return Consumer3<TasksProvider, ChildrenProvider, AuthProvider>(
      builder: (context, tasksProvider, childrenProvider, authProvider, child) {
        final currentParentId = authProvider.currentUser?.id ?? '';
        
        // Filter tasks to only show this parent's tasks
        final tasks = tasksProvider.tasks.where((task) => task.parentId == currentParentId).toList();
        final children = childrenProvider.children;
        
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
        
        // Group tasks by child
        final Map<String, List<Task>> tasksByChild = {};
        for (final task in tasks) {
          tasksByChild.putIfAbsent(task.childId, () => []).add(task);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          itemCount: tasksByChild.length,
          itemBuilder: (context, groupIndex) {
            final childId = tasksByChild.keys.elementAt(groupIndex);
            final childTasks = tasksByChild[childId]!;
            
            // Find the child info - match by userId (Firebase Auth ID)
            final childInfo = children.firstWhere(
              (c) => c.userId == childId,
              orElse: () => Student(
                id: childId,
                userId: childId,
                parentId: currentParentId,
                name: 'Unknown Child',
                email: '',
                dateOfBirth: DateTime.now(),
                enrolledAt: DateTime.now(),
              ),
            );
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child header
                Container(
                  margin: EdgeInsets.only(bottom: AppTheme.spacingM, top: groupIndex > 0 ? AppTheme.spacingL : 0),
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Color(int.parse(childInfo.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          childInfo.name[0].toUpperCase(),
                          style: TextStyle(
                            color: Color(int.parse(childInfo.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              childInfo.name,
                              style: AppTheme.headline6.copyWith(color: Colors.white),
                            ),
                            Text(
                              '${childTasks.length} ${childTasks.length == 1 ? 'task' : 'tasks'}',
                              style: AppTheme.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),
                      // Task stats for this child
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${childTasks.where((t) => t.status == TaskStatus.approved).fold<double>(0, (sum, t) => sum + t.rewardAmount).toInt()} pts',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tasks for this child
                ...childTasks.map((task) => Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTaskStatusColor(task.status),
                      child: Icon(
                        _getTaskStatusIcon(task.status),
                        color: Colors.white,
                        size: 20,
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
                            const SizedBox(width: 4),
                            Text('${task.rewardAmount.toInt()} points'),
                            const SizedBox(width: 16),
                            const Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                            const SizedBox(width: 4),
                            Text(_formatDate(task.dueDate)),
                          ],
                        ),
                      ],
                    ),
                    trailing: task.status == TaskStatus.completed
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approve'),
                            onPressed: () {
                              tasksProvider.approveTask(task.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task approved for ${childInfo.name}!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                            ),
                          )
                        : Chip(
                            label: Text(
                              task.status.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getTaskStatusColor(task.status).withOpacity(0.2),
                          ),
                  ),
                )),
              ],
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
        subtitle: Text('${task.status.name} - ${task.rewardAmount.toInt()} points'),
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
