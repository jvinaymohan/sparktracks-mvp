import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/coach_profile_model.dart';
import '../../models/class_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/ai_class_suggestions_service.dart';
import '../../utils/app_theme.dart';
import 'package:go_router/go_router.dart';

/// Quick Start Coach Wizard - Get online in 5 minutes!
/// Simplified 3-step onboarding for coaches who want to start fast
class QuickStartCoachWizard extends StatefulWidget {
  const QuickStartCoachWizard({Key? key}) : super(key: key);

  @override
  State<QuickStartCoachWizard> createState() => _QuickStartCoachWizardState();
}

class _QuickStartCoachWizardState extends State<QuickStartCoachWizard> {
  int _currentStep = 0;
  
  // Step 1: Quick Info
  String? _selectedCategory;
  List<String> _selectedSpecializations = [];
  final _headlineController = TextEditingController();
  
  // Step 2: Location
  final _cityController = TextEditingController();
  String _country = 'United States';
  String? _photoUrl;
  
  // Step 3: First Class
  final _classTitle = TextEditingController();
  final _classDescription = TextEditingController();
  double _classPrice = 30.0;
  String _locationType = 'online';
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _cityController.dispose();
    _classTitle.dispose();
    _classDescription.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateStep(_currentStep)) {
        setState(() => _currentStep++);
      }
    } else {
      _completeQuickStart();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_selectedCategory == null) {
          _showError('Please select what you teach');
          return false;
        }
        if (_selectedSpecializations.isEmpty) {
          _showError('Please select at least one specialization');
          return false;
        }
        if (_headlineController.text.trim().isEmpty) {
          _showError('Please add a headline');
          return false;
        }
        return true;
      case 1:
        if (_cityController.text.trim().isEmpty) {
          _showError('Please enter your city');
          return false;
        }
        return true;
      case 2:
        if (_classTitle.text.trim().isEmpty) {
          _showError('Please enter a class title');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final imageService = ImageUploadService();
      final imageUrl = await imageService.pickAndUploadProfilePhoto(userId: userId);

      if (mounted) {
        Navigator.pop(context);
      }

      if (imageUrl != null) {
        setState(() => _photoUrl = imageUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo uploaded!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _completeQuickStart() async {
    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      final userName = authProvider.currentUser?.name ?? '';

      // Create coach profile
      final profile = CoachProfile(
        id: userId,
        name: userName,
        headline: _headlineController.text.trim(),
        bio: 'Experienced ${_selectedSpecializations.join(', ')} instructor. Let\'s achieve your goals together!',
        photoUrl: _photoUrl,
        location: CoachLocation(
          city: _cityController.text.trim(),
          state: '',
          zipCode: '',
          country: _country,
          serviceRadiusMiles: 10,
          travelOptions: [_locationType == 'online' ? 'online' : 'coach_location'],
        ),
        languages: [
          LanguageSkill(language: 'English', proficiency: 'native'),
        ],
        categories: [_selectedCategory!],
        specializations: _selectedSpecializations,
        yearsExperience: 1,
        teachingPhilosophy: 'Student-centered, goal-oriented approach',
        ageGroups: ['children', 'teens', 'adults'],
        skillLevels: ['beginner', 'intermediate', 'advanced'],
        classTypes: ['one_on_one', 'group'],
        certifications: [],
        education: [],
        awards: [],
        galleryUrls: [],
        testimonials: [],
        isActive: true,
        isVerified: false,
        totalStudents: 0,
        totalClasses: 1,
        preferences: {'quickStartCompleted': true},
      );

      await FirestoreService().saveCoachProfile(profile);

      // Create first class
      final classDescription = _classDescription.text.trim().isEmpty
          ? 'Join me for an amazing ${_selectedSpecializations.isNotEmpty ? _selectedSpecializations.first : _selectedCategory} learning experience! Perfect for beginners and those looking to improve their skills.'
          : _classDescription.text.trim();
      
      final now = DateTime.now();
      final defaultStartTime = DateTime(now.year, now.month, now.day, 15, 0); // 3 PM
      final defaultEndTime = DateTime(now.year, now.month, now.day, 16, 0); // 4 PM
      
      final firstClass = Class(
        id: 'class_${DateTime.now().millisecondsSinceEpoch}',
        title: _classTitle.text.trim(),
        description: classDescription,
        coachId: userId,
        category: _selectedCategory,
        type: ClassType.weekly,
        locationType: _locationType == 'online' ? LocationType.online : LocationType.inPerson,
        location: _locationType == 'online' ? 'Online' : _cityController.text.trim(),
        price: _classPrice,
        currency: Currency.usd,
        startTime: defaultStartTime,
        endTime: defaultEndTime,
        durationMinutes: 60,
        skillLevel: SkillLevel.beginner,
        isGroupClass: true,
        maxStudents: 10,
        status: ClassStatus.scheduled,
        isPublic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService().addClass(firstClass);

      // Mark profile setup as complete
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'preferences.hasSeenWelcome': true,
        'preferences.profileSetupComplete': true,
        'preferences.quickStartUsed': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Show success and navigate to dashboard
        _showSuccessDialog(userId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String coachId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('You\'re Live! 🎉'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your profile and class are now public!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ Profile created', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Text('✅ First class published', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Text('✅ Ready for students!', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'What\'s next?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• Complete your full profile (add bio, certifications, gallery)'),
            const Text('• Add more classes'),
            const Text('• Share your profile link with parents'),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/coach/$coachId');
            },
            child: const Text('View Public Profile'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/coach-dashboard');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Start - Get Online in 5 Minutes!'),
        backgroundColor: AppTheme.successColor,
        actions: [
          TextButton(
            onPressed: () {
              // Option to use full wizard instead
              context.go('/coach-dashboard');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Use Full Setup'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: AppTheme.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
          ),
          
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.successColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(
                  'Step ${_currentStep + 1} of 3 • ~${3 - _currentStep} min remaining',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1QuickInfo(),
                _buildStep2Location(),
                _buildStep3FirstClass(),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _nextStep,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_currentStep == 2 ? Icons.check : Icons.arrow_forward),
                  label: Text(_isSubmitting
                      ? 'Publishing...'
                      : _currentStep == 2
                          ? 'Publish & Go Live!'
                          : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1QuickInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What Do You Teach?', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Select your main category - you can add more later',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),

          // Category Selection
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: CoachingCategories.all.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                    _selectedSpecializations.clear();
                    
                    // Auto-generate headline
                    if (selected) {
                      _headlineController.text = '$category Instructor';
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.neutral700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          if (_selectedCategory != null) ...[
            const SizedBox(height: 32),
            Text('Your Specializations', style: AppTheme.headline5),
            const SizedBox(height: 12),
            Text(
              'Select what you specialize in',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (CoachingCategories.specializations[_selectedCategory] ?? [])
                  .map((spec) {
                final isSelected = _selectedSpecializations.contains(spec);
                return FilterChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSpecializations.add(spec);
                      } else {
                        _selectedSpecializations.remove(spec);
                      }
                    });
                  },
                  selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.accentColor,
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Headline
          Text('Your Headline', style: AppTheme.headline5),
          const SizedBox(height: 12),
          TextField(
            controller: _headlineController,
            decoration: const InputDecoration(
              hintText: 'e.g., Expert Chess Coach | 10+ years experience',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where Are You Based?', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Help parents find you',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),

          // City
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              hintText: 'Enter your city',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          const SizedBox(height: 20),

          // Country (simplified)
          DropdownButtonFormField<String>(
            value: _country,
            decoration: const InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.public),
            ),
            items: const [
              DropdownMenuItem(value: 'United States', child: Text('United States')),
              DropdownMenuItem(value: 'United Kingdom', child: Text('United Kingdom')),
              DropdownMenuItem(value: 'Canada', child: Text('Canada')),
              DropdownMenuItem(value: 'Australia', child: Text('Australia')),
              DropdownMenuItem(value: 'India', child: Text('India')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() => _country = value ?? 'United States');
            },
          ),
          const SizedBox(height: 32),

          // Profile Photo (Optional)
          Text('Profile Photo (Optional)', style: AppTheme.headline5),
          const SizedBox(height: 12),
          Text(
            'Add a photo to build trust - or skip for now',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 16),
          
          Center(
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                    image: _photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: AppTheme.neutral400)
                      : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _uploadPhoto,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(_photoUrl == null ? 'Add Photo' : 'Change Photo'),
                ),
                const SizedBox(height: 8),
                if (_photoUrl == null)
                  TextButton(
                    onPressed: _nextStep,
                    child: const Text('Skip for now'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3FirstClass() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Your First Class!', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'List a class so parents can find and book you',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),

          // AI Suggested Title
          if (_selectedCategory != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.1),
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 AI Suggestion',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on "$_selectedCategory", we suggest:',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Class Title
          TextField(
            controller: _classTitle,
            decoration: InputDecoration(
              labelText: 'Class Title',
              hintText: 'e.g., Beginner ${_selectedSpecializations.isNotEmpty ? _selectedSpecializations.first : 'Lessons'}',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.class_),
            ),
          ),
          const SizedBox(height: 16),

          // Description (optional)
          TextField(
            controller: _classDescription,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'AI will generate one if you skip',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Price
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price per Session', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Slider(
                      value: _classPrice,
                      min: 10,
                      max: 200,
                      divisions: 19,
                      label: '\$${_classPrice.toInt()}',
                      onChanged: (value) {
                        setState(() => _classPrice = value);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '\$${_classPrice.toInt()}/hr',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Location Type
          Text('Where will you teach?', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLocationTypeCard(
                  'online',
                  'Online',
                  Icons.computer,
                  'Virtual classes',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLocationTypeCard(
                  'in_person',
                  'In-Person',
                  Icons.location_on,
                  'At your location',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTypeCard(String value, String title, IconData icon, String subtitle) {
    final isSelected = _locationType == value;
    return InkWell(
      onTap: () => setState(() => _locationType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppTheme.primaryColor : AppTheme.neutral600,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : AppTheme.neutral700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

