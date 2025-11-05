import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../models/task_model.dart';
import '../../models/class_model.dart';
import '../../models/payment_model.dart';
import '../../utils/app_theme.dart';

class ChildDashboardScreen extends StatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Class> _myClasses = [];
  final List<String> _achievements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load tasks from Firebase when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      final childId = authProvider.currentUser?.id;
      
      if (childId != null) {
        print('🔄 Loading tasks for child: $childId');
        tasksProvider.loadTasksForChild(childId);
      }
    });
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
        title: const Text('My Activities'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            Tab(icon: Icon(Icons.school), text: 'Classes'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Achievements',
            onPressed: () => context.push('/achievements'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Calendar',
            onPressed: () => context.go('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.feedback),
            tooltip: 'Feedback',
            onPressed: () => context.go('/feedback'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/notification-settings'),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home Page',
            onPressed: () => context.go('/'),
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
          _buildTasksTab(),
          _buildClassesTab(),
          _buildAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final tasksProvider = Provider.of<TasksProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'Student';
    final currentUserId = authProvider.currentUser?.id ?? '';
    
    // Get tasks for this child using their Firebase user ID
    final myTasks = tasksProvider.tasks.where((task) => task.childId == currentUserId).toList();
    
    final totalEarnings = myTasks
        .where((task) => task.status == TaskStatus.approved)
        .fold<double>(0.0, (sum, task) => sum + task.rewardAmount);

    final pendingEarnings = myTasks
        .where((task) => task.status == TaskStatus.completed)
        .fold<double>(0.0, (sum, task) => sum + task.rewardAmount);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $userName! 👋',
                  style: AppTheme.headline4.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Keep up the great work! 🌟',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Points',
                  '${totalEarnings.toInt()} pts',
                  Icons.stars,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '${pendingEarnings.toInt()} pts',
                  Icons.pending,
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
                  'Tasks Done',
                  myTasks.where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.approved).length.toString(),
                  Icons.check_circle,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Classes',
                  _myClasses.length.toString(),
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
              onPressed: () => context.push('/financial-ledger?userType=child'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Financial Ledger'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              ),
            ),
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
                    _tabController.index = 1; // Go to Tasks tab
                  });
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Show today's tasks
          ...() {
            final today = DateTime.now();
            final todaysTasks = myTasks.where((task) {
              if (task.dueDate == null) return false;
              return task.dueDate!.year == today.year &&
                     task.dueDate!.month == today.month &&
                     task.dueDate!.day == today.day &&
                     task.status == TaskStatus.pending; // Only show pending tasks
            }).toList();
            
            if (todaysTasks.isEmpty) {
              return [Card(
                color: AppTheme.successColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, color: AppTheme.successColor, size: 32),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All done for today!',
                              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Great job! Check back tomorrow for new tasks',
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
            
            return todaysTasks.map((task) => _buildTaskCard(task)).toList();
          }(),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Recent Tasks
          Text(
            'Recent Tasks',
            style: AppTheme.headline6,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...myTasks.where((t) => t.status != TaskStatus.pending).take(3).map((task) => _buildTaskCard(task)),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final tasksProvider = Provider.of<TasksProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? '';
    
    // Get tasks for this child
    final myTasks = tasksProvider.tasks.where((task) => task.childId == currentUserId).toList();
    
    if (myTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppTheme.neutral400),
            const SizedBox(height: AppTheme.spacingL),
            Text('No tasks assigned yet', style: AppTheme.headline6),
            const SizedBox(height: AppTheme.spacingS),
            Text('Check back later for new tasks!', style: AppTheme.bodyMedium),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: myTasks.length,
      itemBuilder: (context, index) {
        final task = myTasks[index];
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
                    Text('${task.rewardAmount.toInt()} pts'),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                    Text(_formatDate(task.dueDate)),
                  ],
                ),
                if (task.completionNotes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Notes: ${task.completionNotes}',
                    style: AppTheme.bodySmall.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
            trailing: task.status == TaskStatus.pending || task.status == TaskStatus.inProgress
                ? ElevatedButton(
                    onPressed: () => _completeTask(task),
                    child: const Text('Complete'),
                  )
                : task.status == TaskStatus.completed
                    ? const Chip(
                        label: Text('Pending Approval'),
                        backgroundColor: AppTheme.warningColor,
                      )
                    : const Chip(
                        label: Text('Approved'),
                        backgroundColor: AppTheme.successColor,
                      ),
          ),
        );
      },
    );
  }

  Widget _buildClassesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _myClasses.length,
      itemBuilder: (context, index) {
        final classItem = _myClasses[index];
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: AppTheme.successColor),
                    Text('\$${classItem.price.toStringAsFixed(2)}'),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 16, color: AppTheme.neutral600),
                    Text('${classItem.enrolledStudentIds.length}/${classItem.maxStudents} students'),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(classItem.startTime),
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Enrolled',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: AppTheme.warningColor,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  achievement,
                  style: AppTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Unlocked',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
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

  Widget _buildTaskCard(Task task) {
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

  void _completeTask(Task task) {
    final TextEditingController notesController = TextEditingController();
    List<XFile> selectedImages = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Complete: ${task.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add completion notes:'),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    hintText: 'What did you do?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Upload photos (optional):'),
                const SizedBox(height: 8),
                
                // Selected Images Preview
                if (selectedImages.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? Image.network(
                                        selectedImages[index].path,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(selectedImages[index].path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Image Upload Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera, selectedImages, setDialogState),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery, selectedImages, setDialogState),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                
                // Update task status using TasksProvider
                final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
                tasksProvider.completeTask(
                  task.id,
                  notes: notesController.text.isNotEmpty 
                      ? notesController.text 
                      : 'Task completed successfully!',
                  imageUrls: selectedImages.map((img) => img.path).toList(),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task completed! ${selectedImages.length} photo(s) uploaded. Waiting for approval.'),
                  ),
                );
              },
              child: const Text('Complete Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, List<XFile> selectedImages, StateSetter setDialogState) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setDialogState(() {
          selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}
