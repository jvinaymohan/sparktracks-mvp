import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';

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

  int _calculateProfileCompletion() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return 0;
    
    int completed = 0;
    int total = 5;
    
    if (user.preferences['bio'] != null && user.preferences['bio'].toString().isNotEmpty) completed++;
    if (user.preferences['experience'] != null && user.preferences['experience'].toString().isNotEmpty) completed++;
    if (user.preferences['yearsExperience'] != null && user.preferences['yearsExperience'] > 0) completed++;
    if (user.preferences['certifications'] is List && (user.preferences['certifications'] as List).isNotEmpty) completed++;
    if (user.preferences['specialties'] is List && (user.preferences['specialties'] as List).isNotEmpty) completed++;
    
    return ((completed / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final completion = _calculateProfileCompletion();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Profile'),
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save Profile',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProfile(context),
            tooltip: 'Share My Page',
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
              // Profile Completion Card
              Card(
                color: completion == 100 ? AppTheme.successColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            completion == 100 ? Icons.check_circle : Icons.analytics,
                            color: completion == 100 ? AppTheme.successColor : AppTheme.warningColor,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile Completion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$completion%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: completion == 100 ? AppTheme.successColor : AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: completion / 100,
                          minHeight: 12,
                          backgroundColor: AppTheme.neutral200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completion == 100 ? AppTheme.successColor : AppTheme.warningColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        completion < 100
                            ? 'Complete your profile to attract more students!'
                            : '✓ Profile complete! Your page looks amazing!',
                        style: TextStyle(
                          fontSize: 14,
                          color: completion < 100 ? AppTheme.warningColor : AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.successColor,
                      AppTheme.successColor.withOpacity(0.8),
                    ],
                  ),
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
        
        // Update AuthProvider (this persists the data in memory)
        // The user data will be updated
        
        // Save to Firebase via AuthService
        try {
          final authService = AuthService();
          // In production, add updateUserPreferences method to AuthService
          // For now, we use the workaround of updating via Firestore directly
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.id)
              .update({'preferences': updatedPreferences, 'updatedAt': FieldValue.serverTimestamp()});
          
          // Reload user data to reflect changes
          await authProvider.checkAuthStatus();
          
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

  void _shareProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;
    
    final link = 'https://sparktracks-mvp.web.app/coach/${user.id}';
    final message = '🏫 Check out my coaching profile and classes on Sparktracks!\n\n$link\n\nJoin Sparktracks for free and enroll your child in my programs!';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.share, color: AppTheme.successColor),
            SizedBox(width: 12),
            Text('Share Your Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your coach page with parents:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neutral300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.link, size: 18, color: AppTheme.successColor),
                      SizedBox(width: 8),
                      Text('Your Public Page:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    link,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: AppTheme.accentColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Complete your profile to attract more students!',
                      style: TextStyle(fontSize: 12, color: AppTheme.accentColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Share message copied! Paste to share.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Message'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
          ),
        ],
      ),
    );
  }
}

