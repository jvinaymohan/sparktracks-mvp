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
            // Hero Section - Now compact and fun!
            _buildHeroSection(context),
            
            // Quick Features Strip
            _buildQuickFeatures(context),
            
            // Footer
            _buildCompactFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight < 800 ? screenHeight * 0.95 : 700,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1), // Bright indigo
            const Color(0xFF8B5CF6), // Purple
            const Color(0xFFA855F7), // Light purple
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
                  // Fun emoji-style logo
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
                    child: const Text(
                      '⭐',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main Heading - More playful
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
                  
                  // Fun subtitle with emojis
                  Text(
                    '🎯 Learn • Earn • Grow 🚀',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Three role cards in a row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildRoleCard(
                        context,
                        'Parents',
                        '👨‍👩‍👧',
                        'Manage & Track',
                        const Color(0xFF3B82F6),
                      ),
                      _buildRoleCard(
                        context,
                        'Kids',
                        '🧒',
                        'Learn & Earn',
                        const Color(0xFF10B981),
                      ),
                      _buildRoleCard(
                        context,
                        'Coaches',
                        '👨‍🏫',
                        'Teach & Grow',
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Single prominent CTA
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Get Started Free',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 24),
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

  Widget _buildRoleCard(BuildContext context, String title, String emoji, String subtitle, Color color) {
    return InkWell(
      onTap: () => context.go('/login'),
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

  Widget _buildQuickFeatures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            '✨ Everything You Need in One Place',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral800,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureChip('📝 Task Management', const Color(0xFF3B82F6)),
              _buildFeatureChip('⭐ Points System', const Color(0xFFF59E0B)),
              _buildFeatureChip('📊 Progress Tracking', const Color(0xFF10B981)),
              _buildFeatureChip('💰 Financial Reports', const Color(0xFF8B5CF6)),
              _buildFeatureChip('🎓 Class Management', const Color(0xFFEC4899)),
              _buildFeatureChip('🏆 Achievements', const Color(0xFF6366F1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCompactFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: AppTheme.neutral800,
      child: Column(
        children: [
          const Text(
            '🚀 Ready to get started?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Sign Up Free',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 SparkTracks • Made with ❤️',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

