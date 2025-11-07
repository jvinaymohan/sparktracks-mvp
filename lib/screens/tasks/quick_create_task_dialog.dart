import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';

/// Quick single-screen task creation - simple & fast!
class QuickCreateTaskDialog extends StatefulWidget {
  const QuickCreateTaskDialog({super.key});

  @override
  State<QuickCreateTaskDialog> createState() => _QuickCreateTaskDialogState();
}

class _QuickCreateTaskDialogState extends State<QuickCreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedChildId;
  String _selectedCategory = 'Chores';
  double _rewardPoints = 10.0;
  bool _isSubmitting = false;
  bool _isRecurring = false;
  String _recurringPattern = 'daily';
  Set<int> _selectedWeekDays = {1}; // Monday default
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));

  final List<Map<String, dynamic>> _quickCategories = [
    {'name': 'Chores', 'icon': Icons.cleaning_services, 'color': '#4CAF50'},
    {'name': 'Homework', 'icon': Icons.school, 'color': '#2196F3'},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': '#FF9800'},
    {'name': 'Music', 'icon': Icons.music_note, 'color': '#9C27B0'},
    {'name': 'Reading', 'icon': Icons.book, 'color': '#F44336'},
    {'name': 'Other', 'icon': Icons.star, 'color': '#00BCD4'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  Widget _buildDayChip(String label, int day) {
    final isSelected = _selectedWeekDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedWeekDays.add(day);
          } else {
            _selectedWeekDays.remove(day);
          }
        });
      },
      selectedColor: AppTheme.accentColor.withOpacity(0.3),
      checkmarkColor: AppTheme.accentColor,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isSelected ? AppTheme.accentColor : AppTheme.neutral600,
      ),
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      
      final newTask = Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        parentId: authProvider.currentUser?.id ?? '',
        childId: _selectedChildId!,
        title: _titleController.text.trim(),
        description: '',
        rewardAmount: _rewardPoints,
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        category: _selectedCategory,
        dueDate: _selectedDueDate,
        isRecurring: _isRecurring,
        recurringPattern: _isRecurring ? _recurringPattern : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tasksProvider.addTask(newTask);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Task created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final myChildren = childrenProvider.getChildrenForParent(authProvider.currentUser?.id ?? '');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.task_alt, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Task',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Create in seconds!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Task Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'What needs to be done?',
                      hintText: 'e.g., Clean your room',
                      prefixIcon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.neutral100,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  
                  // Child Selection
                  if (myChildren.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber, color: AppTheme.warningColor),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Please add a child first before creating tasks.'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    const Text(
                      'Assign to:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: myChildren.map((child) {
                        final isSelected = _selectedChildId == child.userId;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedChildId = child.userId),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(int.parse('FF${child.colorCode?.substring(1) ?? '4CAF50'}', radix: 16))
                                  : AppTheme.neutral100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.white : AppTheme.neutral300,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isSelected ? Colors.white : Color(int.parse('FF${child.colorCode?.substring(1) ?? '4CAF50'}', radix: 16)),
                                  child: Text(
                                    child.name[0].toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? Color(int.parse('FF${child.colorCode?.substring(1) ?? '4CAF50'}', radix: 16)) : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  child.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.neutral700,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Category
                  const Text(
                    'Category:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickCategories.map((cat) {
                      final isSelected = _selectedCategory == cat['name'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat['icon'] as IconData, size: 16),
                            const SizedBox(width: 6),
                            Text(cat['name'] as String),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat['name'] as String);
                          }
                        },
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.neutral700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reward Points
                  const Text(
                    'Reward:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                      Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _rewardPoints,
                          min: 10,
                          max: 100,
                          divisions: 9,
                          label: '${_rewardPoints.toInt()} points',
                          activeColor: AppTheme.successColor,
                          onChanged: (value) => setState(() => _rewardPoints = ((value / 10).round() * 10).toDouble()),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '⭐',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_rewardPoints.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || myChildren.isEmpty ? null : _createTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.rocket_launch, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Create Task',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/create-task');
                      },
                      child: const Text('Need more options? Use advanced task creator →'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

