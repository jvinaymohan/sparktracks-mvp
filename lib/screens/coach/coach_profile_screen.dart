import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _specialtiesController = TextEditingController();
  
  int _yearsExperience = 0;
  List<String> _specialties = [];
  List<String> _certifications = [];

  @override
  void initState() {
    super.initState();
    _loadCoachProfile();
  }

  void _loadCoachProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null && user.preferences.isNotEmpty) {
      setState(() {
        _bioController.text = user.preferences['bio'] ?? '';
        _yearsExperience = user.preferences['yearsExperience'] ?? 0;
        _experienceController.text = user.preferences['experience'] ?? '';
        
        if (user.preferences['specialties'] is List) {
          _specialties = List<String>.from(user.preferences['specialties']);
          _specialtiesController.text = _specialties.join(', ');
        }
        
        if (user.preferences['certifications'] is List) {
          _certifications = List<String>.from(user.preferences['certifications']);
          _certificationsController.text = _certifications.join(', ');
        }
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      'Your Coach Profile',
                      style: AppTheme.headline4.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Share your experience and expertise with students',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Bio Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Me',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          hintText: 'Tell students about yourself and your coaching philosophy...',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please add a bio';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Experience Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Experience',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Years of Experience
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Years of Experience: $_yearsExperience',
                                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Slider(
                                  value: _yearsExperience.toDouble(),
                                  min: 0,
                                  max: 50,
                                  divisions: 50,
                                  label: '$_yearsExperience years',
                                  onChanged: (value) {
                                    setState(() {
                                      _yearsExperience = value.toInt();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Background/Experience Details
                      TextFormField(
                        controller: _experienceController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Professional Background',
                          hintText: 'Share your coaching background, achievements, teams coached, etc.',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Certifications
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Certifications & Qualifications',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _certificationsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Certifications',
                          hintText: 'e.g., UEFA B License, NASM CPT, First Aid Certified',
                          helperText: 'Separate multiple certifications with commas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      if (_certifications.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingM),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _certifications.map((cert) => Chip(
                            label: Text(cert),
                            backgroundColor: AppTheme.successColor.withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _certifications.remove(cert);
                                _certificationsController.text = _certifications.join(', ');
                              });
                            },
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Specialties
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specialties & Focus Areas',
                        style: AppTheme.headline6,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      TextFormField(
                        controller: _specialtiesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Specialties',
                          hintText: 'e.g., Youth Development, Skills Training, Game Strategy',
                          helperText: 'Separate multiple specialties with commas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Quick specialty chips
                      Text(
                        'Quick Add:',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Youth Development',
                          'Skills Training',
                          'Game Strategy',
                          'Physical Conditioning',
                          'Mental Coaching',
                          'Nutrition',
                        ].map((specialty) => ActionChip(
                          label: Text(specialty),
                          onPressed: () {
                            if (!_specialties.contains(specialty)) {
                              setState(() {
                                _specialties.add(specialty);
                                _specialtiesController.text = _specialties.join(', ');
                              });
                            }
                          },
                          backgroundColor: _specialties.contains(specialty)
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : AppTheme.neutral100,
                        )).toList(),
                      ),
                      
                      if (_specialties.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingM),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _specialties.map((spec) => Chip(
                            label: Text(spec),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _specialties.remove(spec);
                                _specialtiesController.text = _specialties.join(', ');
                              });
                            },
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        // Parse certifications and specialties
        if (_certificationsController.text.isNotEmpty) {
          _certifications = _certificationsController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        
        if (_specialtiesController.text.isNotEmpty) {
          _specialties = _specialtiesController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        
        // Create updated preferences map
        final updatedPreferences = {
          ...currentUser.preferences,
          'bio': _bioController.text.trim(),
          'yearsExperience': _yearsExperience,
          'experience': _experienceController.text.trim(),
          'certifications': _certifications,
          'specialties': _specialties,
          'profileCompleted': true,
        };
        
        // Update user with new preferences
        final updatedUser = currentUser.copyWith(
          preferences: updatedPreferences,
          updatedAt: DateTime.now(),
        );
        
        // Save to AuthProvider (this persists the data)
        authProvider.setUser(updatedUser);
        
        // Save to Firebase
        try {
          await authProvider.updateUserProfile(updatedUser);
          print('✓ Coach profile saved to Firebase');
        } catch (e) {
          print('Error saving to Firebase: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profile saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate back to dashboard
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go('/coach-dashboard');
            }
          });
        }
      }
    }
  }
}

