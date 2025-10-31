import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';

class ChildTaskViewScreen extends StatefulWidget {
  const ChildTaskViewScreen({super.key});

  @override
  State<ChildTaskViewScreen> createState() => _ChildTaskViewScreenState();
}

class _ChildTaskViewScreenState extends State<ChildTaskViewScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final childId = authProvider.currentUser?.id;
    
    if (childId == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in as child')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, _) {
          final allTasks = tasksProvider.tasks;
          final childTasks = allTasks
              .where((task) => task.childId == childId)
              .toList()
            ..sort((a, b) {
              // Sort by due date, pending first
              if (a.status != b.status) {
                if (a.status == TaskStatus.pending) return -1;
                if (b.status == TaskStatus.pending) return 1;
              }
              if (a.dueDate == null && b.dueDate == null) return 0;
              if (a.dueDate == null) return 1;
              if (b.dueDate == null) return -1;
              return a.dueDate!.compareTo(b.dueDate!);
            });

          if (childTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: AppTheme.neutral400),
                  const SizedBox(height: 24),
                  Text(
                    'No tasks assigned!',
                    style: AppTheme.headline6.copyWith(color: AppTheme.neutral600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tasks will appear here when your parent assigns them',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final pendingTasks = childTasks.where((t) => t.status == TaskStatus.pending).toList();
          final completedTasks = childTasks.where((t) => t.status == TaskStatus.completed).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Pending',
                        pendingTasks.length,
                        AppTheme.warningColor,
                        Icons.pending_outlined,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildSummaryCard(
                        'Completed',
                        completedTasks.length,
                        AppTheme.successColor,
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXL),
                
                // Pending Tasks
                if (pendingTasks.isNotEmpty) ...[
                  Text(
                    'Pending Tasks',
                    style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ...pendingTasks.map((task) => _buildTaskCard(task, tasksProvider)),
                  const SizedBox(height: AppTheme.spacingXL),
                ],
                
                // Completed Tasks
                if (completedTasks.isNotEmpty) ...[
                  Text(
                    'Completed Tasks',
                    style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ...completedTasks.map((task) => _buildTaskCard(task, tasksProvider)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                  ),
                  Text(
                    '$count',
                    style: AppTheme.headline4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, TasksProvider tasksProvider) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status == TaskStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: isCompleted ? 1 : 2,
      child: InkWell(
        onTap: () => _showTaskDetails(task, tasksProvider),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (task.isRecurring)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.repeat,
                        size: 16,
                        color: AppTheme.infoColor,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(task.status),
                      style: AppTheme.bodySmall.copyWith(
                        color: _getStatusColor(task.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  task.description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.neutral600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  if (task.dueDate != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: AppTheme.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(task.dueDate!),
                      style: AppTheme.bodySmall.copyWith(
                        color: isOverdue && !isCompleted
                            ? AppTheme.errorColor
                            : AppTheme.neutral600,
                        fontWeight: isOverdue && !isCompleted ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                  ],
                  if (task.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.category!.toUpperCase(),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.neutral700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                  ],
                  if (task.rewardAmount > 0) ...[
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${task.rewardAmount.toInt()} pts',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (!isCompleted) ...[
                const SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCompleteTaskDialog(task, tasksProvider),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteTaskDialog(Task task, TasksProvider tasksProvider) {
    final noteController = TextEditingController();
    List<String> imageUrls = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            const SizedBox(width: 8),
            const Text('Complete Task'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spacingL),
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Add a note (optional)',
                  hintText: 'What did you do?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.neutral100,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Upload pictures (optional)',
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final image = await _imagePicker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 85,
                        );
                        if (image != null && mounted) {
                          // In real app, upload to Firebase Storage and get URL
                          imageUrls.add(image.path);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Picture added!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final image = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image != null && mounted) {
                          // In real app, upload to Firebase Storage and get URL
                          imageUrls.add(image.path);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Picture added!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              if (imageUrls.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  '${imageUrls.length} picture${imageUrls.length == 1 ? '' : 's'} added',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor),
                ),
              ],
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
              final updatedTask = task.copyWith(
                status: TaskStatus.completed,
                completionNotes: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
                imageUrls: imageUrls,
                completedAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              tasksProvider.updateTask(updatedTask);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task marked as complete!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Complete Task'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task, TasksProvider tasksProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacingL),
              ],
              _buildDetailRow(Icons.calendar_today, 'Due Date',
                  task.dueDate != null ? _formatDueDate(task.dueDate!) : 'No due date'),
              _buildDetailRow(Icons.category, 'Category',
                  task.category?.toUpperCase() ?? 'N/A'),
              _buildDetailRow(Icons.star, 'Reward',
                  '${task.rewardAmount.toInt()} points'),
              if (task.isRecurring) ...[
                const SizedBox(height: AppTheme.spacingS),
                _buildDetailRow(Icons.repeat, 'Repeats', task.recurringPattern ?? 'N/A'),
              ],
              if (task.completionNotes != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                const Divider(),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Completion Note:',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  task.completionNotes!,
                  style: AppTheme.bodyMedium,
                ),
              ],
              if (task.imageUrls.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingM),
                const Divider(),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Pictures (${task.imageUrls.length}):',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                // In real app, display images here
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.neutral600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pending),
              title: const Text('Pending Only'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Completed Only'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('All Tasks'),
              onTap: () {
                Navigator.pop(context);
                // Implement filter
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppTheme.warningColor;
      case TaskStatus.completed:
        return AppTheme.successColor;
      case TaskStatus.approved:
        return AppTheme.successColor;
      case TaskStatus.rejected:
        return AppTheme.errorColor;
      case TaskStatus.inProgress:
        return AppTheme.infoColor;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.approved:
        return 'Approved';
      case TaskStatus.rejected:
        return 'Rejected';
      case TaskStatus.inProgress:
        return 'In Progress';
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}

