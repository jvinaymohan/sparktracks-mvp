import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../models/task_model.dart';
import '../../models/student_model.dart';
import '../../utils/app_theme.dart';

class CreateTaskWizard extends StatefulWidget {
  final Task? existingTask; // For editing
  
  const CreateTaskWizard({super.key, this.existingTask});

  @override
  State<CreateTaskWizard> createState() => _CreateTaskWizardState();
}

class _CreateTaskWizardState extends State<CreateTaskWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();
  
  // Task data
  String? _selectedChildId;
  Set<String> _selectedChildIds = {}; // Multiple children support
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedDueTime = TimeOfDay(hour: 17, minute: 0); // 5 PM default
  bool _isRecurring = false;
  String _recurringPattern = 'daily';
  String _selectedCategory = 'chores';
  Set<int> _selectedWeekDays = {}; // 1=Monday, 2=Tuesday, ..., 7=Sunday
  int _selectedDayOfMonth = 1; // For monthly tasks
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _loadExistingTask();
    }
  }

  void _loadExistingTask() {
    final task = widget.existingTask!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _rewardController.text = task.rewardAmount.toInt().toString();
    _selectedChildId = task.childId;
    if (task.dueDate != null) {
      _selectedDueDate = task.dueDate!;
      _selectedDueTime = TimeOfDay.fromDateTime(task.dueDate!);
    }
    _isRecurring = task.isRecurring;
    _recurringPattern = task.recurringPattern ?? 'daily';
    _selectedCategory = task.category ?? 'chores';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.existingTask != null;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/parent-dashboard');
            }
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              tooltip: 'Back to Dashboard',
              onPressed: () => context.go('/parent-dashboard'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Wizard content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1BasicInfo(),
                _buildStep2ChildAndDate(),
                _buildStep3CategoryAndReward(),
                _buildStep4Review(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Info', Icons.edit_note),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Assign', Icons.person),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Reward', Icons.star),
          _buildStepConnector(2),
          _buildStepIndicator(3, 'Review', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : isActive
                      ? AppTheme.primaryColor
                      : AppTheme.neutral300,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isActive ? AppTheme.primaryColor : AppTheme.neutral600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? Colors.green : AppTheme.neutral300,
      ),
    );
  }

  // Step 1: Basic Info
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What needs to be done?',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Give your task a clear, descriptive title',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Task Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title *',
              hintText: 'e.g., Clean your room',
              prefixIcon: const Icon(Icons.assignment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.neutral100,
            ),
            style: AppTheme.bodyLarge,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Task Description
          Text(
            'Add details (optional)',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingS),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'What should they do? Any special instructions?',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.neutral100,
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Quick suggestions
          Text(
            'Quick suggestions:',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Clean your room'),
              _buildSuggestionChip('Do homework'),
              _buildSuggestionChip('Practice piano'),
              _buildSuggestionChip('Water the plants'),
              _buildSuggestionChip('Take out trash'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String title) {
    return ActionChip(
      label: Text(title),
      onPressed: () {
        setState(() {
          _titleController.text = title;
        });
      },
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: AppTheme.primaryColor),
    );
  }

  // Step 2: Assign Child and Set Date
  Widget _buildStep2ChildAndDate() {
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final children = childrenProvider.children;
    
    if (_selectedChildId == null && children.isNotEmpty) {
      _selectedChildId = children[0].userId; // Use Firebase User ID
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who and when?',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Assign this task to a child and set the deadline',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Assign to child
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assign to:',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              if (children.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedChildIds.length == children.length) {
                        _selectedChildIds.clear();
                      } else {
                        _selectedChildIds = children.map((c) => c.userId).toSet();
                      }
                    });
                  },
                  icon: Icon(_selectedChildIds.length == children.length ? Icons.deselect : Icons.select_all),
                  label: Text(_selectedChildIds.length == children.length ? 'Deselect All' : 'Select All'),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          if (children.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  children: [
                    Icon(Icons.child_care, size: 48, color: AppTheme.neutral400),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'No children added yet',
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Add a child first to assign tasks',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/add-child'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Child'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...children.map((child) => _buildChildSelectionCard(child)),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Due date
          Text(
            'Due date and time:',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Date',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedDueDate.month}/${_selectedDueDate.day}/${_selectedDueDate.year}',
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Time',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedDueTime.format(context),
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Recurring option
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.repeat, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repeat this task',
                              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Make this a recurring task',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Repeat every:',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRecurringChip('Daily', 'daily'),
                        _buildRecurringChip('Weekly', 'weekly'),
                        _buildRecurringChip('Monthly', 'monthly'),
                      ],
                    ),
                    
                    // Day selection for monthly tasks
                    if (_recurringPattern == 'monthly') ...[
                      const SizedBox(height: AppTheme.spacingL),
                      Text(
                        'Select day of month:',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      DropdownButtonFormField<int>(
                        value: _selectedDayOfMonth,
                        decoration: InputDecoration(
                          labelText: 'Day of Month',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                        items: List.generate(31, (index) {
                          final day = index + 1;
                          return DropdownMenuItem(
                            value: day,
                            child: Text('Day $day${_getDaySuffix(day)} of each month'),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDayOfMonth = value;
                            });
                          }
                        },
                      ),
                    ],
                    
                    // Day selection for weekly tasks
                    if (_recurringPattern == 'weekly') ...[
                      const SizedBox(height: AppTheme.spacingL),
                      Text(
                        'Select days of the week:',
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildDayChip('Mon', 1),
                          _buildDayChip('Tue', 2),
                          _buildDayChip('Wed', 3),
                          _buildDayChip('Thu', 4),
                          _buildDayChip('Fri', 5),
                          _buildDayChip('Sat', 6),
                          _buildDayChip('Sun', 7),
                        ],
                      ),
                      if (_selectedWeekDays.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select at least one day',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelectionCard(Student child) {
    final isSelected = _selectedChildIds.contains(child.userId); // Use Firebase User ID
    final colorValue = int.parse(child.colorCode?.replaceFirst('#', '0xFF') ?? '0xFF4CAF50');
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedChildIds.remove(child.userId);
            } else {
              _selectedChildIds.add(child.userId);
            }
            // Keep backward compatibility with single selection
            _selectedChildId = _selectedChildIds.isNotEmpty ? _selectedChildIds.first : null;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(colorValue),
                radius: 24,
                child: Text(
                  child.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                      child.name,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Age ${DateTime.now().year - child.dateOfBirth.year}',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedChildIds.add(child.userId);
                    } else {
                      _selectedChildIds.remove(child.userId);
                    }
                    _selectedChildId = _selectedChildIds.isNotEmpty ? _selectedChildIds.first : null;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringChip(String label, String value) {
    final isSelected = _recurringPattern == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _recurringPattern = value;
            // Clear day selection when switching from weekly
            if (value != 'weekly') {
              _selectedWeekDays.clear();
            }
          });
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.neutral700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDayChip(String label, int dayNumber) {
    final isSelected = _selectedWeekDays.contains(dayNumber);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedWeekDays.add(dayNumber);
          } else {
            _selectedWeekDays.remove(dayNumber);
          }
        });
      },
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.neutral700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _getSelectedDaysText() {
    if (_selectedWeekDays.isEmpty) return '';
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDayNames = _selectedWeekDays.map((day) => days[day - 1]).toList();
    selectedDayNames.sort((a, b) => days.indexOf(a).compareTo(days.indexOf(b)));
    
    return selectedDayNames.join(', ');
  }
  
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  // Step 3: Category and Reward
  Widget _buildStep3CategoryAndReward() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category & Reward',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Choose a category and set the reward points',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Category selection
          Text(
            'Task category:',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildCategoryCard('Chores', Icons.cleaning_services, 'chores', Colors.blue),
                _buildCategoryCard('Homework', Icons.school, 'homework', Colors.purple),
                _buildCategoryCard('Reading', Icons.menu_book, 'reading', Colors.orange),
                _buildCategoryCard('Practice', Icons.music_note, 'practice', Colors.green),
                _buildCategoryCard('Exercise', Icons.fitness_center, 'exercise', Colors.red),
                _buildCategoryCard('Other', Icons.more_horiz, 'other', Colors.grey),
              ],
            ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Reward points
          Text(
            'Reward points:',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'How many points should they earn?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          TextFormField(
            controller: _rewardController,
            decoration: InputDecoration(
              labelText: 'Points',
              hintText: '10',
              prefixIcon: const Icon(Icons.star, color: Colors.amber),
              suffix: const Text('pts'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppTheme.neutral100,
            ),
            keyboardType: TextInputType.number,
            style: AppTheme.headline6,
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Suggested rewards
          Text(
            'Suggested:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: 8,
            children: [
              _buildRewardChip('5 pts', '5'),
              _buildRewardChip('10 pts', '10'),
              _buildRewardChip('20 pts', '20'),
              _buildRewardChip('50 pts', '50'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, String category, Color color) {
    final isSelected = _selectedCategory == category;
    
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 60) / 2,
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? color : AppTheme.neutral600,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : AppTheme.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardChip(String label, String value) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _rewardController.text = value;
        });
      },
      backgroundColor: Colors.amber.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
    );
  }

  // Step 4: Review
  Widget _buildStep4Review() {
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    
    // Get all selected children
    final childrenToAssign = _selectedChildIds.isNotEmpty 
      ? childrenProvider.children.where((c) => _selectedChildIds.contains(c.userId)).toList()
      : (_selectedChildId != null 
        ? childrenProvider.children.where((c) => c.userId == _selectedChildId).toList()
        : []);
    
    final selectedChildrenNames = childrenToAssign.isNotEmpty
      ? childrenToAssign.map((c) => c.name).join(', ')
      : 'No child selected';
    
    final selectedChild = childrenToAssign.isNotEmpty ? childrenToAssign.first : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Create',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Double-check everything looks good',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Task summary card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _titleController.text.isEmpty ? 'Untitled Task' : _titleController.text,
                    style: AppTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                  ),
                  
                  if (_descriptionController.text.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      _descriptionController.text,
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                  
                  const SizedBox(height: AppTheme.spacingL),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Details
                  _buildReviewRow(
                    Icons.person, 
                    'Assigned to', 
                    childrenToAssign.length > 1 
                      ? '${childrenToAssign.length} children: $selectedChildrenNames'
                      : selectedChildrenNames,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.calendar_today,
                    'Due date',
                    '${_selectedDueDate.month}/${_selectedDueDate.day}/${_selectedDueDate.year} at ${_selectedDueTime.format(context)}',
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.category,
                    'Category',
                    _selectedCategory.substring(0, 1).toUpperCase() + _selectedCategory.substring(1),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.star,
                    'Reward',
                    '${_rewardController.text.isEmpty ? '0' : _rewardController.text} points',
                  ),
                  
                  if (_isRecurring) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    _buildReviewRow(
                      Icons.repeat,
                      'Repeats',
                      _recurringPattern.toUpperCase() + 
                        (_recurringPattern == 'weekly' && _selectedWeekDays.isNotEmpty 
                          ? ' (${_getSelectedDaysText()})'
                          : _recurringPattern == 'monthly'
                          ? ' (Day $_selectedDayOfMonth${_getDaySuffix(_selectedDayOfMonth)})'
                          : ''),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Info box
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.infoColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The task will appear on your calendar and in the child\'s task list.',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.infoColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
              ),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppTheme.spacingM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep == 3 ? (isEditing ? 'Update Task' : 'Create Task') : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    // Validation for each step
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a task title')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedChildIds.isEmpty && _selectedChildId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one child')),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (_rewardController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter reward points')),
        );
        return;
      }
    }

    if (_currentStep == 3) {
      _createTask();
    } else {
      _nextStep();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );
    if (picked != null && picked != _selectedDueTime) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  Future<void> _createTask() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      
      final dueDateTime = DateTime(
        _selectedDueDate.year,
        _selectedDueDate.month,
        _selectedDueDate.day,
        _selectedDueTime.hour,
        _selectedDueTime.minute,
      );

      // Get all children to assign to
      final childrenToAssign = _selectedChildIds.isNotEmpty 
        ? _selectedChildIds.toList() 
        : (_selectedChildId != null ? [_selectedChildId!] : []);

      if (isEditing) {
        // When editing, only update the single task
        final task = Task(
          id: widget.existingTask!.id,
          parentId: authProvider.currentUser?.id ?? 'parent1',
          childId: _selectedChildId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          dueDate: dueDateTime,
          rewardAmount: (int.tryParse(_rewardController.text) ?? 0).toDouble(),
          status: widget.existingTask!.status,
          isRecurring: _isRecurring,
          recurringPattern: _isRecurring ? _recurringPattern : null,
          createdAt: widget.existingTask!.createdAt,
          updatedAt: DateTime.now(),
        );
        tasksProvider.updateTask(task);
      } else {
        // When creating new, create one task for each selected child
        for (var childId in childrenToAssign) {
          final task = Task(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}_$childId',
            parentId: authProvider.currentUser?.id ?? 'parent1',
            childId: childId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            dueDate: dueDateTime,
            rewardAmount: (int.tryParse(_rewardController.text) ?? 0).toDouble(),
            status: TaskStatus.pending,
            isRecurring: _isRecurring,
            recurringPattern: _isRecurring ? _recurringPattern : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          tasksProvider.addTask(task);
          // Small delay between tasks to ensure unique IDs
          await Future.delayed(const Duration(milliseconds: 10));
        }
      }

      if (mounted) {
        final tasksCreatedCount = childrenToAssign.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
              ? 'Task updated successfully!' 
              : tasksCreatedCount > 1 
                ? 'Task assigned to $tasksCreatedCount children successfully!'
                : 'Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/parent-dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${isEditing ? 'updating' : 'creating'} task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

