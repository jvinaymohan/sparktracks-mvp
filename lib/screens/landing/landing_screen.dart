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
      final tasksSnapshot = await _firestore.collection('tasks').get();
      final classesSnapshot = await _firestore.collection('classes').get();
      
      return {
        'users': usersSnapshot.size,
        'tasks': tasksSnapshot.size,
        'classes': classesSnapshot.size,
      };
    } catch (e) {
      return {'users': 0, 'tasks': 0, 'classes': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⭐', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SparkTracks',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In'),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
          
          // Hero Section
          SliverToBoxAdapter(
            child: _buildModernHero(isMobile),
          ),
          
          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsSection(isMobile),
          ),
          
          // Features Section
          SliverToBoxAdapter(
            child: _buildFeaturesSection(isMobile),
          ),
          
          // Marketplace Preview
          SliverToBoxAdapter(
            child: _buildMarketplaceSection(isMobile),
          ),
          
          // CTA Section
          SliverToBoxAdapter(
            child: _buildCTASection(isMobile),
          ),
          
          // Footer
          SliverToBoxAdapter(
            child: _buildFooter(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHero(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.05),
            const Color(0xFF8B5CF6).withOpacity(0.05),
            const Color(0xFFA855F7).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '🚀 Early Access Now Available',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          
          // Main Headline
          Text(
            'Learning Made Fun,',
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F2937),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Progress Made Easy',
            style: TextStyle(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w900,
              height: 1.1,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          
          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Connect parents, kids, and coaches in one powerful platform. '
              'Track tasks, earn rewards, and celebrate achievements together.',
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          
          // CTA Buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 40,
                    vertical: isMobile ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Claim Your Spot',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => _tabController.animateTo(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 40,
                    vertical: isMobile ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Watch Demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 24 : 32),
          
          // Trust Badge
          Text(
            '✓ No credit card required  •  ✓ Early Access Offer',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      color: Colors.white,
      child: FutureBuilder<Map<String, int>>(
        future: _getStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {'users': 0, 'tasks': 0, 'classes': 0};
          
          return Wrap(
            spacing: isMobile ? 20 : 60,
            runSpacing: isMobile ? 20 : 40,
            alignment: WrapAlignment.center,
            children: [
              _buildStatCard(
                stats['users']! > 0 ? '${stats['users']}+' : 'New',
                'Active Users',
                Icons.people_outline,
                const Color(0xFF6366F1),
                isMobile,
              ),
              _buildStatCard(
                stats['classes']! > 0 ? '${stats['classes']}+' : 'New',
                'Classes Available',
                Icons.school_outlined,
                const Color(0xFFEC4899),
                isMobile,
              ),
              _buildStatCard(
                stats['tasks']! > 0 ? '${stats['tasks']}+' : 'New',
                'Tasks Completed',
                Icons.check_circle_outline,
                const Color(0xFF10B981),
                isMobile,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, bool isMobile) {
    return Container(
      width: isMobile ? 140 : 180,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 80,
      ),
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          Text(
            'Everything You Need',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Powerful features designed for modern families',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 48),
          
          Wrap(
            spacing: isMobile ? 16 : 24,
            runSpacing: isMobile ? 16 : 24,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                '📝',
                'Smart Tasks',
                'Create and manage tasks with rewards, deadlines, and recurring schedules.',
                const Color(0xFF3B82F6),
                isMobile,
              ),
              _buildFeatureCard(
                '⭐',
                'Points System',
                'Motivate with a flexible points system that converts to real rewards.',
                const Color(0xFFF59E0B),
                isMobile,
              ),
              _buildFeatureCard(
                '📊',
                'Live Progress',
                'Track achievements and progress in beautiful, real-time dashboards.',
                const Color(0xFF10B981),
                isMobile,
              ),
              _buildFeatureCard(
                '🎓',
                'Class Hub',
                'Browse and book classes from certified coaches in your area.',
                const Color(0xFFEC4899),
                isMobile,
              ),
              _buildFeatureCard(
                '💰',
                'Finance Tools',
                'Manage payments, invoices, and family finances effortlessly.',
                const Color(0xFF8B5CF6),
                isMobile,
              ),
              _buildFeatureCard(
                '🏆',
                'Achievements',
                'Celebrate milestones with badges, streaks, and leaderboards.',
                const Color(0xFF6366F1),
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title, String description, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 80,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            '🛍️ Coach Marketplace',
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Discover amazing classes from certified coaches. Sports, music, academics, and more!',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildClassCard('⚽', 'Soccer Training', 'Coach Mike', '\$25', const Color(0xFF10B981), isMobile),
              _buildClassCard('🎹', 'Piano Lessons', 'Coach Sarah', '\$40', const Color(0xFFEC4899), isMobile),
              _buildClassCard('📐', 'Math Tutoring', 'Coach David', '\$30', const Color(0xFF3B82F6), isMobile),
            ],
          ),
          SizedBox(height: isMobile ? 32 : 40),
          
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 14 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Browse All Classes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(String emoji, String title, String coach, String price, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              child: Text(emoji, style: const TextStyle(fontSize: 64)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coach,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$price/class',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
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

  Widget _buildCTASection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join families and coaches using SparkTracks today',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 40),
          
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 32 : 48,
                vertical: isMobile ? 16 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Start Your Free Trial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No credit card required',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF1F2937),
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
            ],
          ),
        ],
      ),
    );
  }
}
