import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

/// Timeline/Roadmap Screen - Shows version history and upcoming features
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline & Roadmap'),
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
                    Icons.timeline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sparktracks Timeline',
                    style: AppTheme.headline2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our journey of building a better platform for families and coaches',
                    style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Current Version Banner
            Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.successColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Version: v1.0.0',
                        style: AppTheme.headline5.copyWith(color: AppTheme.successColor),
                      ),
                      Text(
                        'Released: November 8, 2025',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Timeline Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Latest Release
                    _buildVersionCard(
                      version: 'v1.0.0',
                      date: 'November 8, 2025',
                      status: 'Released',
                      statusColor: AppTheme.successColor,
                      features: [
                        'Complete coach business platform with 6 integrated features',
                        'Enhanced coach profile wizard (7-step guided setup)',
                        'Intelligent class creation with AI-powered templates',
                        'Student grouping and management tools',
                        'Financial dashboard with revenue tracking',
                        'Communication feed for updates and announcements',
                        'Public coach pages with shareable URLs',
                        'Photo upload system with Firebase Storage',
                        'Public marketplace for browsing classes and coaches',
                        'Location-based class search',
                        'Mobile-optimized design (48dp touch targets)',
                        'Privacy Policy and Terms of Service',
                        'About page with creator story',
                        '28 comprehensive unit and widget tests',
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Coming Soon
                    Text(
                      '🚀 Coming Soon',
                      style: AppTheme.headline3.copyWith(color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildUpcomingCard(
                      version: 'v1.1.0',
                      eta: 'November 2025',
                      features: [
                        'Payment processing with Stripe integration',
                        'Email notifications for tasks and payments',
                        'CSV export for financial reports',
                        'Push notifications (mobile app)',
                        'Enhanced analytics and insights',
                        'Rating and review system for coaches',
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildUpcomingCard(
                      version: 'v1.2.0',
                      eta: 'December 2025',
                      features: [
                        'iOS App Store release',
                        'Android Play Store release',
                        'Video messaging for coaches and students',
                        'Bulk task creation and templates',
                        'Advanced search with more filters',
                        'Goal setting and milestone tracking',
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildUpcomingCard(
                      version: 'v2.0.0',
                      eta: 'Q1 2026',
                      features: [
                        'AI-powered class recommendations',
                        'Real-time class chat',
                        'Video class support',
                        'Parent community forums',
                        'Advanced reporting and exports',
                        'Multi-language support',
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Feedback CTA
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor.withOpacity(0.1),
                            AppTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.feedback, size: 48, color: AppTheme.primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            'Help Shape Our Future',
                            style: AppTheme.headline4,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your feedback drives our development. Tell us what features you\'d like to see next!',
                            style: AppTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/feedback'),
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Share Your Feedback'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard({
    required String version,
    required String date,
    required String status,
    required Color statusColor,
    required List<String> features,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  version,
                  style: AppTheme.headline4.copyWith(color: AppTheme.primaryColor),
                ),
                const Spacer(),
                Text(
                  date,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'What\'s New:',
              style: AppTheme.headline6,
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard({
    required String version,
    required String eta,
    required List<String> features,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.neutral300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.infoColor),
                  ),
                  child: Text(
                    'Planned',
                    style: TextStyle(color: AppTheme.infoColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  version,
                  style: AppTheme.headline5.copyWith(color: AppTheme.primaryColor),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppTheme.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      'ETA: $eta',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Planned Features:',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_forward, color: AppTheme.infoColor, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

