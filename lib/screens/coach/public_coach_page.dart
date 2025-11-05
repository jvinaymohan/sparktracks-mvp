import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classes_provider.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

/// Public coach page - shareable webpage showcasing coach profile and classes
class PublicCoachPage extends StatelessWidget {
  final User coach;
  
  const PublicCoachPage({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    // Calculate profile completion
    final completion = _calculateProfileCompletion(coach);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: isMobile ? 250 : 350,
            pinned: true,
            backgroundColor: AppTheme.successColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.successColor,
                      AppTheme.successColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 50 : 70,
                      backgroundColor: Colors.white,
                      child: Text(
                        coach.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: isMobile ? 40 : 56,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      coach.name,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Verified Coach',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareCoachPage(context),
                tooltip: 'Share this page',
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Completion (if viewing own profile)
                    if (completion < 100) _buildProfileCompletion(completion),
                    
                    // Bio Section
                    if (coach.preferences['bio'] != null && coach.preferences['bio'].toString().isNotEmpty) ...[
                      _buildSection(
                        'About Me',
                        Icons.person,
                        Text(
                          coach.preferences['bio'],
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Experience
                    if (coach.preferences['experience'] != null) ...[
                      _buildSection(
                        'Experience',
                        Icons.work,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${coach.preferences['yearsExperience'] ?? 0}+ years',
                                    style: const TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              coach.preferences['experience'],
                              style: const TextStyle(fontSize: 16, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Certifications
                    if (coach.preferences['certifications'] is List &&
                        (coach.preferences['certifications'] as List).isNotEmpty) ...[
                      _buildSection(
                        'Certifications',
                        Icons.verified,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (coach.preferences['certifications'] as List)
                              .map((cert) => Chip(
                                    label: Text(cert.toString()),
                                    backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                                    labelStyle: const TextStyle(color: AppTheme.accentColor),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Specialties
                    if (coach.preferences['specialties'] is List &&
                        (coach.preferences['specialties'] as List).isNotEmpty) ...[
                      _buildSection(
                        'Specialties',
                        Icons.star,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (coach.preferences['specialties'] as List)
                              .map((spec) => Chip(
                                    label: Text(spec.toString()),
                                    backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                                    labelStyle: const TextStyle(color: AppTheme.warningColor),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Public Classes
                    _buildSection(
                      'Available Classes',
                      Icons.class_,
                      Consumer<ClassesProvider>(
                        builder: (context, classesProvider, _) {
                          final publicClasses = classesProvider.classes
                              .where((c) => c.coachId == coach.id && c.isPublic)
                              .toList();
                          
                          if (publicClasses.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.neutral100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  children: const [
                                    Icon(Icons.class_, size: 48, color: AppTheme.neutral400),
                                    SizedBox(height: 12),
                                    Text('No public classes yet'),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return Column(
                            children: publicClasses.map((classItem) {
                              return _buildClassCard(context, classItem);
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Contact CTA
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Interested in my classes?',
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _contactCoach(context),
                            icon: const Icon(Icons.mail_outline),
                            label: const Text('Contact Me'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  int _calculateProfileCompletion(User coach) {
    int completed = 0;
    int total = 5;
    
    if (coach.preferences['bio'] != null && coach.preferences['bio'].toString().isNotEmpty) completed++;
    if (coach.preferences['experience'] != null && coach.preferences['experience'].toString().isNotEmpty) completed++;
    if (coach.preferences['yearsExperience'] != null && coach.preferences['yearsExperience'] > 0) completed++;
    if (coach.preferences['certifications'] is List && (coach.preferences['certifications'] as List).isNotEmpty) completed++;
    if (coach.preferences['specialties'] is List && (coach.preferences['specialties'] as List).isNotEmpty) completed++;
    
    return ((completed / total) * 100).round();
  }

  Widget _buildProfileCompletion(int completion) {
    return Card(
      color: AppTheme.warningColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppTheme.warningColor),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: completion / 100,
                minHeight: 10,
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
                  : '✓ Profile complete! Looking great!',
              style: TextStyle(
                fontSize: 14,
                color: completion < 100 ? AppTheme.warningColor : AppTheme.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.successColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, Class classItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () {
          // Show class detail dialog or navigate
          _showClassDetail(context, classItem);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      classItem.locationType == LocationType.online
                          ? Icons.computer
                          : Icons.location_on,
                      color: AppTheme.successColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildClassBadge(
                              classItem.type == ClassType.weekly
                                  ? 'Weekly'
                                  : classItem.type == ClassType.monthly
                                      ? 'Monthly'
                                      : 'One-Time',
                              AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            _buildClassBadge(
                              classItem.isGroupClass ? 'Group' : '1-on-1',
                              AppTheme.accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_getCurrencySymbol(classItem.currency)}${classItem.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Text(
                        'per ${classItem.paymentSchedule.replaceAll('_', ' ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                classItem.description,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.neutral700,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    '${classItem.durationMinutes} min',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.people,
                    '${classItem.enrolledStudentIds.length}/${classItem.maxStudents} enrolled',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    classItem.locationType == LocationType.online
                        ? Icons.computer
                        : Icons.location_on,
                    classItem.locationType == LocationType.online ? 'Online' : 'In-Person',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _enrollInClass(context, classItem),
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Enroll Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.neutral600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.neutral700,
          ),
        ),
      ],
    );
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

  void _shareCoachPage(BuildContext context) {
    final link = 'https://sparktracks-mvp.web.app/coach/${coach.id}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Profile link copied! Share it with parents.'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClassDetail(BuildContext context, Class classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classItem.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(classItem.description),
              const SizedBox(height: 16),
              _buildDetailRow('Duration', '${classItem.durationMinutes} minutes'),
              _buildDetailRow('Price', '${_getCurrencySymbol(classItem.currency)}${classItem.price}'),
              _buildDetailRow('Type', classItem.isGroupClass ? 'Group Class' : 'Individual'),
              _buildDetailRow('Location', classItem.locationType == LocationType.online ? 'Online' : classItem.location ?? 'TBD'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _enrollInClass(context, classItem);
            },
            child: const Text('Enroll Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _enrollInClass(BuildContext context, Class classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enroll in Class'),
        content: const Text(
          'Please sign up or login to Sparktracks to enroll in this class!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/register');
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  void _contactCoach(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.mail, color: AppTheme.successColor),
            SizedBox(width: 12),
            Text('Contact Coach'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sign up to send a message to this coach!'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.go('/register');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Create Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

