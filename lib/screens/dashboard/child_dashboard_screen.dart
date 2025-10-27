import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
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
  
  // Mock data for child dashboard
  final List<Task> _myTasks = [
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
      completionNotes: 'Completed all problems correctly!',
    ),
    Task(
      id: '2',
      title: 'Practice Piano',
      description: 'Practice for 30 minutes daily',
      parentId: 'parent1',
      childId: 'child1',
      status: TaskStatus.pending,
      rewardAmount: 3.0,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '3',
      title: 'Read for 20 minutes',
      description: 'Read your favorite book for 20 minutes',
      parentId: 'parent1',
      childId: 'child1',
      status: TaskStatus.inProgress,
      rewardAmount: 2.0,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final List<Class> _myClasses = [
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
      enrolledStudentIds: ['child1'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Class(
      id: '2',
      title: 'Piano Lessons',
      description: 'Individual piano instruction',
      coachId: 'coach2',
      type: ClassType.weekly,
      locationType: LocationType.inPerson,
      location: 'Music Studio',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 5)),
      durationMinutes: 60,
      price: 40.0,
      currency: Currency.usd,
      maxStudents: 1,
      enrolledStudentIds: ['child1'],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  final List<String> _achievements = [
    'First Task Completed',
    'Math Master',
    'Piano Pro',
    'Reading Champion',
    'Perfect Attendance',
  ];

  double get _totalEarnings => _myTasks
      .where((task) => task.status == TaskStatus.approved)
      .fold(0.0, (sum, task) => sum + task.rewardAmount);

  double get _pendingEarnings => _myTasks
      .where((task) => task.status == TaskStatus.completed)
      .fold(0.0, (sum, task) => sum + task.rewardAmount);

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
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/calendar'),
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
          _buildTasksTab(),
          _buildClassesTab(),
          _buildAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
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
                  'Welcome back, Emma!',
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
                  '${_totalEarnings.toInt()} pts',
                  Icons.stars,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '${_pendingEarnings.toInt()} pts',
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
                  _myTasks.where((t) => t.status == TaskStatus.completed || t.status == TaskStatus.approved).length.toString(),
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
          
          // Recent Tasks
          Text(
            'Recent Tasks',
            style: AppTheme.headline6,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ..._myTasks.take(3).map((task) => _buildTaskCard(task)),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: _myTasks.length,
      itemBuilder: (context, index) {
        final task = _myTasks[index];
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
                                child: Image.file(
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
                setState(() {
                  // Update task status to completed
                  final index = _myTasks.indexWhere((t) => t.id == task.id);
                  if (index != -1) {
                    _myTasks[index] = task.copyWith(
                      status: TaskStatus.completed,
                      completedAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      completionNotes: notesController.text.isNotEmpty 
                          ? notesController.text 
                          : 'Task completed successfully!',
                      imageUrls: selectedImages.map((img) => img.path).toList(),
                    );
                  }
                });
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
