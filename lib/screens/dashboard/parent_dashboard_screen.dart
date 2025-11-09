import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/classes_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../models/student_model.dart';
import '../../models/task_model.dart';
import '../../models/class_model.dart';
import '../../models/payment_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/dev_utils.dart';
import '../../screens/children/add_edit_child_screen.dart';
import '../../screens/children/quick_add_child_dialog.dart';
import '../../screens/tasks/create_task_wizard.dart';
import '../../screens/tasks/quick_create_task_dialog.dart';
import '../../screens/classes/browse_classes_modern.dart';
import '../../widgets/bulk_task_creation_dialog.dart';
import '../../widgets/quick_booking_dialog.dart';
import '../../widgets/edit_task_dialog.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // Tasks are now managed by TasksProvider

  final List<Class> _upcomingClasses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    
    // Load children, tasks, and classes from Firebase when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
      final parentId = authProvider.currentUser?.id;
      
      if (parentId == null) {
        print('❌ No parent ID found, cannot load data');
        return;
      }
      
      print('🔄 Loading all data for parent: $parentId');
      
      // Clear existing data to force fresh load
      childrenProvider.clearAllChildren();
      tasksProvider.clearAllTasks();
      classesProvider.clearAllClasses();
      
      // Load children
      await childrenProvider.loadChildren(parentId);
      print('✅ Loaded ${childrenProvider.children.length} children');
      
      // Load tasks
      await tasksProvider.loadTasksForParent(parentId);
      print('✅ Loaded ${tasksProvider.tasks.length} tasks');
      
      // Load all classes (for browse/enroll)
      await classesProvider.loadClasses();
      print('✅ Loaded ${classesProvider.classes.length} classes');
      
      // Force UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      print('❌ Error loading data: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppTheme.errorColor,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadAllData(),
            ),
          ),
        );
      }
    }
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
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final parentName = authProvider.currentUser?.name ?? 'Parent';
            final firstName = parentName.split(' ').first;
            return Text('Welcome, $firstName');
          },
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Home Dashboard',
            onPressed: () {
              setState(() {
                _tabController.index = 0; // Always go to Overview tab
              });
            },
          ),
        ),
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              _loadAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Refreshing...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Calendar',
            onPressed: () => context.go('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.feedback_outlined),
            tooltip: 'Feedback',
            onPressed: () => context.go('/feedback'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/notification-settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/');
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
      floatingActionButton: _buildSmartFAB(),
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
                  'Waiting Approval',
                  tasks.where((t) => t.status == TaskStatus.completed).length.toString(),
                  Icons.pending_actions,
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
          
          // Tasks for Today Section (Prominent!)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.today, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Tasks for Today',
                    style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tabController.index = 2; // Go to Tasks tab
                  });
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Show today's tasks grouped by child
          ...() {
            final today = DateTime.now();
            final todaysTasks = tasks.where((task) {
              if (task.dueDate == null) return false;
              return task.dueDate!.year == today.year &&
                     task.dueDate!.month == today.month &&
                     task.dueDate!.day == today.day;
            }).toList();
            
            if (todaysTasks.isEmpty) {
              return [Card(
                color: AppTheme.neutral100,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 32),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No tasks due today!',
                              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Enjoy your day or create new tasks for tomorrow',
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )];
            }
            
            // Group today's tasks by child
            final tasksByChild = <String, List<Task>>{};
            for (var task in todaysTasks) {
              tasksByChild.putIfAbsent(task.childId, () => []).add(task);
            }
            
            return tasksByChild.entries.map((entry) {
              final child = children.firstWhere(
                (c) => c.userId == entry.key,
                orElse: () => Student(
                  id: entry.key,
                  userId: entry.key,
                  parentId: currentParentId,
                  name: 'Unknown',
                  email: '',
                  dateOfBirth: DateTime.now(),
                  enrolledAt: DateTime.now(),
                ),
              );
              final childTasks = entry.value;
              
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(child.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    '${child.name} (${childTasks.length} ${childTasks.length == 1 ? "task" : "tasks"})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: childTasks.map((task) => ListTile(
                    dense: true,
                    leading: Icon(
                      task.status == TaskStatus.completed ? Icons.check_circle :
                      task.status == TaskStatus.approved ? Icons.verified :
                      Icons.pending,
                      color: task.status == TaskStatus.completed ? AppTheme.warningColor :
                             task.status == TaskStatus.approved ? AppTheme.successColor :
                             AppTheme.primaryColor,
                      size: 20,
                    ),
                    title: Text(task.title),
                    subtitle: Text('${task.status.name} • ${task.rewardAmount.toInt()} points'),
                    trailing: Text('${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}'),
                  )).toList(),
                ),
              );
            }).toList();
          }(),
          
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
          
          // Pending Approval Section
          if (tasks.where((t) => t.status == TaskStatus.completed).isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waiting for Approval',
                  style: AppTheme.headline6,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tabController.index = 2; // Go to Tasks tab
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...tasks.where((t) => t.status == TaskStatus.completed).take(3).map((task) {
              final child = children.firstWhere(
                (c) => c.userId == task.childId,
                orElse: () => Student(
                  id: task.childId,
                  userId: task.childId,
                  parentId: currentParentId,
                  name: 'Unknown',
                  email: '',
                  dateOfBirth: DateTime.now(),
                  enrolledAt: DateTime.now(),
                ),
              );
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                color: AppTheme.warningColor.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.warningColor,
                    child: const Icon(Icons.pending_actions, color: Colors.white, size: 20),
                  ),
                  title: Text(task.title),
                  subtitle: Text('${child.name} • Completed ${_formatTimeAgo(task.completedAt!)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: AppTheme.successColor),
                        onPressed: () {
                          tasksProvider.approveTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Task approved!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: AppTheme.errorColor),
                        onPressed: () {
                          tasksProvider.rejectTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task rejected'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingXL),
          ],
          
          // Recent Activity with Calendar Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AppTheme.headline6,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_view_day),
                    onPressed: () {
                      context.push('/calendar');
                    },
                    tooltip: 'Calendar View',
                  ),
                  IconButton(
                    icon: const Icon(Icons.analytics),
                    onPressed: () {
                      context.push('/analytics');
                    },
                    tooltip: 'Analytics',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...tasks.take(3).map((task) => _buildActivityCard(task, children)),
        ],
      ),
        );
      },
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
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
                  trailing: PopupMenuButton<String>(
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
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Child', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditChildScreen(child: childItem),
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Child?'),
                            content: Text('Are you sure you want to remove ${childItem.name} from your family? This will delete all their tasks and progress.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await childrenProvider.deleteChild(childItem.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${childItem.name} has been removed'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting child: $e'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          }
                        }
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.status == TaskStatus.completed)
                          ElevatedButton.icon(
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
                        else
                          Chip(
                            label: Text(
                              task.status.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getTaskStatusColor(task.status).withOpacity(0.2),
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => EditTaskDialog(task: task),
                              );
                            } else if (value == 'clone') {
                              await _cloneTask(task);
                            } else if (value == 'delete') {
                              await _deleteTask(task);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit Task'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'clone',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 20),
                                  SizedBox(width: 12),
                                  Text('Clone Task'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Delete Task', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
    // Use the same marketplace view for consistency!
    return const BrowseClassesModern();
  }

  Widget _buildDetailedClassCard(Class classItem) {
    final spotsLeft = classItem.maxStudents - classItem.enrolledStudentIds.length;
    final isFull = spotsLeft <= 0;
    
    return FutureBuilder<String>(
      future: _getCoachName(classItem.coachId),
      builder: (context, snapshot) {
        final coachName = snapshot.data ?? 'Coach';
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(classItem.category),
                      _getCategoryColor(classItem.category).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Category & Location Badges
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              classItem.category ?? 'Class',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: classItem.locationType == LocationType.online
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  classItem.locationType == LocationType.online
                                      ? Icons.computer_rounded
                                      : Icons.location_on_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  classItem.locationType == LocationType.online ? 'Online' : 'In-Person',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Enrollment Count
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFull ? Icons.people : Icons.people_outline_rounded,
                              size: 16,
                              color: isFull ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$spotsLeft/${classItem.maxStudents} open',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isFull ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        classItem.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Coach
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              coachName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Date & Time
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateFormat('MMM d, y').format(classItem.startTime),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('h:mm a').format(classItem.startTime)} - ${DateFormat('h:mm a').format(classItem.endTime)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      if (classItem.location != null && classItem.locationType == LocationType.inPerson) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF8B5CF6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                classItem.location!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Price & Action
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_money_rounded, size: 14, color: Color(0xFF10B981)),
                                Text(
                                  classItem.price.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          
                          ElevatedButton(
                            onPressed: () async {
                              await _showQuickBooking(classItem, coachName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B9D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_rounded, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Book',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Future<String> _getCoachName(String coachId) async {
    try {
      final user = await FirestoreService().getUser(coachId);
      return user?.name ?? 'Coach';
    } catch (e) {
      return 'Coach';
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'sports':
        return const Color(0xFF10B981);
      case 'music':
        return const Color(0xFF8B5CF6);
      case 'arts':
        return const Color(0xFFFF6B9D);
      case 'stem':
        return const Color(0xFF3B82F6);
      case 'academic':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  Future<void> _showQuickBooking(Class classItem, String coachName) async {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final parentId = authProvider.currentUser?.id ?? '';
    
    if (childrenProvider.children.isEmpty) {
      await childrenProvider.loadChildren(parentId);
    }

    if (mounted) {
      final booked = await showDialog<bool>(
        context: context,
        builder: (context) => QuickBookingDialog(
          classItem: classItem,
          coachName: coachName,
        ),
      );

      if (booked == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Booking successful! Check your email for details.'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
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

  Widget _buildActivityCard(Task task, List<Student> children) {
    final child = children.firstWhere(
      (c) => c.userId == task.childId,
      orElse: () => Student(
        id: task.childId,
        userId: task.childId,
        parentId: task.parentId,
        name: 'Unknown',
        email: '',
        dateOfBirth: DateTime.now(),
        enrolledAt: DateTime.now(),
      ),
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: Color(int.parse(child.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50')),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: _getTaskStatusColor(task.status),
              child: Icon(
                _getTaskStatusIcon(task.status),
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
        title: Text(task.title),
        subtitle: Text('${child.name} • ${task.status.name} • ${task.rewardAmount.toInt()} points'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit Task'),
                ],
              ),
            ),
            if (task.status == TaskStatus.pending || task.status == TaskStatus.inProgress)
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text('Mark Complete'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => EditTaskDialog(task: task),
              );
              // Task will auto-refresh via provider
            } else if (value == 'complete') {
              // Update via Firestore directly
              await FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(task.id)
                  .update({'status': 'completed', 'completedAt': FieldValue.serverTimestamp()});
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(task.id)
                    .delete();
              }
            }
          },
        ),
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

  Future<void> _cloneTask(Task task) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      
      // Create new task based on existing one
      final newTask = Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: '${task.title} (Copy)',
        description: task.description,
        childId: task.childId,
        parentId: authProvider.currentUser?.id ?? '',
        status: TaskStatus.pending,
        dueDate: DateTime.now().add(const Duration(days: 1)), // Tomorrow
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        rewardAmount: task.rewardAmount,
        priority: task.priority,
        category: task.category,
        isRecurring: task.isRecurring,
        recurringPattern: task.recurringPattern,
        metadata: task.metadata,
        tags: task.tags,
      );
      
      await tasksProvider.addTask(newTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Task cloned! Edit the copy as needed.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cloning task: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Task deleted'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
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

  // Smart FAB that changes based on tab
  Widget? _buildSmartFAB() {
    switch (_tabController.index) {
      case 1: // Children tab
        return FloatingActionButton.extended(
          onPressed: () => _showQuickAddChildDialog(),
          backgroundColor: AppTheme.successColor,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Child'),
        );
      case 2: // Tasks tab
        return FloatingActionButton.extended(
          onPressed: () => _showQuickTaskDialog(),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add),
          label: const Text('Quick Task'),
        );
      default:
        return null;
    }
  }

  // Show quick add child dialog
  Future<void> _showQuickAddChildDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const QuickAddChildDialog(),
    );
    
    if (result == true && mounted) {
      // Refresh children list
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      await childrenProvider.loadChildren(authProvider.currentUser?.id ?? '');
    }
  }

  // Show quick task creation dialog
  Future<void> _showQuickTaskDialog() async {
    // Show options: Quick Task or Bulk Create
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_task, color: AppTheme.primaryColor),
              title: const Text('Quick Task'),
              subtitle: const Text('Create a single task for one child'),
              onTap: () => Navigator.pop(context, 'quick'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: AppTheme.accentColor),
              title: const Text('Bulk Create'),
              subtitle: const Text('Assign the same task to multiple children'),
              onTap: () => Navigator.pop(context, 'bulk'),
            ),
          ],
        ),
      ),
    );

    if (choice == 'quick') {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const QuickCreateTaskDialog(),
      );
      
      if (result == true && mounted) {
        // Refresh tasks list
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
        await tasksProvider.loadTasksForParent(authProvider.currentUser?.id ?? '');
      }
    } else if (choice == 'bulk') {
      await _showBulkCreateDialog();
    }
  }

  // Show bulk task creation dialog
  Future<void> _showBulkCreateDialog() async {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    final children = childrenProvider.children;

    if (children.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please add children first before creating tasks'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final result = await showDialog<int>(
      context: context,
      builder: (context) => BulkTaskCreationDialog(children: children),
    );
    
    if (result != null && result > 0 && mounted) {
      // Refresh tasks list
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      await tasksProvider.loadTasksForParent(authProvider.currentUser?.id ?? '');
    }
  }
}
