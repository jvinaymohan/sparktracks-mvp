import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../models/student_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class BulkTaskCreationDialog extends StatefulWidget {
  final List<Student> children;

  const BulkTaskCreationDialog({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  State<BulkTaskCreationDialog> createState() => _BulkTaskCreationDialogState();
}

class _BulkTaskCreationDialogState extends State<BulkTaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final Set<String> _selectedChildrenIds = {};
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  String? _recurringPattern; // 'daily', 'weekly', 'monthly'
  String? _category;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Select all children by default
    _selectedChildrenIds.addAll(widget.children.map((c) => c.id));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTasks() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildrenIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one child'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final parentId = authProvider.currentUser?.id ?? '';
      final firestoreService = FirestoreService();

      int successCount = 0;
      
      for (var childId in _selectedChildrenIds) {
        final task = Task(
          id: 'task_${childId}_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          childId: childId,
          parentId: parentId,
          status: TaskStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueDate: _dueDate,
          priority: _priority,
          recurringPattern: _recurringPattern,
          category: _category,
        );

        await firestoreService.addTask(task);
        successCount++;
      }

      if (mounted) {
        Navigator.of(context).pop(successCount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✅ Created $successCount ${successCount == 1 ? 'task' : 'tasks'} successfully!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tasks: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.playlist_add, color: AppTheme.primaryColor),
          SizedBox(width: 12),
          Text('Create Tasks for Multiple Children'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Details
                Text('Task Details', style: AppTheme.headline6),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Due Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date (optional)',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _dueDate != null
                          ? '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'
                          : 'Select due date',
                      style: TextStyle(
                        color: _dueDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Priority
                DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Category
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Homework, Chores, Practice',
                  ),
                  onChanged: (value) => _category = value.trim().isEmpty ? null : value.trim(),
                ),
                const SizedBox(height: 16),
                
                // Recurring Pattern
                DropdownButtonFormField<String>(
                  value: _recurringPattern,
                  decoration: const InputDecoration(
                    labelText: 'Recurring (optional)',
                    prefixIcon: Icon(Icons.repeat),
                    border: OutlineInputBorder(),
                    hintText: 'Select if task repeats',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Not recurring')),
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (value) {
                    setState(() => _recurringPattern = value);
                  },
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Select Children
                Text('Select Children', style: AppTheme.headline6),
                const SizedBox(height: 12),
                Text(
                  'This task will be assigned to all selected children',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                ),
                const SizedBox(height: 12),
                
                // Select All / Deselect All
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedChildrenIds.addAll(widget.children.map((c) => c.id));
                        });
                      },
                      icon: const Icon(Icons.select_all, size: 16),
                      label: const Text('Select All'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedChildrenIds.clear();
                        });
                      },
                      icon: const Icon(Icons.deselect, size: 16),
                      label: const Text('Deselect All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Children List
                ...widget.children.map((child) {
                  final isSelected = _selectedChildrenIds.contains(child.id);
                  return CheckboxListTile(
                    title: Text(child.name),
                    subtitle: Text(child.email),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedChildrenIds.add(child.id);
                        } else {
                          _selectedChildrenIds.remove(child.id);
                        }
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        child.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will create ${_selectedChildrenIds.length} ${_selectedChildrenIds.length == 1 ? 'task' : 'tasks'}',
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isCreating ? null : _createTasks,
          icon: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_task),
          label: Text(_isCreating ? 'Creating...' : 'Create Tasks'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

