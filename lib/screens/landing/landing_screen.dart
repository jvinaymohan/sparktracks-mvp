import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<Map<String, int>> _getStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final childrenSnapshot = await _firestore.collection('children').get();
      final tasksSnapshot = await _firestore.collection('tasks').get();
      final classesSnapshot = await _firestore.collection('classes').get();
      
      return {
        'users': usersSnapshot.size,
        'children': childrenSnapshot.size,
        'tasks': tasksSnapshot.size,
        'classes': classesSnapshot.size,
      };
    } catch (e) {
      // Return placeholder values if Firebase isn't set up yet
      return {
        'users': 0,
        'children': 0,
        'tasks': 0,
        'classes': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildAboutSection(context),
            _buildFeaturesSection(context),
            _buildMarketplacePreview(context),
            _buildWhatsNewSection(context),
            _buildCTASection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Hero Section
  Widget _buildHeroSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight < 800 ? screenHeight * 0.95 : 700,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFA855F7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated circles background
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL, vertical: AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Text('⭐', style: TextStyle(fontSize: 60)),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main Heading
                  Text(
                    'SparkTracks',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  const Text(
                    '🎯 Learn • Earn • Grow 🚀',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The all-in-one platform for parents, kids, and coaches',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Role cards
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildRoleCard(context, 'Parents', '👨‍👩‍👧', 'Manage & Track', const Color(0xFF3B82F6)),
                      _buildRoleCard(context, 'Kids', '🧒', 'Learn & Earn', const Color(0xFF10B981)),
                      _buildRoleCard(context, 'Coaches', '👨‍🏫', 'Teach & Grow', const Color(0xFFF59E0B)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA
                  ElevatedButton(
                    onPressed: () => context.go('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Get Started Free', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // About Section
  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            '💡 What is SparkTracks?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral800,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'SparkTracks is a comprehensive learning management platform that connects parents, children, and coaches. '
              'Track tasks, manage rewards, organize classes, and monitor progress—all in one beautiful, easy-to-use platform.',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.neutral600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          FutureBuilder<Map<String, int>>(
            future: _getStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              
              final stats = snapshot.data ?? {'users': 0, 'children': 0, 'tasks': 0, 'classes': 0};
              final userCount = stats['users'] ?? 0;
              final classCount = stats['classes'] ?? 0;
              final taskCount = stats['tasks'] ?? 0;
              
              return Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatCard(
                    userCount > 0 ? '$userCount' : 'New!',
                    'Active Users',
                    Icons.people,
                  ),
                  _buildStatCard(
                    classCount > 0 ? '$classCount' : 'New!',
                    'Classes',
                    Icons.school,
                  ),
                  _buildStatCard(
                    taskCount > 0 ? '$taskCount' : 'New!',
                    'Tasks Completed',
                    Icons.check_circle,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF6366F1)),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Features Section
  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            '✨ Powerful Features',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral800,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                '📝 Smart Task Management',
                'Create, assign, and track tasks with rewards. Support for recurring tasks and priorities.',
                const Color(0xFF3B82F6),
                Icons.assignment,
              ),
              _buildFeatureCard(
                '⭐ Points & Rewards System',
                'Motivate kids with a flexible points system. Convert points to real rewards.',
                const Color(0xFFF59E0B),
                Icons.stars,
              ),
              _buildFeatureCard(
                '📊 Progress Tracking',
                'Monitor learning progress, task completion, and achievement milestones.',
                const Color(0xFF10B981),
                Icons.trending_up,
              ),
              _buildFeatureCard(
                '🎓 Class Management',
                'Schedule classes, track attendance, and manage enrollments effortlessly.',
                const Color(0xFFEC4899),
                Icons.school,
              ),
              _buildFeatureCard(
                '💰 Financial Dashboard',
                'Track payments, generate invoices, and manage family finances.',
                const Color(0xFF8B5CF6),
                Icons.account_balance_wallet,
              ),
              _buildFeatureCard(
                '🏆 Achievements & Badges',
                'Celebrate success with achievements, badges, and leaderboards.',
                const Color(0xFF6366F1),
                Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, Color color, IconData icon) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.neutral600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Marketplace Preview Section
  Widget _buildMarketplacePreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🛍️', style: TextStyle(fontSize: 40)),
              SizedBox(width: 16),
              Text(
                'Coach Marketplace',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Browse hundreds of classes from certified coaches. From sports to music, academics to arts—find the perfect learning experience for your child.',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.neutral600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          
          // Sample marketplace classes
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildMarketplaceCard(
                'Soccer Training ⚽',
                'Coach Mike Johnson',
                '\$25/class',
                '15 spots left',
                const Color(0xFF10B981),
              ),
              _buildMarketplaceCard(
                'Piano Lessons 🎹',
                'Coach Sarah Lee',
                '\$40/class',
                '8 spots left',
                const Color(0xFFEC4899),
              ),
              _buildMarketplaceCard(
                'Math Tutoring 📐',
                'Coach David Chen',
                '\$30/class',
                '12 spots left',
                const Color(0xFF3B82F6),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Marketplace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceCard(String title, String coach, String price, String spots, Color color) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Text(
                title.split(' ').last,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.split(' ').first + ' ' + title.split(' ')[1],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      coach,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spots,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
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
    );
  }

  // What's New Section
  Widget _buildWhatsNewSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🆕', style: TextStyle(fontSize: 40)),
              SizedBox(width: 16),
              Text(
                'What\'s New',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Stay updated with the latest features and improvements',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: 48),
          
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _buildUpdateCard(
                  '🔥 Firebase Integration',
                  'January 2025',
                  'Real authentication, email verification, and persistent data storage with Firestore.',
                  true,
                ),
                const SizedBox(height: 16),
                _buildUpdateCard(
                  '⭐ Points System',
                  'January 2025',
                  'New flexible points system with customizable rewards and conversion rates.',
                  true,
                ),
                const SizedBox(height: 16),
                _buildUpdateCard(
                  '📊 Enhanced Dashboards',
                  'January 2025',
                  'Beautiful, responsive dashboards for Parents, Kids, and Coaches with real-time updates.',
                  false,
                ),
                const SizedBox(height: 16),
                _buildUpdateCard(
                  '🔄 Recurring Tasks',
                  'January 2025',
                  'Create daily, weekly, or monthly recurring tasks with smart scheduling.',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(String title, String date, String description, bool isNew) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isNew) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.neutral500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.neutral600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CTA Section
  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            const Color(0xFF6366F1).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🚀 Ready to Get Started?',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join families and coaches using SparkTracks',
            style: TextStyle(
              fontSize: 20,
              color: AppTheme.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
            child: const Text(
              'Sign Up Free - No Credit Card Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Footer
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: AppTheme.neutral800,
      child: Column(
        children: [
          Text(
            '© 2025 SparkTracks • Made with ❤️',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Login', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Text('Sign Up', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ),
              TextButton(
                onPressed: () {},
                child: Text('About', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Privacy', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Terms', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String emoji, String subtitle, Color color) {
    return InkWell(
      onTap: () => context.go('/register'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
