import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/coach_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

/// Enhanced Coach Profile Setup Wizard (v3.0)
/// Multi-step wizard for complete coach profile creation
class EnhancedCoachProfileWizard extends StatefulWidget {
  final CoachProfile? existingProfile;
  
  const EnhancedCoachProfileWizard({
    super.key,
    this.existingProfile,
  });

  @override
  State<EnhancedCoachProfileWizard> createState() => _EnhancedCoachProfileWizardState();
}

class _EnhancedCoachProfileWizardState extends State<EnhancedCoachProfileWizard> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  String? _photoUrl;
  int? _yearsExperience;
  
  // Step 2: Location
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  String _country = 'United States';
  int _serviceRadius = 10;
  List<String> _travelOptions = ['coach_location'];
  
  // Step 3: Languages
  List<LanguageSkill> _languages = [
    LanguageSkill(language: 'English', proficiency: 'native'),
  ];
  
  // Step 4: Expertise
  List<String> _selectedCategories = [];
  List<String> _selectedSpecializations = [];
  final List<Certification> _certifications = [];
  String? _teachingPhilosophy;
  
  // Step 5: Teaching Preferences
  List<String> _ageGroups = [];
  List<String> _skillLevels = [];
  List<String> _classTypes = [];
  Map<String, bool> _availableDays = {
    'monday': true,
    'tuesday': true,
    'wednesday': true,
    'thursday': true,
    'friday': true,
    'saturday': false,
    'sunday': false,
  };
  
  // Step 6: Media & Marketing
  final List<String> _galleryUrls = [];
  final _websiteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _loadExistingProfile();
    }
  }
  
  void _loadExistingProfile() {
    final profile = widget.existingProfile!;
    _nameController.text = profile.name;
    _headlineController.text = profile.headline ?? '';
    _bioController.text = profile.bio ?? '';
    _photoUrl = profile.photoUrl;
    _yearsExperience = profile.yearsExperience;
    
    if (profile.location != null) {
      _cityController.text = profile.location!.city;
      _stateController.text = profile.location!.state;
      _zipCodeController.text = profile.location!.zipCode ?? '';
      _country = profile.location!.country;
      _serviceRadius = profile.location!.serviceRadiusMiles ?? 10;
      _travelOptions = profile.location!.travelOptions;
    }
    
    _languages = List.from(profile.languages);
    _selectedCategories = List.from(profile.categories);
    _selectedSpecializations = List.from(profile.specializations);
    _teachingPhilosophy = profile.teachingPhilosophy;
    _ageGroups = List.from(profile.ageGroups);
    _skillLevels = List.from(profile.skillLevels);
    _classTypes = List.from(profile.classTypes);
    
    if (profile.availableDays != null) {
      _availableDays = Map.from(profile.availableDays!);
    }
    
    _websiteController.text = profile.website ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Coach Profile'),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Step Content
          Expanded(
            child: _buildCurrentStep(),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / 7;
    
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
              Text(
                'Step ${_currentStep + 1} of 7',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).round()}% Complete',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
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
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2Location();
      case 2:
        return _buildStep3Languages();
      case 3:
        return _buildStep4Expertise();
      case 4:
        return _buildStep5Teaching();
      case 5:
        return _buildStep6Media();
      case 6:
        return _buildStep7Review();
      default:
        return Container();
    }
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Let\'s Start with the Basics', style: AppTheme.headline3),
            const SizedBox(height: 8),
            Text(
              'This information will be visible on your public profile',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 32),
            
            // Profile Photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.neutral200,
                    backgroundImage: _photoUrl != null 
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: _photoUrl == null
                        ? Icon(Icons.person, size: 60, color: AppTheme.neutral400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _uploadPhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: AppTheme.inputDecoration(
                labelText: 'Full Name *',
                hintText: 'Sarah Johnson',
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 20),
            
            // Professional Headline
            TextFormField(
              controller: _headlineController,
              decoration: AppTheme.inputDecoration(
                labelText: 'Professional Headline *',
                hintText: 'Expert Tennis Coach | 15 Years Experience',
                prefixIcon: const Icon(Icons.work),
                helperText: 'This appears at the top of your profile',
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Headline is required' : null,
            ),
            const SizedBox(height: 20),
            
            // Years of Experience
            DropdownButtonFormField<int>(
              value: _yearsExperience,
              decoration: AppTheme.inputDecoration(
                labelText: 'Years of Experience *',
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              items: List.generate(50, (index) => index + 1)
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text('$year ${year == 1 ? 'year' : 'years'}'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _yearsExperience = value),
              validator: (value) =>
                  value == null ? 'Please select experience' : null,
            ),
            const SizedBox(height: 20),
            
            // Bio
            TextFormField(
              controller: _bioController,
              decoration: AppTheme.inputDecoration(
                labelText: 'About You *',
                hintText: 'Tell parents and students about your teaching background, philosophy, and what makes you unique...',
                helperText: 'This is your chance to shine! Be authentic and engaging.',
              ),
              maxLines: 6,
              validator: (value) =>
                  value?.isEmpty == true ? 'Bio is required' : null,
            ),
            const SizedBox(height: 20),
            
            // Tips Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppTheme.infoColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: A great bio includes your teaching style, achievements, and what students can expect from your classes.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.infoColor),
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

  Widget _buildStep2Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where Do You Teach?', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Help parents find you in their area',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // City
          TextFormField(
            controller: _cityController,
            decoration: AppTheme.inputDecoration(
              labelText: 'City *',
              hintText: 'Austin',
              prefixIcon: const Icon(Icons.location_city),
            ),
          ),
          const SizedBox(height: 20),
          
          // State & Zip Code
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _stateController,
                  decoration: AppTheme.inputDecoration(
                    labelText: 'State *',
                    hintText: 'TX',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _zipCodeController,
                  decoration: AppTheme.inputDecoration(
                    labelText: 'Zip Code',
                    hintText: '78701',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Service Radius
          Text('How far will you travel?', style: AppTheme.headline6),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _serviceRadius.toDouble(),
                  min: 0,
                  max: 50,
                  divisions: 10,
                  label: '$_serviceRadius miles',
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) => setState(() => _serviceRadius = value.toInt()),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_serviceRadius miles',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Teaching Location Options
          Text('Where do you offer classes?', style: AppTheme.headline6),
          const SizedBox(height: 12),
          _buildLocationOption(
            'At My Location',
            'coach_location',
            Icons.home,
            'Students come to your studio/facility',
          ),
          _buildLocationOption(
            'Travel to Students',
            'travel_to_student',
            Icons.directions_car,
            'You travel to student\'s location',
          ),
          _buildLocationOption(
            'Online (Virtual)',
            'online',
            Icons.video_call,
            'Remote classes via Zoom, etc.',
          ),
          _buildLocationOption(
            'Outdoor Locations',
            'outdoor',
            Icons.park,
            'Parks, courts, outdoor facilities',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption(String title, String value, IconData icon, String description) {
    final isSelected = _travelOptions.contains(value);
    
    return CheckboxListTile(
      value: isSelected,
      onChanged: (selected) {
        setState(() {
          if (selected == true) {
            _travelOptions.add(value);
          } else {
            _travelOptions.remove(value);
          }
        });
      },
      title: Row(
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.neutral500),
          const SizedBox(width: 12),
          Text(title, style: AppTheme.bodyLarge),
        ],
      ),
      subtitle: Text(description, style: AppTheme.bodySmall),
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildStep3Languages() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Languages You Speak', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Help parents find coaches who speak their language',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Language List
          ..._languages.asMap().entries.map((entry) {
            final index = entry.key;
            final lang = entry.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.language, color: AppTheme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: lang.language,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(),
                        ),
                        items: _getLanguageOptions(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _languages[index] = LanguageSkill(
                                language: value,
                                proficiency: lang.proficiency,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: lang.proficiency,
                        decoration: const InputDecoration(
                          labelText: 'Level',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'native', child: Text('Native')),
                          DropdownMenuItem(value: 'fluent', child: Text('Fluent')),
                          DropdownMenuItem(value: 'conversational', child: Text('Conversational')),
                          DropdownMenuItem(value: 'basic', child: Text('Basic')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _languages[index] = LanguageSkill(
                                language: lang.language,
                                proficiency: value,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    if (_languages.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _languages.removeAt(index)),
                      ),
                  ],
                ),
              ),
            );
          }),
          
          // Add Language Button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _languages.add(LanguageSkill(
                  language: 'Spanish',
                  proficiency: 'conversational',
                ));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Another Language'),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getLanguageOptions() {
    const languages = [
      'English', 'Spanish', 'French', 'Mandarin', 'German', 'Italian',
      'Portuguese', 'Japanese', 'Korean', 'Hindi', 'Arabic', 'Russian',
    ];
    
    return languages
        .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
        .toList();
  }

  Widget _buildStep4Expertise() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Expertise', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'What do you teach? Select all that apply.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Categories
          Text('Main Categories *', style: AppTheme.headline5),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: CoachingCategories.all.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                      // Remove specializations from this category
                      final specs = CoachingCategories.specializations[category] ?? [];
                      _selectedSpecializations.removeWhere((s) => specs.contains(s));
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.neutral700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          
          // Specializations (based on selected categories)
          if (_selectedCategories.isNotEmpty) ...[
            Text('What specifically do you teach? *', style: AppTheme.headline5),
            const SizedBox(height: 16),
            ..._selectedCategories.map((category) {
              final specs = CoachingCategories.specializations[category] ?? [];
              if (specs.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: specs.map((spec) {
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
                        selectedColor: AppTheme.accentColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.accentColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ],
          
          // Teaching Philosophy
          const SizedBox(height: 16),
          Text('Your Teaching Philosophy', style: AppTheme.headline5),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _teachingPhilosophy,
            decoration: AppTheme.inputDecoration(
              hintText: 'Describe your teaching approach and values...',
              helperText: 'Optional, but helps parents understand your style',
            ),
            maxLines: 4,
            onChanged: (value) => _teachingPhilosophy = value,
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Teaching() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teaching Preferences', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Help us match you with the right students',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Age Groups
          Text('What age groups do you teach? *', style: AppTheme.headline6),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildSelectionChip('Kids (5-10)', 'kids_5_10', _ageGroups),
              _buildSelectionChip('Tweens (11-13)', 'tweens_11_13', _ageGroups),
              _buildSelectionChip('Teens (14-17)', 'teens_14_17', _ageGroups),
              _buildSelectionChip('Adults (18+)', 'adults_18+', _ageGroups),
            ],
          ),
          const SizedBox(height: 32),
          
          // Skill Levels
          Text('What skill levels do you teach? *', style: AppTheme.headline6),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildSelectionChip('Beginner', 'beginner', _skillLevels),
              _buildSelectionChip('Intermediate', 'intermediate', _skillLevels),
              _buildSelectionChip('Advanced', 'advanced', _skillLevels),
              _buildSelectionChip('Expert/Competitive', 'expert', _skillLevels),
            ],
          ),
          const SizedBox(height: 32),
          
          // Class Types
          Text('What class formats do you offer? *', style: AppTheme.headline6),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildSelectionChip('Group Classes', 'group', _classTypes),
              _buildSelectionChip('Private 1-on-1', 'individual', _classTypes),
              _buildSelectionChip('Semi-Private (2-3)', 'semi_private', _classTypes),
            ],
          ),
          const SizedBox(height: 32),
          
          // Availability
          Text('When are you typically available?', style: AppTheme.headline6),
          const SizedBox(height: 16),
          ..._availableDays.keys.map((day) {
            return CheckboxListTile(
              value: _availableDays[day],
              onChanged: (value) {
                setState(() => _availableDays[day] = value ?? false);
              },
              title: Text(_capitalize(day)),
              activeColor: AppTheme.primaryColor,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectionChip(String label, String value, List<String> list) {
    final isSelected = list.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            list.add(value);
          } else {
            list.remove(value);
          }
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildStep6Media() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Showcase Your Work', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Photos and media help parents get excited about your classes',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Gallery
          Text('Photo Gallery (Optional)', style: AppTheme.headline6),
          const SizedBox(height: 12),
          Text(
            'Add photos of your classes, facilities, student achievements, etc.',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 16),
          
          // Gallery Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _galleryUrls.length + 1,
            itemBuilder: (context, index) {
              if (index == _galleryUrls.length) {
                // Add Photo Button
                return GestureDetector(
                  onTap: _addGalleryPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neutral300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, 
                            color: AppTheme.neutral400, size: 32),
                        const SizedBox(height: 8),
                        Text('Add Photo', style: AppTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              }
              
              // Gallery Photo
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_galleryUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _galleryUrls.removeAt(index)),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Website
          TextFormField(
            controller: _websiteController,
            decoration: AppTheme.inputDecoration(
              labelText: 'Website (Optional)',
              hintText: 'https://yourwebsite.com',
              prefixIcon: const Icon(Icons.language),
              helperText: 'Your personal website or social media',
            ),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildStep7Review() {
    final completionPercentage = _calculateCompletion();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Your Profile', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'Make sure everything looks great!',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          ),
          const SizedBox(height: 32),
          
          // Completion Indicator
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: completionPercentage >= 80
                  ? AppTheme.secondaryGradient
                  : LinearGradient(colors: [AppTheme.warningColor, AppTheme.warningColor]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      completionPercentage >= 80 ? Icons.check_circle : Icons.info,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Completion',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$completionPercentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                if (completionPercentage < 80) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Complete at least 80% for better visibility!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Summary Cards
          _buildSummaryCard('Basic Info', [
            'Name: ${_nameController.text}',
            'Headline: ${_headlineController.text}',
            'Experience: ${_yearsExperience ?? 0} years',
          ]),
          _buildSummaryCard('Location', [
            'City: ${_cityController.text}, ${_stateController.text}',
            'Service Radius: $_serviceRadius miles',
            'Options: ${_travelOptions.join(', ')}',
          ]),
          _buildSummaryCard('Languages', 
            _languages.map((l) => '${l.language} (${l.proficiency})').toList(),
          ),
          _buildSummaryCard('Expertise', [
            'Categories: ${_selectedCategories.join(', ')}',
            'Specializations: ${_selectedSpecializations.join(', ')}',
          ]),
          _buildSummaryCard('Teaching', [
            'Age Groups: ${_ageGroups.join(', ')}',
            'Skill Levels: ${_skillLevels.join(', ')}',
            'Class Types: ${_classTypes.join(', ')}',
          ]),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                const SizedBox(width: 12),
                Text(title, style: AppTheme.headline6),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: AppTheme.bodyMedium),
            )),
          ],
        ),
      ),
    );
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
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 6 ? _saveProfile : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_currentStep == 6 ? 'Complete Profile' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Validation for required steps
    if (_currentStep == 0 && _formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_currentStep == 3 && _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }
    
    if (_currentStep == 3 && _selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one specialization')),
      );
      return;
    }
    
    if (_currentStep == 4 && _ageGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one age group')),
      );
      return;
    }
    
    setState(() => _currentStep++);
  }

  int _calculateCompletion() {
    int completed = 0;
    int total = 10;

    if (_nameController.text.isNotEmpty) completed++;
    if (_headlineController.text.isNotEmpty) completed++;
    if (_bioController.text.isNotEmpty) completed++;
    if (_cityController.text.isNotEmpty) completed++;
    if (_languages.length >= 1) completed++;
    if (_selectedCategories.isNotEmpty) completed++;
    if (_selectedSpecializations.isNotEmpty) completed++;
    if (_ageGroups.isNotEmpty) completed++;
    if (_skillLevels.isNotEmpty) completed++;
    if (_classTypes.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }

  Future<void> _saveProfile() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      final profile = CoachProfile(
        id: userId,
        name: _nameController.text.trim(),
        headline: _headlineController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: _photoUrl,
        location: CoachLocation(
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          country: _country,
          serviceRadiusMiles: _serviceRadius,
          travelOptions: _travelOptions,
        ),
        languages: _languages,
        categories: _selectedCategories,
        specializations: _selectedSpecializations,
        teachingPhilosophy: _teachingPhilosophy,
        ageGroups: _ageGroups,
        skillLevels: _skillLevels,
        classTypes: _classTypes,
        yearsExperience: _yearsExperience,
        availableDays: _availableDays,
        galleryUrls: _galleryUrls,
        joinedDate: DateTime.now(),
      );
      
      // Save to Firestore
      await FirestoreService().saveCoachProfile(profile);
      
      // Update user preferences
      await authProvider.updateUserPreferences({
        'profileCompleted': true,
        'profileCompletionPercentage': profile.getProfileCompletionPercentage(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to coach dashboard
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

  Future<void> _uploadPhoto() async {
    // TODO: Implement photo upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload coming soon!')),
    );
  }

  Future<void> _addGalleryPhoto() async {
    // TODO: Implement gallery photo upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery upload coming soon!')),
    );
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}

