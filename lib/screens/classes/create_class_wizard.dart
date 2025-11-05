import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/classes_provider.dart';
import '../../models/class_model.dart';
import '../../utils/app_theme.dart';
import 'dart:math';

class CreateClassWizard extends StatefulWidget {
  final Class? existingClass;
  
  const CreateClassWizard({super.key, this.existingClass});

  @override
  State<CreateClassWizard> createState() => _CreateClassWizardState();
}

class _CreateClassWizardState extends State<CreateClassWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxStudentsController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  
  // Class data
  ClassType _classType = ClassType.weekly;
  LocationType _locationType = LocationType.inPerson;
  bool _isPublic = true;
  bool _isGroupClass = true;
  String _paymentSchedule = 'per_class';
  bool _makeUpClassesAllowed = true;
  Currency _currency = Currency.usd;
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 11, minute: 0);
  
  // Schedule options for recurring classes
  Set<int> _selectedWeekDays = {1}; // 1=Monday, 2=Tuesday, etc. Default to Monday
  int _selectedDayOfMonth = 1; // For monthly classes, day 1-31
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingClass != null) {
      _loadExistingClass();
    }
  }

  void _loadExistingClass() {
    final cls = widget.existingClass!;
    _titleController.text = cls.title;
    _descriptionController.text = cls.description;
    _priceController.text = cls.price.toString();
    _maxStudentsController.text = cls.maxStudents.toString();
    _locationController.text = cls.location ?? '';
    _meetingLinkController.text = cls.meetingLink ?? '';
    _classType = cls.type;
    _locationType = cls.locationType;
    _isPublic = cls.isPublic;
    _isGroupClass = cls.isGroupClass;
    _paymentSchedule = cls.paymentSchedule;
    _makeUpClassesAllowed = cls.makeUpClassesAllowed;
    _currency = cls.currency;
    _selectedDate = cls.startTime;
    _selectedStartTime = TimeOfDay.fromDateTime(cls.startTime);
    _selectedEndTime = TimeOfDay.fromDateTime(cls.endTime);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxStudentsController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.existingClass != null;

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
        title: Text(isEditing ? 'Edit Class' : 'Create Class'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/coach-dashboard');
              }
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Details'),
                Expanded(child: Container(height: 2, color: AppTheme.neutral200)),
                _buildStepIndicator(1, 'Schedule'),
                Expanded(child: Container(height: 2, color: AppTheme.neutral200)),
                _buildStepIndicator(2, 'Pricing'),
                Expanded(child: Container(height: 2, color: AppTheme.neutral200)),
                _buildStepIndicator(3, 'Review'),
              ],
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStep1ClassDetails(),
                _buildStep2Schedule(),
                _buildStep3Pricing(),
                _buildStep4Review(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 3 ? _createClass : _nextStep,
                    child: Text(_currentStep == 3 ? (isEditing ? 'Update Class' : 'Create Class') : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? AppTheme.primaryColor : AppTheme.neutral200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.neutral600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    );
  }

  // Step 1: Class Details
  Widget _buildStep1ClassDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Details',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Tell us about your class',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Class Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Class Title',
              hintText: 'e.g., Soccer Training for Beginners',
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe what students will learn...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Public/Private Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  const Icon(Icons.public, color: AppTheme.primaryColor),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Public Class',
                          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _isPublic ? 'Anyone can browse and enroll' : 'Invite only',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Group/Individual Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  Icon(
                    _isGroupClass ? Icons.groups : Icons.person,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isGroupClass ? 'Group Class' : 'Individual (1-on-1)',
                          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _isGroupClass ? 'Multiple students per session' : 'One student per session',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isGroupClass,
                    onChanged: (value) {
                      setState(() {
                        _isGroupClass = value;
                        if (!value) {
                          _maxStudentsController.text = '1';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Schedule
  Widget _buildStep2Schedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'When and where is your class?',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Class Type
          Text(
            'Class Type:',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('One-Time', ClassType.oneTime),
              _buildTypeChip('Weekly', ClassType.weekly),
              _buildTypeChip('Monthly', ClassType.monthly),
            ],
          ),
          
          // Day selection for weekly classes
          if (_classType == ClassType.weekly) ...[
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
          
          // Day selection for monthly classes
          if (_classType == ClassType.monthly) ...[
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
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Location Type
          Text(
            'Location Type:',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: 8,
            children: [
              _buildLocationChip('In-Person', LocationType.inPerson),
              _buildLocationChip('Online', LocationType.online),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Location/Meeting Link
          if (_locationType == LocationType.inPerson)
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Community Center, Room 101',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            TextFormField(
              controller: _meetingLinkController,
              decoration: InputDecoration(
                labelText: 'Meeting Link',
                hintText: 'e.g., https://zoom.us/j/123456789',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Date and Time
          Text(
            'Schedule:',
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
                              const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _classType == ClassType.oneTime ? 'Date' : 'Start Date',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
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
          const SizedBox(height: AppTheme.spacingM),
          
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Start Time',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedStartTime.format(context),
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
                    onTap: () => _selectTime(context, false),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'End Time',
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedEndTime.format(context),
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
        ],
      ),
    );
  }

  // Step 3: Pricing
  Widget _buildStep3Pricing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing & Registration',
            style: AppTheme.headline5.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Set your pricing and class size',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Price with Currency Selector
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: '25.00',
                    prefixText: '${_getCurrencySymbol(_currency)} ',
                    prefixStyle: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixText: _currency.toString().split('.').last.toUpperCase(),
                    suffixStyle: TextStyle(
                      color: AppTheme.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.neutral100,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: DropdownButtonFormField<Currency>(
                  value: _currency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: Currency.values.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Payment Schedule
          Text(
            'Payment Schedule:',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentChip('Per Class', 'per_class'),
              _buildPaymentChip('Monthly', 'monthly'),
              _buildPaymentChip('Per Term', 'term'),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Max Students (for group classes)
          if (_isGroupClass)
            TextFormField(
              controller: _maxStudentsController,
              decoration: InputDecoration(
                labelText: 'Maximum Students',
                hintText: '15',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          if (_isGroupClass) const SizedBox(height: AppTheme.spacingL),
          
          // Make-up Classes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  const Icon(Icons.event_repeat, color: AppTheme.primaryColor),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allow Make-up Classes',
                          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Students can reschedule if they miss a class',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _makeUpClassesAllowed,
                    onChanged: (value) {
                      setState(() {
                        _makeUpClassesAllowed = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Review
  Widget _buildStep4Review() {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );
    
    final duration = endDateTime.difference(startDateTime).inMinutes;
    
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
          
          // Class summary card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text.isEmpty ? 'Untitled Class' : _titleController.text,
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
                  _buildReviewRow(Icons.event, 'Type', _classType.toString().split('.').last.toUpperCase()),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    _locationType == LocationType.inPerson ? Icons.location_on : Icons.link,
                    _locationType == LocationType.inPerson ? 'Location' : 'Meeting Link',
                    _locationType == LocationType.inPerson 
                        ? (_locationController.text.isEmpty ? 'Not specified' : _locationController.text)
                        : (_meetingLinkController.text.isEmpty ? 'Not specified' : _meetingLinkController.text),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.calendar_today,
                    'Schedule',
                    '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year} ${_selectedStartTime.format(context)} - ${_selectedEndTime.format(context)}',
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.attach_money,
                    'Price',
                    '${_getCurrencySymbol(_currency)}${_priceController.text.isEmpty ? '0' : _priceController.text} ${_currency.toString().split('.').last.toUpperCase()} (${_paymentSchedule.replaceAll('_', ' ')})',
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.people,
                    'Class Size',
                    _isGroupClass ? 'Group (max ${_maxStudentsController.text.isEmpty ? '10' : _maxStudentsController.text})' : 'Individual (1-on-1)',
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildReviewRow(
                    Icons.public,
                    'Visibility',
                    _isPublic ? 'Public (Anyone can enroll)' : 'Private (Invite only)',
                  ),
                  if (_makeUpClassesAllowed) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    _buildReviewRow(
                      Icons.event_repeat,
                      'Make-up Classes',
                      'Allowed',
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Shareable link info
          if (_isPublic)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppTheme.successColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A shareable enrollment link will be generated after creating this class.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.successColor),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, ClassType type) {
    final isSelected = _classType == type;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _classType = type;
            // Clear day selections when changing type
            if (type != ClassType.weekly) {
              _selectedWeekDays = {1}; // Reset to Monday
            }
            if (type != ClassType.monthly) {
              _selectedDayOfMonth = 1; // Reset to 1st
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
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.neutral700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
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

  Widget _buildLocationChip(String label, LocationType type) {
    final isSelected = _locationType == type;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _locationType = type;
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

  Widget _buildPaymentChip(String label, String value) {
    final isSelected = _paymentSchedule == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _paymentSchedule = value;
          });
        }
      },
      selectedColor: AppTheme.successColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.neutral700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 2),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _selectedStartTime : _selectedEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  String _getCurrencySymbol(Currency currency) {
    switch (currency) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.cad:
        return 'C\$';
      case Currency.aud:
        return 'A\$';
      case Currency.inr:
        return '₹';
    }
  }

  String _generateShareableLink(String classId) {
    // Generate a unique shareable link
    final random = Random();
    final code = String.fromCharCodes(
      List.generate(8, (index) => random.nextInt(26) + 65),
    );
    return 'sparktracks://enroll/$classId/$code';
  }

  Future<void> _createClass() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
      
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );
      
      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );
      
      final duration = endDateTime.difference(startDateTime).inMinutes;
      final classId = widget.existingClass?.id ?? 'class_${DateTime.now().millisecondsSinceEpoch}';
      
      final classItem = Class(
        id: classId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        coachId: authProvider.currentUser?.id ?? '',
        type: _classType,
        locationType: _locationType,
        location: _locationType == LocationType.inPerson ? _locationController.text.trim() : null,
        meetingLink: _locationType == LocationType.online ? _meetingLinkController.text.trim() : null,
        startTime: startDateTime,
        endTime: endDateTime,
        durationMinutes: duration,
        price: double.tryParse(_priceController.text) ?? 0.0,
        currency: _currency,
        maxStudents: _isGroupClass ? (int.tryParse(_maxStudentsController.text) ?? 10) : 1,
        createdAt: widget.existingClass?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: _isPublic,
        isGroupClass: _isGroupClass,
        paymentSchedule: _paymentSchedule,
        makeUpClassesAllowed: _makeUpClassesAllowed,
        shareableLink: _isPublic ? _generateShareableLink(classId) : null,
      );

      if (isEditing) {
        classesProvider.updateClass(classItem);
      } else {
        classesProvider.addClass(classItem);
      }

      if (mounted) {
        // Show shareable link if public
        if (_isPublic && classItem.shareableLink != null) {
          _showShareableLinkDialog(classItem.shareableLink!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Class updated successfully!' : 'Class created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/coach-dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${isEditing ? 'updating' : 'creating'} class: $e'),
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

  void _showShareableLinkDialog(String link) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Class Created!'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your class has been created. Share this link for enrollment:',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.neutral50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.neutral200),
                ),
                child: SelectableText(
                  link,
                  style: AppTheme.bodyMedium.copyWith(
                    fontFamily: 'monospace',
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Link copied to clipboard!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              label: const Text('Copy Link'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/coach-dashboard');
                }
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

