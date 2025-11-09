import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/class_model.dart';
import '../../models/coach_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/classes_provider.dart';
import '../../services/ai_class_suggestions_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

/// Intelligent Class Creation Wizard with AI Suggestions (v3.0)
class IntelligentClassWizard extends StatefulWidget {
  final Class? existingClass;
  
  const IntelligentClassWizard({super.key, this.existingClass});

  @override
  State<IntelligentClassWizard> createState() => _IntelligentClassWizardState();
}

class _IntelligentClassWizardState extends State<IntelligentClassWizard> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Coach profile for context
  CoachProfile? _coachProfile;
  
  // Step 1: Category
  String? _selectedCategory;
  String? _selectedSpecialization;
  
  // Step 2: AI Suggestion
  ClassSuggestion? _selectedTemplate;
  bool _useCustom = false;
  
  // Step 3: Basic Details (auto-filled from template)
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  SkillLevel _skillLevel = SkillLevel.beginner;
  int _minAge = 6;
  int _maxAge = 18;
  int _minStudents = 1;
  int _maxStudents = 10;
  int _duration = 60;
  
  // Step 4: Location
  ClassLocationOption _locationOption = ClassLocationOption.coachLocation;
  final _facilityController = TextEditingController();
  final _outdoorLocationController = TextEditingController();
  double _travelFee = 0;
  int _maxTravelDistance = 10;
  
  // Step 5: Pricing
  PricingModel _pricingModel = PricingModel.perSession;
  double _sessionPrice = 50;
  double _monthlyPrice = 200;
  double _packagePrice = 400;
  int _packageSessions = 10;
  Currency _currency = Currency.usd;
  bool _offersTrial = true;
  double _trialPrice = 0;
  int _trialDuration = 30;
  
  // Step 6: Materials & Policies
  List<String> _materials = [];
  List<String> _prerequisites = [];
  bool _includesProgressReports = true;
  bool _includesHomework = false;
  bool _includesCertificate = false;
  bool _includesRecordings = false;
  int _cancellationHours = 24;
  double _cancellationFeePercent = 50;
  
  // Step 7: Schedule & Publish
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  bool _isRecurring = true;
  String _recurringPattern = 'weekly'; // weekly, biweekly, monthly, custom
  List<int> _selectedWeekDays = [1]; // Monday by default
  DateTime? _seriesEndDate;
  bool _hasEndDate = false;
  int _numberOfSessions = 8;
  bool _isPublic = true;
  
  @override
  void initState() {
    super.initState();
    _loadCoachProfile();
    if (widget.existingClass != null) {
      _loadExistingClass();
    }
  }

  Future<void> _loadCoachProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coachId = authProvider.currentUser?.id ?? '';
    
    final profile = await FirestoreService().getCoachProfile(coachId);
    if (profile != null && mounted) {
      setState(() => _coachProfile = profile);
    }
  }

  void _loadExistingClass() {
    final c = widget.existingClass!;
    _titleController.text = c.title;
    _descriptionController.text = c.description;
    _selectedCategory = c.category;
    _selectedSpecialization = c.subcategory;
    _skillLevel = c.skillLevel ?? SkillLevel.beginner;
    _minAge = c.minAge ?? 6;
    _maxAge = c.maxAge ?? 18;
    _minStudents = c.minStudents ?? 1;
    _maxStudents = c.maxStudents;
    _duration = c.durationMinutes;
    _locationOption = c.locationOption ?? ClassLocationOption.coachLocation;
    _pricingModel = c.pricingModel ?? PricingModel.perSession;
    _sessionPrice = c.price;
    _currency = c.currency;
    _offersTrial = c.offersTrial;
    _isPublic = c.isPublic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingClass == null ? 'Create Class with AI' : 'Edit Class'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(child: _buildCurrentStep()),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / 8;
    final stepNames = [
      'Category',
      'AI Suggestions',
      'Details',
      'Location',
      'Schedule',
      'Pricing',
      'Materials',
      'Review'
    ];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of 8',
                    style: AppTheme.headline6,
                  ),
                  Text(
                    stepNames[_currentStep],
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.neutral600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category();
      case 1:
        return _buildStep2AISuggestions();
      case 2:
        return _buildStep3Details();
      case 3:
        return _buildStep4Location();
      case 4:
        return _buildStep5Schedule();
      case 5:
        return _buildStep6Pricing();
      case 6:
        return _buildStep7Materials();
      case 7:
        return _buildStep8Review();
      default:
        return Container();
    }
  }

  Widget _buildStep1Category() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What Will You Teach?', style: AppTheme.headline3),
                    Text(
                      'Select your category to get AI-powered suggestions',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Show coach's existing specializations if available
          if (_coachProfile != null && _coachProfile!.specializations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.successColor),
                      const SizedBox(width: 12),
                      Text(
                        'Your Specializations',
                        style: AppTheme.headline6.copyWith(color: AppTheme.successColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _coachProfile!.specializations.map((spec) {
                      return ActionChip(
                        label: Text(spec),
                        onPressed: () {
                          setState(() {
                            _selectedSpecialization = spec;
                            // Auto-select category based on specialization
                            _autoSelectCategory(spec);
                          });
                        },
                        backgroundColor: AppTheme.successColor.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          // Category Selection
          Text('Main Category *', style: AppTheme.headline5),
          const SizedBox(height: 16),
          ...CoachingCategories.all.map((category) {
            final isSelected = _selectedCategory == category;
            return _buildCategoryCard(category, isSelected);
          }),
          
          // Specialization (if category selected)
          if (_selectedCategory != null) ...[
            const SizedBox(height: 32),
            Text('Specific Specialization *', style: AppTheme.headline5),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (CoachingCategories.specializations[_selectedCategory] ?? [])
                  .map((spec) {
                final isSelected = _selectedSpecialization == spec;
                return FilterChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedSpecialization = selected ? spec : null);
                  },
                  selectedColor: AppTheme.accentColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.accentColor,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _autoSelectCategory(String specialization) {
    for (var category in CoachingCategories.all) {
      final specs = CoachingCategories.specializations[category] ?? [];
      if (specs.contains(specialization)) {
        setState(() => _selectedCategory = category);
        break;
      }
    }
  }

  Widget _buildCategoryCard(String category, bool isSelected) {
    IconData icon;
    switch (category) {
      case 'Sports & Fitness':
        icon = Icons.sports_soccer;
        break;
      case 'Music':
        icon = Icons.music_note;
        break;
      case 'Academic':
        icon = Icons.school;
        break;
      case 'Arts & Creativity':
        icon = Icons.palette;
        break;
      case 'Life Skills':
        icon = Icons.psychology;
        break;
      default:
        icon = Icons.category;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : AppTheme.neutral200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor
                : AppTheme.neutral200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : AppTheme.neutral600),
        ),
        title: Text(
          category,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : AppTheme.neutral900,
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
            : null,
        onTap: () => setState(() {
          _selectedCategory = category;
          _selectedSpecialization = null; // Reset specialization
        }),
      ),
    );
  }

  Widget _buildStep2AISuggestions() {
    if (_selectedSpecialization == null) {
      return Center(
        child: Text('Please select a specialization first'),
      );
    }
    
    final suggestions = AIClassSuggestionsService.getSuggestions(_selectedSpecialization!);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI-Powered Suggestions', style: AppTheme.headline3),
                    Text(
                      'Based on your ${_selectedSpecialization} expertise',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          if (suggestions.isNotEmpty) ...[
            Text(
              '⭐ Recommended Classes for ${_selectedSpecialization} Coaches',
              style: AppTheme.headline5.copyWith(color: Colors.purple),
            ),
            const SizedBox(height: 16),
            
            ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
            
            const SizedBox(height: 24),
          ],
          
          // Custom Option
          Card(
            color: AppTheme.neutral50,
            child: InkWell(
              onTap: () => setState(() {
                _selectedTemplate = null;
                _useCustom = true;
              }),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Custom Class',
                            style: AppTheme.headline6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start from scratch with your own details',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _useCustom ? Icons.check_circle : Icons.arrow_forward,
                      color: _useCustom ? AppTheme.successColor : AppTheme.neutral400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ClassSuggestion suggestion) {
    final isSelected = _selectedTemplate == suggestion;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isSelected ? Colors.purple.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.purple : AppTheme.neutral200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() {
          _selectedTemplate = suggestion;
          _useCustom = false;
          _applyTemplate(suggestion);
        }),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(suggestion.title, style: AppTheme.headline6),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildBadge(suggestion.skillLevel, Colors.blue),
                            const SizedBox(width: 8),
                            _buildBadge(
                              'Ages ${suggestion.minAge}-${suggestion.maxAge}',
                              Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildBadge(suggestion.recommendedGroupSize, Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: Colors.purple, size: 32),
                ],
              ),
              const SizedBox(height: 12),
              Text(suggestion.description, style: AppTheme.bodyMedium),
              const SizedBox(height: 16),
              
              // Recommendations
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildRecommendation(
                      Icons.schedule,
                      'Duration',
                      '${suggestion.recommendedDuration} min',
                    ),
                    _buildRecommendation(
                      Icons.repeat,
                      'Frequency',
                      suggestion.recommendedFrequency,
                    ),
                    _buildRecommendation(
                      Icons.attach_money,
                      'Price Range',
                      suggestion.priceRange,
                    ),
                    _buildRecommendation(
                      Icons.trending_up,
                      'Demand',
                      suggestion.popularity,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Market Insight
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.infoColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion.marketInsight,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.infoColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecommendation(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.purple),
          const SizedBox(width: 8),
          Text('$label:', style: AppTheme.bodySmall),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(ClassSuggestion suggestion) {
    setState(() {
      _titleController.text = suggestion.title;
      _descriptionController.text = suggestion.description;
      _minAge = suggestion.minAge;
      _maxAge = suggestion.maxAge;
      _duration = suggestion.recommendedDuration;
      
      // Parse skill level
      switch (suggestion.skillLevel.toLowerCase()) {
        case 'beginner':
          _skillLevel = SkillLevel.beginner;
          break;
        case 'intermediate':
          _skillLevel = SkillLevel.intermediate;
          break;
        case 'advanced':
          _skillLevel = SkillLevel.advanced;
          break;
        case 'all levels':
          _skillLevel = SkillLevel.allLevels;
          break;
      }
      
      // Parse group size
      if (suggestion.recommendedGroupSize.contains('-')) {
        final parts = suggestion.recommendedGroupSize.split('-');
        _minStudents = int.tryParse(parts[0]) ?? 1;
        _maxStudents = int.tryParse(parts[1]) ?? 10;
      } else if (suggestion.recommendedGroupSize == '1') {
        _minStudents = 1;
        _maxStudents = 1;
      }
      
      // Set defaults based on suggestion
      _offersTrial = true;
      _includesProgressReports = suggestion.skillLevel != 'Beginner';
    });
  }

  Widget _buildStep3Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class Details', style: AppTheme.headline3),
            const SizedBox(height: 8),
            Text(
              _selectedTemplate != null 
                  ? 'Review and customize the suggested details'
                  : 'Enter your class information',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 32),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: AppTheme.inputDecoration(
                labelText: 'Class Title *',
                hintText: 'Beginner Tennis for Kids',
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: AppTheme.inputDecoration(
                labelText: 'Description *',
                hintText: 'Describe what students will learn...',
                helperText: 'Be specific and exciting!',
              ),
              maxLines: 4,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            
            // Skill Level
            DropdownButtonFormField<SkillLevel>(
              value: _skillLevel,
              decoration: AppTheme.inputDecoration(
                labelText: 'Skill Level *',
                prefixIcon: const Icon(Icons.bar_chart),
              ),
              items: const [
                DropdownMenuItem(value: SkillLevel.beginner, child: Text('Beginner')),
                DropdownMenuItem(value: SkillLevel.intermediate, child: Text('Intermediate')),
                DropdownMenuItem(value: SkillLevel.advanced, child: Text('Advanced')),
                DropdownMenuItem(value: SkillLevel.expert, child: Text('Expert/Competitive')),
                DropdownMenuItem(value: SkillLevel.allLevels, child: Text('All Levels')),
              ],
              onChanged: (value) => setState(() => _skillLevel = value!),
            ),
            const SizedBox(height: 20),
            
            // Age Range
            Text('Age Range', style: AppTheme.headline6),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minAge.toString(),
                    decoration: AppTheme.inputDecoration(labelText: 'Min Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _minAge = int.tryParse(v) ?? _minAge,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('to', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxAge.toString(),
                    decoration: AppTheme.inputDecoration(labelText: 'Max Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _maxAge = int.tryParse(v) ?? _maxAge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Class Size
            Text('Class Size', style: AppTheme.headline6),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minStudents.toString(),
                    decoration: AppTheme.inputDecoration(labelText: 'Minimum Students'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _minStudents = int.tryParse(v) ?? _minStudents,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxStudents.toString(),
                    decoration: AppTheme.inputDecoration(labelText: 'Maximum Students'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _maxStudents = int.tryParse(v) ?? _maxStudents,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Duration
            Text('Class Duration', style: AppTheme.headline6),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _duration.toDouble(),
                    min: 15,
                    max: 180,
                    divisions: 11,
                    label: '$_duration minutes',
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) => setState(() => _duration = value.toInt()),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_duration min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where Will Classes Be Held?', style: AppTheme.headline3),
          const SizedBox(height: 32),
          
          // Location Options
          _buildLocationOptionCard(
            'At My Location',
            ClassLocationOption.coachLocation,
            Icons.home_work,
            'Students come to your studio/facility',
            _coachProfile?.location?.displayLocation,
          ),
          _buildLocationOptionCard(
            'Travel to Students',
            ClassLocationOption.studentLocation,
            Icons.directions_car,
            'You travel to student\'s home or preferred location',
            null,
          ),
          _buildLocationOptionCard(
            'Online (Virtual)',
            ClassLocationOption.online,
            Icons.video_call,
            'Remote classes via Zoom, Google Meet, etc.',
            null,
          ),
          _buildLocationOptionCard(
            'Outdoor Location',
            ClassLocationOption.outdoor,
            Icons.park,
            'Parks, courts, or outdoor facilities',
            null,
          ),
          
          // Additional Fields Based on Selection
          if (_locationOption == ClassLocationOption.coachLocation) ...[
            const SizedBox(height: 20),
            TextFormField(
              controller: _facilityController,
              decoration: AppTheme.inputDecoration(
                labelText: 'Facility Name (Optional)',
                hintText: 'Austin Tennis Center',
                prefixIcon: const Icon(Icons.business),
                helperText: 'Help students find you',
              ),
            ),
          ],
          
          if (_locationOption == ClassLocationOption.studentLocation) ...[
            const SizedBox(height: 20),
            Text('Travel Details', style: AppTheme.headline6),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _travelFee.toStringAsFixed(2),
              decoration: InputDecoration(
                labelText: 'Travel Fee (per session)',
                prefix: const Text('\$ '),
                prefixIcon: const Icon(Icons.local_gas_station),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.neutral50,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _travelFee = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 12),
            Text('Maximum Travel Distance: $_maxTravelDistance miles', 
                 style: AppTheme.bodyMedium),
            Slider(
              value: _maxTravelDistance.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: '$_maxTravelDistance miles',
              activeColor: AppTheme.primaryColor,
              onChanged: (value) => setState(() => _maxTravelDistance = value.toInt()),
            ),
          ],
          
          if (_locationOption == ClassLocationOption.outdoor) ...[
            const SizedBox(height: 20),
            TextFormField(
              controller: _outdoorLocationController,
              decoration: AppTheme.inputDecoration(
                labelText: 'Outdoor Location',
                hintText: 'City Park Tennis Courts',
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationOptionCard(
    String title,
    ClassLocationOption option,
    IconData icon,
    String description,
    String? subtitle,
  ) {
    final isSelected = _locationOption == option;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : AppTheme.neutral200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<ClassLocationOption>(
        value: option,
        groupValue: _locationOption,
        onChanged: (value) => setState(() => _locationOption = value!),
        title: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.neutral500),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildStep6Pricing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pricing & Trial Options', style: AppTheme.headline3),
          const SizedBox(height: 32),
          
          // Pricing Model
          Text('Pricing Model *', style: AppTheme.headline6),
          const SizedBox(height: 16),
          _buildPricingModelCard(
            'Per Session',
            PricingModel.perSession,
            Icons.receipt,
            'Charge per individual session',
          ),
          _buildPricingModelCard(
            'Monthly Unlimited',
            PricingModel.monthly,
            Icons.calendar_month,
            'Fixed monthly fee for unlimited sessions',
          ),
          _buildPricingModelCard(
            'Package Deal',
            PricingModel.package,
            Icons.redeem,
            'Discounted package (e.g., 10 sessions for \$400)',
          ),
          const SizedBox(height: 24),
          
          // Currency
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Currency>(
                  value: _currency,
                  decoration: AppTheme.inputDecoration(
                    labelText: 'Currency',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  items: const [
                    DropdownMenuItem(value: Currency.usd, child: Text('USD (\$)')),
                    DropdownMenuItem(value: Currency.eur, child: Text('EUR (€)')),
                    DropdownMenuItem(value: Currency.gbp, child: Text('GBP (£)')),
                    DropdownMenuItem(value: Currency.cad, child: Text('CAD (\$)')),
                    DropdownMenuItem(value: Currency.inr, child: Text('INR (₹)')),
                  ],
                  onChanged: (value) => setState(() => _currency = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Price Fields (based on model)
          if (_pricingModel == PricingModel.perSession) ...[
            TextFormField(
              initialValue: _sessionPrice.toStringAsFixed(2),
              decoration: InputDecoration(
                labelText: 'Price Per Session *',
                prefixText: _getCurrencySymbol() + ' ',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.neutral50,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _sessionPrice = double.tryParse(v) ?? _sessionPrice,
            ),
          ],
          
          if (_pricingModel == PricingModel.monthly) ...[
            TextFormField(
              initialValue: _monthlyPrice.toStringAsFixed(2),
              decoration: InputDecoration(
                labelText: 'Monthly Price *',
                prefix: Text(_getCurrencySymbol() + ' '),
                prefixIcon: const Icon(Icons.calendar_today),
                helperText: 'Unlimited sessions per month',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.neutral50,
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _monthlyPrice = double.tryParse(v) ?? _monthlyPrice,
            ),
          ],
          
          if (_pricingModel == PricingModel.package) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _packageSessions.toString(),
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Sessions in Package',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _packageSessions = int.tryParse(v) ?? _packageSessions,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _packagePrice.toStringAsFixed(2),
                    decoration: InputDecoration(
                      labelText: 'Package Price',
                      prefix: Text(_getCurrencySymbol() + ' '),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      filled: true,
                      fillColor: AppTheme.neutral50,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _packagePrice = double.tryParse(v) ?? _packagePrice,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          
          // Free Trial
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offer Free Trial?',
                            style: AppTheme.headline6.copyWith(color: AppTheme.successColor),
                          ),
                          Text(
                            'Trials help attract new students!',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _offersTrial,
                      onChanged: (value) => setState(() => _offersTrial = value),
                      activeColor: AppTheme.successColor,
                    ),
                  ],
                ),
                if (_offersTrial) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                    child: TextFormField(
                      initialValue: _trialPrice.toStringAsFixed(2),
                      decoration: InputDecoration(
                        labelText: 'Trial Price',
                        prefix: Text(_getCurrencySymbol() + ' '),
                        helperText: '0 for free trial',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        filled: true,
                        fillColor: AppTheme.neutral50,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _trialPrice = double.tryParse(v) ?? 0,
                    ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _trialDuration,
                          decoration: AppTheme.inputDecoration(
                            labelText: 'Duration',
                          ),
                          items: const [
                            DropdownMenuItem(value: 15, child: Text('15 min')),
                            DropdownMenuItem(value: 30, child: Text('30 min')),
                            DropdownMenuItem(value: 45, child: Text('45 min')),
                            DropdownMenuItem(value: 60, child: Text('60 min')),
                          ],
                          onChanged: (value) => setState(() => _trialDuration = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingModelCard(
    String title,
    PricingModel model,
    IconData icon,
    String description,
  ) {
    final isSelected = _pricingModel == model;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.accentColor.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.accentColor : AppTheme.neutral200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<PricingModel>(
        value: model,
        groupValue: _pricingModel,
        onChanged: (value) => setState(() => _pricingModel = value!),
        title: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.accentColor : AppTheme.neutral500),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        subtitle: Text(description),
        activeColor: AppTheme.accentColor,
      ),
    );
  }

  String _getCurrencySymbol() {
    switch (_currency) {
      case Currency.usd:
      case Currency.cad:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
      case Currency.inr:
        return '₹';
      case Currency.aud:
        return 'A\$';
      default:
        return '\$';
    }
  }

  Widget _buildStep7Materials() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Materials & Policies', style: AppTheme.headline3),
          const SizedBox(height: 32),
          
          // Materials to Bring
          _buildListSection(
            'What Should Students Bring?',
            _materials,
            'Add material',
            Icons.backpack,
            'e.g., Tennis racket, Water bottle, Athletic shoes',
          ),
          const SizedBox(height: 24),
          
          // Prerequisites
          _buildListSection(
            'Prerequisites (if any)',
            _prerequisites,
            'Add prerequisite',
            Icons.check_circle_outline,
            'e.g., Basic knowledge of musical notes, or "None - beginners welcome"',
          ),
          const SizedBox(height: 32),
          
          // What's Included
          Text('What\'s Included in Your Class?', style: AppTheme.headline6),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _includesProgressReports,
            onChanged: (v) => setState(() => _includesProgressReports = v!),
            title: const Text('Progress Reports'),
            subtitle: const Text('Regular updates on student progress'),
          ),
          CheckboxListTile(
            value: _includesHomework,
            onChanged: (v) => setState(() => _includesHomework = v!),
            title: const Text('Practice Homework'),
            subtitle: const Text('Assignments between sessions'),
          ),
          CheckboxListTile(
            value: _includesCertificate,
            onChanged: (v) => setState(() => _includesCertificate = v!),
            title: const Text('Certificate of Completion'),
            subtitle: const Text('Award certificate at end of program'),
          ),
          CheckboxListTile(
            value: _includesRecordings,
            onChanged: (v) => setState(() => _includesRecordings = v!),
            title: const Text('Session Recordings'),
            subtitle: const Text('Video recordings for students to review'),
          ),
          const SizedBox(height: 32),
          
          // Cancellation Policy
          Text('Cancellation Policy', style: AppTheme.headline6),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _cancellationHours,
                  decoration: AppTheme.inputDecoration(
                    labelText: 'Notice Required',
                  ),
                  items: const [
                    DropdownMenuItem(value: 6, child: Text('6 hours')),
                    DropdownMenuItem(value: 12, child: Text('12 hours')),
                    DropdownMenuItem(value: 24, child: Text('24 hours')),
                    DropdownMenuItem(value: 48, child: Text('48 hours')),
                    DropdownMenuItem(value: 72, child: Text('3 days')),
                  ],
                  onChanged: (value) => setState(() => _cancellationHours = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _cancellationFeePercent.toStringAsFixed(0),
                  decoration: InputDecoration(
                    labelText: 'Fee (%)',
                    suffix: const Text('%'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppTheme.neutral50,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _cancellationFeePercent = double.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> list,
    String buttonLabel,
    IconData icon,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(title, style: AppTheme.headline6),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Text(hint, style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral500)),
        ...list.asMap().entries.map((entry) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(entry.value),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => list.removeAt(entry.key)),
            ),
          ),
        )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showAddItemDialog(title, list, hint),
          icon: const Icon(Icons.add),
          label: Text(buttonLabel),
        ),
      ],
    );
  }

  void _showAddItemDialog(String title, List<String> list, String hint) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => list.add(controller.text.trim()));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Schedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule Your Class', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Set up when your class meets',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Recurring vs One-Time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class Type', style: AppTheme.headline6),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Recurring'), icon: Icon(Icons.repeat)),
                      ButtonSegment(value: false, label: Text('One-Time'), icon: Icon(Icons.event)),
                    ],
                    selected: {_isRecurring},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() => _isRecurring = selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Start Date
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
              title: const Text('Start Date'),
              subtitle: Text(
                '${_startDate.month}/${_startDate.day}/${_startDate.year}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Time Range
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class Time', style: AppTheme.headline6),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (time != null) {
                              setState(() => _startTime = time);
                            }
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            'Start: ${_startTime.format(context)}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (time != null) {
                              setState(() => _endTime = time);
                            }
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            'End: ${_endTime.format(context)}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${_calculateDuration()} minutes',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Recurring Options
          if (_isRecurring) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recurring Pattern', style: AppTheme.headline6),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _recurringPattern,
                      decoration: const InputDecoration(
                        labelText: 'Repeat',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'weekly', child: Text('Every week')),
                        DropdownMenuItem(value: 'biweekly', child: Text('Every 2 weeks')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _recurringPattern = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Days of Week Selection
                    if (_recurringPattern == 'weekly' || _recurringPattern == 'biweekly') ...[
                      Text('Meets on:', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
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
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Series End
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Series Duration', style: AppTheme.headline6),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _hasEndDate,
                      onChanged: (v) => setState(() => _hasEndDate = v),
                      title: const Text('Set end date'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_hasEndDate) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _seriesEndDate ?? _startDate.add(const Duration(days: 60)),
                            firstDate: _startDate.add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _seriesEndDate = date);
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: Text(
                          _seriesEndDate != null
                              ? 'Ends: ${_seriesEndDate!.month}/${_seriesEndDate!.day}/${_seriesEndDate!.year}'
                              : 'Select end date',
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _numberOfSessions.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Number of Sessions',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_list_numbered),
                          suffix: Text('sessions'),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final num = int.tryParse(value);
                          if (num != null && num > 0) {
                            setState(() => _numberOfSessions = num);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // Public/Private Toggle
          Card(
            child: SwitchListTile(
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              title: const Text('Make class public'),
              subtitle: Text(
                _isPublic 
                    ? 'Visible in marketplace for parents to discover'
                    : 'Private - only you can invite students',
                style: AppTheme.bodySmall,
              ),
              secondary: Icon(
                _isPublic ? Icons.public : Icons.lock,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          
          // Schedule Summary
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('Schedule Summary', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_getScheduleSummary(), style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
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
          _selectedWeekDays.sort();
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  int _calculateDuration() {
    final start = _startTime.hour * 60 + _startTime.minute;
    final end = _endTime.hour * 60 + _endTime.minute;
    return end - start;
  }

  String _getScheduleSummary() {
    if (!_isRecurring) {
      return 'One-time class on ${_startDate.month}/${_startDate.day}/${_startDate.year} from ${_startTime.format(context)} to ${_endTime.format(context)}';
    }
    
    String pattern = _recurringPattern == 'weekly' ? 'every week' : 
                    _recurringPattern == 'biweekly' ? 'every 2 weeks' : 'monthly';
    String days = _selectedWeekDays.isEmpty ? 'no days selected' : _selectedWeekDays.map((d) => 
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]
    ).join(', ');
    
    String duration = _hasEndDate && _seriesEndDate != null
        ? 'until ${_seriesEndDate!.month}/${_seriesEndDate!.day}/${_seriesEndDate!.year}'
        : 'for $_numberOfSessions sessions';
    
    return 'Meets $pattern on $days from ${_startTime.format(context)} to ${_endTime.format(context)}, starting ${_startDate.month}/${_startDate.day}/${_startDate.year} $duration.';
  }

  Widget _buildStep8Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Publish', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Everything looks good? Let\'s publish your class!',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Class Preview Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text,
                  style: AppTheme.headline4.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedSpecialization ?? 'Class',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _buildReviewRow(Icons.bar_chart, 'Level', _skillLevel.toString().split('.').last),
                _buildReviewRow(Icons.child_care, 'Ages', '$_minAge - $_maxAge years'),
                _buildReviewRow(Icons.groups, 'Size', '$_minStudents - $_maxStudents students'),
                _buildReviewRow(Icons.schedule, 'Duration', '$_duration minutes'),
                _buildReviewRow(Icons.attach_money, 'Price', _getPriceDisplay()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Visibility
          Text('Class Visibility', style: AppTheme.headline6),
          const SizedBox(height: 16),
          RadioListTile<bool>(
            value: true,
            groupValue: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value!),
            title: const Text('Public'),
            subtitle: const Text('Visible in marketplace, anyone can enroll'),
            activeColor: AppTheme.successColor,
          ),
          RadioListTile<bool>(
            value: false,
            groupValue: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value!),
            title: const Text('Private'),
            subtitle: const Text('Invitation only, not visible in marketplace'),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getPriceDisplay() {
    final symbol = _getCurrencySymbol();
    switch (_pricingModel) {
      case PricingModel.perSession:
        return '$symbol${_sessionPrice.toStringAsFixed(0)}/session';
      case PricingModel.monthly:
        return '$symbol${_monthlyPrice.toStringAsFixed(0)}/month';
      case PricingModel.package:
        return '$symbol${_packagePrice.toStringAsFixed(0)} for $_packageSessions sessions';
      default:
        return '$symbol${_sessionPrice.toStringAsFixed(0)}';
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _currentStep == 7 ? _publishClass : _nextStep,
              icon: Icon(_currentStep == 7 ? Icons.publish : Icons.arrow_forward),
              label: Text(_currentStep == 7 ? 'Publish Class' : 'Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 7 
                    ? AppTheme.successColor 
                    : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Validation
    if (_currentStep == 0 && _selectedSpecialization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specialization')),
      );
      return;
    }
    
    if (_currentStep == 1 && _selectedTemplate == null && !_useCustom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a template or choose custom')),
      );
      return;
    }
    
    if (_currentStep == 2 && _formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() => _currentStep++);
  }

  Future<void> _publishClass() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
      
      final now = DateTime.now();
      
      // Create proper start and end DateTime from our scheduling fields
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      
      final endDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _endTime.hour,
        _endTime.minute,
      );
      
      final durationMinutes = _calculateDuration();
      
      final newClass = Class(
        id: widget.existingClass?.id ?? 'class_${now.millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        coachId: authProvider.currentUser?.id ?? '',
        type: _isRecurring 
            ? (_recurringPattern == 'monthly' ? ClassType.monthly : ClassType.weekly)
            : ClassType.oneTime,
        locationType: _locationOption == ClassLocationOption.online 
            ? LocationType.online 
            : LocationType.inPerson,
        location: _getLocationString(),
        startTime: startDateTime,
        endTime: endDateTime,
        durationMinutes: durationMinutes,
        price: _sessionPrice,
        currency: _currency,
        maxStudents: _maxStudents,
        enrolledStudentIds: widget.existingClass?.enrolledStudentIds ?? [],
        status: ClassStatus.scheduled,
        createdAt: widget.existingClass?.createdAt ?? now,
        updatedAt: now,
        category: _selectedCategory,
        subcategory: _selectedSpecialization,
        tags: _materials + _prerequisites,
        isPublic: _isPublic,
        isGroupClass: _maxStudents > 1,
        paymentSchedule: _pricingModel.toString().split('.').last,
        makeUpClassesAllowed: true,
        // v3.0 fields
        skillLevel: _skillLevel,
        minAge: _minAge,
        maxAge: _maxAge,
        minStudents: _minStudents,
        currentEnrollment: widget.existingClass?.currentEnrollment ?? 0,
        locationOption: _locationOption,
        facilityName: _facilityController.text.trim(),
        outdoorLocation: _outdoorLocationController.text.trim(),
        travelFee: _travelFee,
        maxTravelDistance: _maxTravelDistance,
        pricingModel: _pricingModel,
        monthlyPrice: _monthlyPrice,
        packagePrice: _packagePrice,
        packageSessions: _packageSessions,
        offersTrial: _offersTrial,
        trialPrice: _trialPrice,
        trialDuration: _trialDuration,
        materials: _materials,
        prerequisites: _prerequisites,
        includesProgressReports: _includesProgressReports,
        includesHomework: _includesHomework,
        includesCertificate: _includesCertificate,
        includesRecordings: _includesRecordings,
        cancellationHoursNotice: _cancellationHours,
        cancellationFeePercent: _cancellationFeePercent,
        recurringWeekDays: _selectedWeekDays,
      );

      if (widget.existingClass == null) {
        classesProvider.addClass(newClass);
      } else {
        classesProvider.updateClass(newClass);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Class published successfully!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        context.go('/coach-dashboard');
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
    }
  }

  String _getLocationString() {
    switch (_locationOption) {
      case ClassLocationOption.coachLocation:
        return _facilityController.text.isNotEmpty 
            ? _facilityController.text
            : _coachProfile?.location?.displayLocation ?? 'Coach Location';
      case ClassLocationOption.outdoor:
        return _outdoorLocationController.text;
      case ClassLocationOption.online:
        return 'Online';
      default:
        return 'Various Locations';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _facilityController.dispose();
    _outdoorLocationController.dispose();
    super.dispose();
  }
}

