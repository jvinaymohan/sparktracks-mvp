import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context),
            
            // Features for Parents
            _buildRoleSection(
              context,
              'For Parents',
              'Empower your family with smart task management',
              Icons.family_restroom,
              AppTheme.primaryColor,
              [
                'Create and assign tasks with point rewards',
                'Track your children\'s progress in real-time',
                'Manage multiple children with color coding',
                'Set up recurring tasks automatically',
                'Convert points to real currency rewards',
                'Access comprehensive financial ledger',
              ],
            ),
            
            // Features for Children
            _buildRoleSection(
              context,
              'For Children',
              'Learn responsibility while earning rewards',
              Icons.child_care,
              AppTheme.successColor,
              [
                'View your assigned tasks and deadlines',
                'Track your points and earnings',
                'Upload proof of completed tasks',
                'Enroll in coach-led classes',
                'Celebrate achievements and milestones',
                'Learn financial responsibility early',
              ],
            ),
            
            // Features for Coaches
            _buildRoleSection(
              context,
              'For Coaches',
              'Grow your coaching business effortlessly',
              Icons.school,
              AppTheme.infoColor,
              [
                'Create and manage classes easily',
                'Track student attendance and payments',
                'Send automated payment reminders',
                'Access detailed financial reports',
                'Communicate with students and parents',
                'Build your coaching reputation',
              ],
            ),
            
            // CTA Section
            _buildCTASection(context),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/pattern.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Main Heading
                  Text(
                    'SparkTracks',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Subtitle
                  Text(
                    'Where Learning Meets Earning',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // Description
                  Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      'The complete platform for families and coaches to manage tasks, track progress, and celebrate success together',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXXL),
                  
                  // CTA Buttons
                  Wrap(
                    spacing: AppTheme.spacingL,
                    runSpacing: AppTheme.spacingM,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildRoleButton(
                        context,
                        'I\'m a Parent',
                        Icons.family_restroom,
                        () => context.go('/login'),
                        isPrimary: true,
                      ),
                      _buildRoleButton(
                        context,
                        'I\'m a Child',
                        Icons.child_care,
                        () => context.go('/login'),
                        isPrimary: false,
                      ),
                      _buildRoleButton(
                        context,
                        'I\'m a Coach',
                        Icons.school,
                        () => context.go('/login'),
                        isPrimary: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String label, IconData icon, VoidCallback onPressed, {required bool isPrimary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
        foregroundColor: isPrimary ? AppTheme.primaryColor : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: Colors.white.withOpacity(isPrimary ? 0 : 0.3),
            width: 2,
          ),
        ),
        elevation: isPrimary ? 8 : 0,
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context, String title, String subtitle, IconData icon, Color color, List<String> features) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: color),
            ),
            const SizedBox(height: AppTheme.spacingL),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Subtitle
            Text(
              subtitle,
              style: AppTheme.headline6.copyWith(
                color: AppTheme.neutral600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            
            // Features Grid
            Wrap(
              spacing: AppTheme.spacingL,
              runSpacing: AppTheme.spacingL,
              alignment: WrapAlignment.center,
              children: features.map((feature) {
                return Container(
                  width: 350,
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 24),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Join thousands of families and coaches already using SparkTracks',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            child: const Text(
              'Create Free Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: AppTheme.neutral800,
      child: Column(
        children: [
          Text(
            '© 2025 SparkTracks. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Wrap(
            spacing: AppTheme.spacingL,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Privacy Policy', style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Terms of Service', style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Contact Us', style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

