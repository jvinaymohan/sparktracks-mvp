import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

/// Comprehensive UX-Optimized Landing Page V3
/// Addresses all feedback: Clear messaging, visual hierarchy, social proof,
/// navigation, mobile optimization, emotional engagement
class LandingScreenV3 extends StatefulWidget {
  const LandingScreenV3({super.key});

  @override
  State<LandingScreenV3> createState() => _LandingScreenV3State();
}

class _LandingScreenV3State extends State<LandingScreenV3> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showMobileMenu = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      // Floating Action Button for Accessibility
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccessibilityOptions(context),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.accessibility_new),
        label: const Text('Accessibility'),
      ),
      body: CustomScrollView(
        slivers: [
          // Enhanced Navigation Header
          _buildNavigationHeader(isMobile),
          
          // Hero Section with Clear Value Prop
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: _buildHeroSection(isMobile),
            ),
          ),
          
          // Trust Signals (Stats & Social Proof)
          SliverToBoxAdapter(
            child: _buildTrustSection(isMobile),
          ),
          
          // Visual Benefit Cards
          SliverToBoxAdapter(
            child: _buildBenefitsSection(isMobile),
          ),
          
          // How It Works (Clear Steps)
          SliverToBoxAdapter(
            key: _howItWorksKey,
            child: _buildHowItWorksSection(isMobile),
          ),
          
          // Social Proof (When Available)
          if (!isMobile)
            SliverToBoxAdapter(
              child: _buildPartnersSection(isMobile),
            ),
          
          // FAQ Section
          SliverToBoxAdapter(
            key: _faqKey,
            child: _buildFAQSection(isMobile),
          ),
          
          // Final CTA
          SliverToBoxAdapter(
            child: _buildFinalCTA(isMobile),
          ),
          
          // Enhanced Footer
          SliverToBoxAdapter(
            child: _buildFooter(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader(bool isMobile) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          // Logo with Brand Colors
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'SparkTracks',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Where Kids Thrive',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          TextButton(
            onPressed: () => _scrollToSection('how-it-works'),
            child: const Text('How It Works', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => _scrollToSection('faq'),
            child: const Text('FAQ', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => context.go('/browse-classes'),
            child: const Text('Browse Classes', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign In'),
          ),
        ],
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => context.go('/register'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B9D),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text('Start Free', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (isMobile)
          IconButton(
            icon: Icon(_showMobileMenu ? Icons.close : Icons.menu),
            onPressed: () => setState(() => _showMobileMenu = !_showMobileMenu),
          ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF5F7),
            const Color(0xFFFEFCE8),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Column(
                  children: [
                    _buildHeroContent(isMobile),
                    const SizedBox(height: 48),
                    _buildHeroVisual(isMobile),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildHeroContent(isMobile)),
                    const SizedBox(width: 80),
                    Expanded(child: _buildHeroVisual(isMobile)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Beta Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDCFCE7), Color(0xFFBFDBFE)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Text(
                'Early Beta • Join & Give Feedback',
                style: TextStyle(
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 28 : 36),
        
        // Clear Value Proposition
        Text(
          'Your Child\'s Growth,',
          style: TextStyle(
            fontSize: isMobile ? 42 : 58,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1F2937),
            height: 1.1,
            letterSpacing: -1,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        Text(
          'All in One Place',
          style: TextStyle(
            fontSize: isMobile ? 42 : 58,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFF8B5CF6)],
              ).createShader(const Rect.fromLTWH(0, 0, 400, 80)),
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: isMobile ? 20 : 24),
        
        // Clear Explanation
        Text(
          'Track tasks, celebrate wins, discover amazing classes, and watch your child thrive—all with one simple app parents actually love.',
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            color: const Color(0xFF4B5563),
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        SizedBox(height: isMobile ? 36 : 44),
        
        // Prominent CTA
        SizedBox(
          width: isMobile ? double.infinity : null,
          child: ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 56 : 72,
                vertical: isMobile ? 22 : 26,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFFF6B9D).withOpacity(0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Start Free Now',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, size: 26),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Trust Signals
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 20,
          runSpacing: 12,
          children: const [
            _TrustBadge(icon: Icons.check_circle_rounded, text: 'No cost to start'),
            _TrustBadge(icon: Icons.feedback_rounded, text: 'Give feedback'),
            _TrustBadge(icon: Icons.flash_on_rounded, text: '2 min setup'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroVisual(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFEBF0),
            const Color(0xFFE0F2FE),
            const Color(0xFFFEF3C7),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Placeholder for Hero Image/Video
          Container(
            height: isMobile ? 280 : 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Watch 60-Second Demo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'See how easy it is!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
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

  Widget _buildTrustSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFFFF5F7).withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.feedback_rounded, color: Color(0xFF166534), size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Help Shape Sparktracks - Your Feedback Matters!',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 28 : 36),
              
              Text(
                'Join Our Beta Community',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Be among the first families to experience Sparktracks. Your input will directly influence how we grow!',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: const Color(0xFF6B7280),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFFFF5F7).withOpacity(0.5),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Everything Parents Need',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Simple, powerful tools to help your family thrive',
                style: TextStyle(
                  fontSize: isMobile ? 17 : 20,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 48 : 64),
              
              Wrap(
                spacing: 28,
                runSpacing: 28,
                alignment: WrapAlignment.center,
                children: [
                  _buildBenefitCard(
                    '📊',
                    'Track Growth',
                    'Beautiful charts show your child\'s progress in real-time. See wins big and small!',
                    const Color(0xFF10B981),
                    isMobile,
                  ),
                  _buildBenefitCard(
                    '🎯',
                    'Boost Motivation',
                    'Fun rewards and celebrations keep kids excited to learn and complete tasks.',
                    const Color(0xFFFF6B9D),
                    isMobile,
                  ),
                  _buildBenefitCard(
                    '🎓',
                    'Discover Classes',
                    'Find vetted coaches and amazing classes nearby. Book instantly with one tap.',
                    const Color(0xFF8B5CF6),
                    isMobile,
                  ),
                  _buildBenefitCard(
                    '⏱️',
                    'Save Time',
                    'Manage everything in one app. No more juggling calendars, notes, and apps.',
                    const Color(0xFF3B82F6),
                    isMobile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitCard(String emoji, String title, String description, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 80,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Text(
                'Get Started in Minutes',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Three simple steps to transform family life',
                style: TextStyle(
                  fontSize: isMobile ? 17 : 20,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 48 : 64),
              
              _buildStep('1', 'Create Free Account', 'No credit card, no commitments—just sign up and go!', const Color(0xFFFF6B9D), isMobile),
              _buildStep('2', 'Add Your Child', 'Takes 30 seconds. Add name, age, and you\'re ready.', const Color(0xFF10B981), isMobile),
              _buildStep('3', 'Start Growing Together', 'Assign tasks, track progress, discover classes. It\'s that easy!', const Color(0xFF8B5CF6), isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, Color color, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 48,
      ),
      color: const Color(0xFFFAFAFA),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Backed by Education Experts',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              
              // Placeholder for partner logos
              Wrap(
                spacing: 40,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 120,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Center(
                      child: Text(
                        'Partner ${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 80,
      ),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Everything you need to know',
                style: TextStyle(
                  fontSize: isMobile ? 17 : 20,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 40 : 56),
              
              _buildFAQItem(
                'Is there any cost to join the beta?',
                'No! The beta is completely free to join. We\'re looking for families to test and give feedback. No credit card required, no commitments.',
                Icons.attach_money_rounded,
              ),
              _buildFAQItem(
                'Is my family\'s data secure?',
                'Absolutely. We use bank-level encryption and never sell your data. Your privacy is our top priority. Read our privacy policy for details.',
                Icons.security_rounded,
              ),
              _buildFAQItem(
                'What ages is this for?',
                'Sparktracks works great for kids ages 4-14. We have age-appropriate interfaces for younger kids and more advanced features for teens.',
                Icons.child_care_rounded,
              ),
              _buildFAQItem(
                'Can I use it on mobile?',
                'Yes! Sparktracks works perfectly on phones, tablets, and computers. Access from anywhere, anytime.',
                Icons.phone_android_rounded,
              ),
              _buildFAQItem(
                'How do I get started?',
                'Click "Start Free Now", create an account, add your child, and you\'re ready! It takes about 2 minutes total.',
                Icons.rocket_launch_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B9D), size: 24),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCTA(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 80 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                'Ready to See Your Child Thrive?',
                style: TextStyle(
                  fontSize: isMobile ? 36 : 52,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Join hundreds of families already growing with Sparktracks. Start your journey today—it\'s free!',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  color: const Color(0xFF4B5563),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 44 : 56),
              
              ElevatedButton(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 64 : 80,
                    vertical: isMobile ? 24 : 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 10,
                  shadowColor: const Color(0xFFFF6B9D).withOpacity(0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Start Free Today',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.arrow_forward_rounded, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Takes 2 minutes • No cost to start • Give feedback',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 48,
      ),
      color: const Color(0xFF1F2937),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Wrap(
                spacing: isMobile ? 20 : 48,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/about'),
                    child: const Text('About', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/browse-classes'),
                    child: const Text('Browse Classes', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/privacy'),
                    child: const Text('Privacy', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/terms'),
                    child: const Text('Terms', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () => _showAccessibilityOptions(context),
                    child: const Text('Accessibility', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Made with 💛 by Vinay Jonnakuti',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '© 2025 Sparktracks. All rights reserved.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToSection(String section) {
    final GlobalKey? key = section == 'how-it-works' ? _howItWorksKey : 
                           section == 'faq' ? _faqKey : null;
    
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Position near top of viewport
      );
    }
  }

  void _showAccessibilityOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.accessibility_new, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text('Accessibility Options'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We\'re committed to making Sparktracks accessible to everyone.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildAccessibilityOption('High Contrast Mode', Icons.contrast),
            _buildAccessibilityOption('Larger Text', Icons.text_fields),
            _buildAccessibilityOption('Screen Reader Support', Icons.record_voice_over),
            _buildAccessibilityOption('Keyboard Navigation', Icons.keyboard),
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

  Widget _buildAccessibilityOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1)),
      title: Text(label),
      trailing: Switch(
        value: false,
        onChanged: (value) {},
        activeColor: const Color(0xFF10B981),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

