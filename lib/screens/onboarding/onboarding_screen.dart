import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to SparkTracks',
      description: 'The comprehensive learning management platform that connects parents, children, and coaches in one seamless experience.',
      icon: Icons.school,
      color: AppTheme.primaryColor,
      features: ['Task Management', 'Progress Tracking', 'Class Scheduling'],
    ),
    OnboardingPage(
      title: 'For Parents',
      description: 'Manage your children\'s tasks, track their progress, coordinate with coaches, and reward achievements.',
      icon: Icons.family_restroom,
      color: AppTheme.successColor,
      features: ['Task Assignment', 'Progress Monitoring', 'Payment Management', 'Coach Communication'],
    ),
    OnboardingPage(
      title: 'For Children',
      description: 'Complete tasks, earn rewards, participate in classes, and track your personal achievements.',
      icon: Icons.child_care,
      color: AppTheme.warningColor,
      features: ['Task Completion', 'Earnings Tracking', 'Class Participation', 'Achievement Badges'],
    ),
    OnboardingPage(
      title: 'For Coaches',
      description: 'Create classes, manage students, track attendance, and provide feedback to help athletes succeed.',
      icon: Icons.sports_handball,
      color: AppTheme.infoColor,
      features: ['Class Management', 'Student Enrollment', 'Attendance Tracking', 'Performance Analytics'],
    ),
    OnboardingPage(
      title: 'Key Features',
      description: 'Calendar integration, image uploads, notifications, and comprehensive analytics to enhance your experience.',
      icon: Icons.star,
      color: AppTheme.primaryColor,
      features: ['Calendar View', 'Photo Uploads', 'Smart Notifications', 'Detailed Analytics'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getDashboardRoute() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    print('Onboarding: Getting dashboard route for user: ${user?.name}, type: ${user?.type}, emailVerified: ${user?.emailVerified}');
    
    if (user == null) return '/login';
    
    // Mark onboarding as completed
    authProvider.completeOnboarding();
    
    switch (user.type) {
      case UserType.parent:
        return '/parent-dashboard';
      case UserType.child:
        return '/child-dashboard';
      case UserType.coach:
        return '/coach-dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.go(_getDashboardRoute()),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : AppTheme.neutral300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              context.go(_getDashboardRoute());
                            }
                          },
                          child: Text(
                            _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                          ),
                        ),
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

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Title
          Text(
            page.title,
            style: AppTheme.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Description
          Text(
            page.description,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Features List
          if (page.features.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingXL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: page.color.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Key Features:',
                    style: AppTheme.headline6.copyWith(color: page.color),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ...page.features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: page.color,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
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
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.features = const [],
  });
}
