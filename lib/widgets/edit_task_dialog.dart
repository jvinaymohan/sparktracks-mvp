import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';

/// Dialog for parents to edit existing tasks
class EditTaskDialog extends StatefulWidget {
  final Task task;
  
  const EditTaskDialog({super.key, required this.task});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late double _rewardAmount;
  late TaskPriority _priority;
  late String _category;
  late DateTime _dueDate;
  late bool _isRecurring;
  late String _recurringPattern;
  late List<int> _selectedWeekDays;
  DateTime? _recurringEndDate;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'household',
    'academic',
    'practice',
    'health',
    'family',
    'other',
  ];

  final Map<int, String> _weekDayNames = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _rewardAmount = widget.task.rewardAmount;
    _priority = widget.task.priority;
    _category = widget.task.category ?? 'household';
    _dueDate = widget.task.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _isRecurring = widget.task.isRecurring;
    _recurringPattern = widget.task.recurringPattern ?? 'daily';
    // Extract week days from metadata if available
    final metadataWeekDays = widget.task.metadata['recurringWeekDays'];
    _selectedWeekDays = metadataWeekDays is List
        ? List<int>.from(metadataWeekDays)
        : [DateTime.now().weekday];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Build metadata with recurring week days if applicable
      final metadata = Map<String, dynamic>.from(widget.task.metadata);
      if (_isRecurring && _recurringPattern == 'weekly') {
        metadata['recurringWeekDays'] = _selectedWeekDays;
      }
      if (_recurringEndDate != null) {
        metadata['recurringEndDate'] = Timestamp.fromDate(_recurringEndDate!);
      }

      final updates = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rewardAmount': _rewardAmount,
        'priority': _priority.toString().split('.').last,
        'category': _category,
        'dueDate': Timestamp.fromDate(_dueDate),
        'isRecurring': _isRecurring,
        'recurringPattern': _isRecurring ? _recurringPattern : null,
        'metadata': metadata,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.task.id)
          .update(updates);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Task updated successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          const Text('Edit Task'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              
              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat[0].toUpperCase() + cat.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Points
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Points: ${_rewardAmount.toInt()}', 
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        Slider(
                          value: _rewardAmount,
                          min: 5,
                          max: 100,
                          divisions: 19,
                          label: _rewardAmount.toInt().toString(),
                          onChanged: (value) => setState(() => _rewardAmount = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Priority
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                        DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
                        DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _priority = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Recurring Toggle
              SwitchListTile(
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
                title: const Text('Recurring Task'),
                subtitle: const Text('Repeats on a schedule'),
                contentPadding: EdgeInsets.zero,
              ),
              
              // Recurring Options
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recurring Schedule',
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      
                      // Pattern
                      DropdownButtonFormField<String>(
                        value: _recurringPattern,
                        decoration: const InputDecoration(
                          labelText: 'Repeat Pattern',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _recurringPattern = value);
                          }
                        },
                      ),
                      
                      // Week Days (only for weekly)
                      if (_recurringPattern == 'weekly') ...[
                        const SizedBox(height: 16),
                        Text(
                          'Days of Week',
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                            final isSelected = _selectedWeekDays.contains(day);
                            return FilterChip(
                              label: Text(_weekDayNames[day]!),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedWeekDays.add(day);
                                  } else {
                                    _selectedWeekDays.remove(day);
                                  }
                                  _selectedWeekDays.sort();
                                });
                              },
                              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                              checkmarkColor: AppTheme.primaryColor,
                            );
                          }).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Recurring End Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.event, color: AppTheme.primaryColor),
                        title: const Text('End Date (Optional)'),
                        subtitle: Text(
                          _recurringEndDate != null
                              ? DateFormat('MMM d, y').format(_recurringEndDate!)
                              : 'Continues indefinitely',
                          style: AppTheme.bodySmall,
                        ),
                        trailing: _recurringEndDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _recurringEndDate = null),
                              )
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _recurringEndDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _recurringEndDate = date);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
              
              // Due Date (for non-recurring or first instance)
              if (!_isRecurring) ...[
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.event, color: AppTheme.primaryColor),
                  title: const Text('Due Date'),
                  subtitle: Text(
                    DateFormat('MMM d, y').format(_dueDate),
                    style: AppTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _saveChanges,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save),
          label: Text(_isSubmitting ? 'Saving...' : 'Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

