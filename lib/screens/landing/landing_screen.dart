import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      body: Column(
        children: [
          // Hero Section (Fixed, no scrolling)
          _buildHeroSection(context, isMobile),
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.neutral600,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: 'About'),
                Tab(icon: Icon(Icons.store), text: 'Marketplace'),
                Tab(icon: Icon(Icons.new_releases), text: 'What\'s New'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(context, isMobile),
                _buildMarketplaceTab(context, isMobile),
                _buildWhatsNewTab(context, isMobile),
              ],
            ),
          ),
          
          // Footer CTA
          _buildFooterCTA(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
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
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Text('⭐', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'SparkTracks',
            style: TextStyle(
              fontSize: isMobile ? 36 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            '🎯 Learn • Earn • Grow 🚀',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'For parents, kids, and coaches',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          
          // CTA Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 8,
                ),
                icon: const Icon(Icons.rocket_launch),
                label: Text(
                  'Get Started Free',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32,
                    vertical: isMobile ? 12 : 16,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                icon: const Icon(Icons.login),
                label: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // About Tab
  Widget _buildAboutTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        children: [
          Text(
            '💡 What is SparkTracks?',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'A comprehensive platform connecting parents, children, and coaches. '
              'Track tasks, manage rewards, organize classes, and monitor progress.',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: AppTheme.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          
          // Dynamic Stats
          FutureBuilder<Map<String, int>>(
            future: _getStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              
              final stats = snapshot.data ?? {'users': 0, 'tasks': 0, 'classes': 0};
              
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatCard(
                    stats['users']! > 0 ? '${stats['users']}' : 'New!',
                    'Users',
                    Icons.people,
                    isMobile,
                  ),
                  _buildStatCard(
                    stats['classes']! > 0 ? '${stats['classes']}' : 'New!',
                    'Classes',
                    Icons.school,
                    isMobile,
                  ),
                  _buildStatCard(
                    stats['tasks']! > 0 ? '${stats['tasks']}' : 'New!',
                    'Tasks',
                    Icons.check_circle,
                    isMobile,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Key Features
          Text(
            '✨ Key Features',
            style: TextStyle(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral800,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildFeatureChip('📝 Task Management', const Color(0xFF3B82F6), isMobile),
                _buildFeatureChip('⭐ Points System', const Color(0xFFF59E0B), isMobile),
                _buildFeatureChip('📊 Progress Tracking', const Color(0xFF10B981), isMobile),
                _buildFeatureChip('💰 Financial Reports', const Color(0xFF8B5CF6), isMobile),
                _buildFeatureChip('🎓 Class Management', const Color(0xFFEC4899), isMobile),
                _buildFeatureChip('🏆 Achievements', const Color(0xFF6366F1), isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Marketplace Tab
  Widget _buildMarketplaceTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🛍️', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                'Coach Marketplace',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Browse classes from certified coaches. Sports, music, academics, arts—find the perfect fit!',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: AppTheme.neutral600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          
          // Sample Classes
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildMarketplaceCard(
                'Soccer Training ⚽',
                'Coach Mike',
                '\$25',
                '15 spots',
                const Color(0xFF10B981),
                isMobile,
              ),
              _buildMarketplaceCard(
                'Piano Lessons 🎹',
                'Coach Sarah',
                '\$40',
                '8 spots',
                const Color(0xFFEC4899),
                isMobile,
              ),
              _buildMarketplaceCard(
                'Math Tutoring 📐',
                'Coach David',
                '\$30',
                '12 spots',
                const Color(0xFF3B82F6),
                isMobile,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.explore),
            label: const Text(
              'Explore Marketplace',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // What's New Tab
  Widget _buildWhatsNewTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🆕', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                'What\'s New',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Latest features and updates',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: 32),
          
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                _buildUpdateCard(
                  '🔥 Firebase Integration',
                  'Jan 2025',
                  'Real authentication & persistent data storage.',
                  true,
                  isMobile,
                ),
                const SizedBox(height: 12),
                _buildUpdateCard(
                  '⭐ Points System',
                  'Jan 2025',
                  'Flexible rewards with custom conversion rates.',
                  true,
                  isMobile,
                ),
                const SizedBox(height: 12),
                _buildUpdateCard(
                  '📊 Enhanced Dashboards',
                  'Jan 2025',
                  'Beautiful dashboards with real-time updates.',
                  false,
                  isMobile,
                ),
                const SizedBox(height: 12),
                _buildUpdateCard(
                  '🔄 Recurring Tasks',
                  'Jan 2025',
                  'Daily, weekly, monthly task scheduling.',
                  false,
                  isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Footer CTA
  Widget _buildFooterCTA(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppTheme.neutral800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '© 2025 SparkTracks • Made with ❤️',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon, bool isMobile) {
    return Container(
      width: isMobile ? 120 : 160,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: isMobile ? 28 : 36, color: const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppTheme.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 13 : 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMarketplaceCard(
    String title,
    String coach,
    String price,
    String spots,
    Color color,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? 200 : 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                title.split(' ').last,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coach,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        spots,
                        style: TextStyle(
                          fontSize: 11,
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

  Widget _buildUpdateCard(
    String title,
    String date,
    String description,
    bool isNew,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNew) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutral500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
