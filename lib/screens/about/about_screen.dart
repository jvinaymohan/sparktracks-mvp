import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Sparktracks'),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About Sparktracks',
                    style: AppTheme.headline2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Transforming how families manage activities, tasks, and learning',
                    style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Origin Story
            Container(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Our Story', style: AppTheme.headline3),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Built by a Father for His Child',
                                  style: AppTheme.headline5.copyWith(color: AppTheme.primaryColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sparktracks was created by Vinay Jonnakuti, a parent who wanted a better way to manage his child\'s activities, tasks, and learning journey.',
                                  style: AppTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'What started as a personal solution has evolved into a comprehensive platform that can help families and coaches around the world.',
                      style: AppTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Today, Sparktracks empowers parents to track their children\'s progress, helps kids stay motivated with rewards, and gives coaches powerful tools to manage their teaching business.',
                      style: AppTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            
            // Mission & Vision
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              color: AppTheme.neutral50,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Text('Our Mission', style: AppTheme.headline3),
                    const SizedBox(height: 24),
                    
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildMissionCard(
                          icon: Icons.family_restroom,
                          title: 'Support Families',
                          description: 'Help parents manage their children\'s activities and track progress with ease',
                          color: AppTheme.primaryColor,
                        ),
                        _buildMissionCard(
                          icon: Icons.emoji_events,
                          title: 'Motivate Children',
                          description: 'Make learning fun with rewards, achievements, and visual progress tracking',
                          color: AppTheme.accentColor,
                        ),
                        _buildMissionCard(
                          icon: Icons.school,
                          title: 'Empower Coaches',
                          description: 'Provide coaches with business tools to manage classes, students, and finances',
                          color: AppTheme.successColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Features
            Container(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Text('Platform Features', style: AppTheme.headline3),
                    const SizedBox(height: 16),
                    Text(
                      'Everything you need in one integrated platform',
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.neutral600),
                    ),
                    const SizedBox(height: 40),
                    
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _buildFeatureItem(Icons.check_circle, 'Task Management'),
                        _buildFeatureItem(Icons.calendar_today, 'Class Scheduling'),
                        _buildFeatureItem(Icons.trending_up, 'Progress Tracking'),
                        _buildFeatureItem(Icons.emoji_events, 'Rewards & Achievements'),
                        _buildFeatureItem(Icons.payment, 'Payment Management'),
                        _buildFeatureItem(Icons.groups, 'Student Grouping'),
                        _buildFeatureItem(Icons.analytics, 'Financial Dashboard'),
                        _buildFeatureItem(Icons.chat, 'Communication Tools'),
                        _buildFeatureItem(Icons.public, 'Public Coach Profiles'),
                        _buildFeatureItem(Icons.search, 'Marketplace Discovery'),
                        _buildFeatureItem(Icons.phonelink, 'Mobile Optimized'),
                        _buildFeatureItem(Icons.security, 'Privacy & Security'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Browse Classes Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 24),
                    Text('Browse Classes', style: AppTheme.headline3),
                    const SizedBox(height: 16),
                    Text(
                      'Discover amazing coaches and classes in your area',
                      style: AppTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/browse-classes'),
                      icon: const Icon(Icons.explore),
                      label: const Text('Explore Classes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Creator Section
            Container(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Text('About the Creator', style: AppTheme.headline3),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.shadowMedium,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              'VJ',
                              style: AppTheme.headline2.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Vinay Jonnakuti',
                            style: AppTheme.headline4,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Creator & Developer',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '"As a parent, I built Sparktracks to help manage my child\'s activities and growth. I hope it can help your family too."',
                            style: AppTheme.bodyLarge.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.neutral700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // CTA Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                children: [
                  Text(
                    'Ready to Get Started?',
                    style: AppTheme.headline3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join families and coaches using Sparktracks today',
                    style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Sign Up Free'),
                      ),
                      OutlinedButton(
                        onPressed: () => context.go('/browse-classes'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Browse Classes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.neutral900,
              child: Column(
                children: [
                  Text(
                    '© 2025 Sparktracks. Created by Vinay Jonnakuti.',
                    style: AppTheme.bodySmall.copyWith(color: Colors.white.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => context.go('/privacy'),
                        child: Text('Privacy', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      ),
                      TextButton(
                        onPressed: () => context.go('/terms'),
                        child: Text('Terms', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      ),
                      TextButton(
                        onPressed: () => context.go('/about'),
                        child: Text('About', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.headline6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.successColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

