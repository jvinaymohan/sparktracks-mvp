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
                        'Current Version: Alpha 1.5',
                        style: AppTheme.headline5.copyWith(color: AppTheme.successColor),
                      ),
                      Text(
                        'Released: November 10, 2025 (Beta Ready!)',
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
                    // Latest Release - Alpha 1.5
                    _buildVersionCard(
                      version: 'Alpha 1.5 - Beta Launch Ready 🎉',
                      date: 'November 10, 2025 (4:00 AM)',
                      status: 'Live Now',
                      statusColor: AppTheme.successColor,
                      features: [
                        '🎯 11 Major Features in One Night:',
                        '',
                        '✅ Enrollment Approval Flow - Coach reviews & approves after payment',
                        '✅ Student Roster Management - Grid view with full student details',
                        '✅ Task Editing - Parents can edit any existing task',
                        '✅ Recurring Task Fix - Choose specific days of week',
                        '✅ Reviews & Ratings System - With coach approval workflow',
                        '✅ Post Updates Feature - Class-level or all-classes option',
                        '✅ Buffer Time Settings - 0/15/30/45 min between classes',
                        '✅ Conflict Detection - Smart scheduling with warnings',
                        '✅ Email Reminders - 24hr + 1hr auto-send via Cloud Functions',
                        '✅ iCal Export - Universal calendar integration (Google, Apple, Outlook)',
                        '✅ UI Integration - Quick action cards in dashboards',
                        '',
                        '📊 Business Deliverables:',
                        '',
                        '✅ Comprehensive Product Roadmap (20 pages)',
                        '✅ Market Analysis - \$57.8B Total Addressable Market',
                        '✅ Financial Projections - \$2.67M revenue by Year 3',
                        '✅ Go-to-Market Strategy - Beta to \$10M in 3 years',
                        '✅ Fundraising Plan - \$250K angel to \$2M seed to \$10M Series A',
                        '✅ Customer Personas - 4 detailed profiles',
                        '✅ Competitive Analysis - Why we win',
                        '✅ Innovation Ideas - 8 breakthrough concepts',
                        '',
                        '🚀 Ready for Beta Launch Next Week!',
                        '📄 80+ pages of documentation created',
                        '💯 99% platform completeness',
                        '⏱️ 7 hours of focused development',
                        '💻 4,500+ lines of code written',
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Previous Release - v1.0.0
                    _buildVersionCard(
                      version: 'v1.0.0 - Production Launch 🚀',
                      date: 'November 8, 2025 (Evening)',
                      status: 'Released',
                      statusColor: AppTheme.successColor,
                      features: [
                        'Timeline & Roadmap page with version history',
                        'Enhanced Browse Classes with dual tabs (Classes & Coaches)',
                        'Location-based search for finding nearby classes',
                        'Admin Portal with auto-user creation',
                        'Consolidated navigation (removed duplicate Marketplace)',
                        'Enhanced filters: Online, In-Person, 1-on-1, Group',
                        'About page with creator story (Vinay Jonnakuti)',
                        'Privacy Policy with security highlights',
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // v0.9.0 - Evening Session
                    _buildVersionCard(
                      version: 'v0.9.0 - Coach Platform Complete',
                      date: 'November 8, 2025 (Afternoon)',
                      status: 'Released',
                      statusColor: AppTheme.primaryColor,
                      features: [
                        'Photo upload system with Firebase Storage integration',
                        'Privacy Policy and Terms of Service pages',
                        'Admin security: Hidden from public, direct URL access only',
                        'Unit tests: 28 comprehensive tests created',
                        'Widget tests for landing screen',
                        'Service tests with mocking framework',
                        'Image upload service with progress tracking',
                        'Firebase Storage security rules',
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // v0.8.0 - Coach Features
                    _buildVersionCard(
                      version: 'v0.8.0 - Coach Business Tools',
                      date: 'November 8, 2025 (Morning)',
                      status: 'Released',
                      statusColor: AppTheme.primaryColor,
                      features: [
                        'Enhanced Coach Profile Wizard (7-step guided setup)',
                        'Intelligent Class Creation with AI-powered templates',
                        'Student Grouping Screen (by skill, age, payment)',
                        'Financial Dashboard for coaches',
                        'Communication Feed for updates and announcements',
                        'Public Coach Pages with shareable URLs',
                        'Share Profile dialog with copy-to-clipboard',
                        'Business and Updates tabs in Coach Dashboard',
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // v0.7.0 - Foundation
                    _buildVersionCard(
                      version: 'v0.7.0 - Core Platform',
                      date: 'November 1-7, 2025',
                      status: 'Released',
                      statusColor: AppTheme.primaryColor,
                      features: [
                        'Parent Dashboard with task management',
                        'Child Dashboard with rewards and achievements',
                        'Coach Dashboard with class management',
                        'Multi-child support for parents',
                        'Task creation, assignment, and tracking',
                        'Rewards and points system',
                        'Class scheduling and calendar',
                        'Enrollment management',
                        'Attendance tracking',
                        'Firebase Authentication and Firestore',
                        'Mobile-responsive design (48dp touch targets)',
                        'Role-based access control',
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

