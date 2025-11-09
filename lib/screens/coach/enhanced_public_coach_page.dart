import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../models/coach_profile_model.dart';
import '../../models/class_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/coach_reviews_section.dart';
import '../../widgets/quick_booking_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';

/// Enhanced Public Coach Webpage (v3.0)
/// SEO-optimized, beautiful marketing page for coaches
class EnhancedPublicCoachPage extends StatefulWidget {
  final String coachId;
  
  const EnhancedPublicCoachPage({super.key, required this.coachId});

  @override
  State<EnhancedPublicCoachPage> createState() => _EnhancedPublicCoachPageState();
}

class _EnhancedPublicCoachPageState extends State<EnhancedPublicCoachPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CoachProfile?>(
      future: FirestoreService().getCoachProfile(widget.coachId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text('Coach profile not found', style: AppTheme.headline5),
            ),
          );
        }

        return _buildCoachPage(snapshot.data!);
      },
    );
  }

  Widget _buildCoachPage(CoachProfile profile) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header
          _buildHeroHeader(profile, isMobile),
          
          // Content Sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildAboutSection(profile, isMobile),
                _buildExpertiseSection(profile, isMobile),
                _buildClassesSection(profile, isMobile),
                _buildTestimonialsSection(profile, isMobile),
                _buildReviewsSection(profile, isMobile),
                _buildContactSection(profile, isMobile),
                _buildFooter(isMobile),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bookTrial(profile),
        icon: const Icon(Icons.calendar_today),
        label: const Text('Book Free Trial'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Widget _buildHeroHeader(CoachProfile profile, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 300 : 400,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Photo
              CircleAvatar(
                radius: isMobile ? 60 : 80,
                backgroundColor: Colors.white,
                backgroundImage: profile.photoUrl != null 
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null
                    ? Text(
                        profile.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: isMobile ? 40 : 60,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              
              // Name & Headline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (profile.headline != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.headline!,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Quick Info
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  if (profile.location != null)
                    _buildInfoChip(Icons.location_on, profile.location!.displayLocation),
                  if (profile.yearsExperience != null)
                    _buildInfoChip(Icons.workspace_premium, '${profile.yearsExperience}+ Years'),
                  if (profile.rating != null)
                    _buildInfoChip(Icons.star, '${profile.rating!.toStringAsFixed(1)} ★'),
                  if (profile.languages.isNotEmpty)
                    _buildInfoChip(Icons.language, profile.languages.map((l) => l.language).join(', ')),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareProfile(profile),
          tooltip: 'Share Profile',
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(CoachProfile profile, bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 900),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About ${profile.name.split(' ').first}', style: AppTheme.headline3),
          const SizedBox(height: 16),
          if (profile.bio != null)
            Text(profile.bio!, style: AppTheme.bodyLarge),
          
          if (profile.teachingPhilosophy != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Text('Teaching Philosophy', style: AppTheme.headline6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(profile.teachingPhilosophy!, style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpertiseSection(CoachProfile profile, bool isMobile) {
    return Container(
      width: double.infinity,
      color: AppTheme.neutral50,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expertise & Credentials', style: AppTheme.headline3),
              const SizedBox(height: 24),
              
              // Specializations
              if (profile.specializations.isNotEmpty) ...[
                Text('I Teach:', style: AppTheme.headline6),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.specializations.map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Certifications
              if (profile.certifications.isNotEmpty) ...[
                Text('Certifications:', style: AppTheme.headline6),
                const SizedBox(height: 12),
                ...profile.certifications.map((cert) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                      title: Text(cert.name),
                      subtitle: cert.issuer != null 
                          ? Text('${cert.issuer} ${cert.year != null ? '• ${cert.year}' : ''}')
                          : null,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassesSection(CoachProfile profile, bool isMobile) {
    return StreamBuilder<List<Class>>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .where('coachId', isEqualTo: profile.id)
          .where('isPublic', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Class.fromJson(doc.data()))
              .toList()),
      builder: (context, snapshot) {
        final classes = snapshot.data ?? [];
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Classes Offered', style: AppTheme.headline3),
                  const SizedBox(height: 24),
                  
                  if (classes.isEmpty)
                    Center(
                      child: Text('No public classes available yet', style: AppTheme.bodyLarge),
                    )
                  else
                    ...classes.map((classItem) => _buildPublicClassCard(classItem, isMobile)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPublicClassCard(Class classItem, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(classItem.title, style: AppTheme.headline5),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (classItem.skillLevel != null)
                            _buildClassBadge(classItem.skillLevel.toString().split('.').last, Colors.blue),
                          if (classItem.minAge != null)
                            _buildClassBadge('Ages ${classItem.minAge}-${classItem.maxAge}', Colors.orange),
                          _buildClassBadge('${classItem.durationMinutes} min', Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${classItem.price.toStringAsFixed(0)}',
                      style: AppTheme.headline4.copyWith(color: AppTheme.primaryColor),
                    ),
                    Text('per session', style: AppTheme.bodySmall),
                    if (classItem.offersTrial) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🎁 Free Trial',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(classItem.description, style: AppTheme.bodyMedium),
            const SizedBox(height: 20),
            
            // What's Included
            if (classItem.includesProgressReports || 
                classItem.includesHomework || 
                classItem.includesCertificate) ...[
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (classItem.includesProgressReports)
                    _buildIncludedItem(Icons.assessment, 'Progress Reports'),
                  if (classItem.includesHomework)
                    _buildIncludedItem(Icons.assignment, 'Practice Homework'),
                  if (classItem.includesCertificate)
                    _buildIncludedItem(Icons.card_membership, 'Certificate'),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            // Enroll Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _enrollInClass(classItem),
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Enroll Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIncludedItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.successColor),
        const SizedBox(width: 6),
        Text(text, style: AppTheme.bodySmall),
      ],
    );
  }

  Widget _buildTestimonialsSection(CoachProfile profile, bool isMobile) {
    if (profile.testimonials.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppTheme.neutral50,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What Parents & Students Say', style: AppTheme.headline3),
              const SizedBox(height: 24),
              
              ...profile.testimonials.take(3).map((testimonial) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < testimonial.rating ? Icons.star : Icons.star_border,
                              color: AppTheme.accentColor,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"${testimonial.text}"',
                          style: AppTheme.bodyLarge.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '— ${testimonial.studentName}',
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (testimonial.relationship != null)
                          Text(
                            testimonial.relationship!.replaceAll('_', ' '),
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(CoachProfile profile, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Text('Reviews & Ratings', style: AppTheme.headline4),
                ],
              ),
              const SizedBox(height: 32),
              CoachReviewsSection(
                coachId: profile.id,
                coachName: profile.name,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(CoachProfile profile, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.rocket_launch, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Ready to Get Started?',
                style: AppTheme.headline4.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Book a free trial lesson and experience the difference!',
                style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _bookTrial(profile),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Free Trial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _sendMessage(profile),
                icon: const Icon(Icons.message),
                label: const Text('Send Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      width: double.infinity,
      color: AppTheme.neutral800,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Center(
        child: Text(
          'Powered by Sparktracks',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  void _shareProfile(CoachProfile profile) {
    final url = 'https://sparktracks-mvp.web.app/coach/${profile.id}';
    final message = '''
Check out ${profile.name}'s coaching profile on Sparktracks!

${profile.headline ?? 'Professional coaching services'}

View classes and book a free trial:
$url
    ''';

    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profile link copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _bookTrial(CoachProfile profile) async {
    // Check if user is logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      // Show login prompt
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Text('Login Required'),
            ],
          ),
          content: const Text(
            'Please sign in to book a class. It only takes 30 seconds!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );

      if (shouldLogin == true && mounted) {
        // Navigate to login (will need to import go_router)
        Navigator.of(context).pushNamed('/login');
      }
      return;
    }

    // Load children if not already loaded
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    if (childrenProvider.children.isEmpty) {
      await childrenProvider.loadChildren(authProvider.currentUser?.id ?? '');
    }

    // Get the first class from this coach
    final classes = await FirestoreService().getClasses(
      profile.id,
      userType: UserType.coach,
    );

    final firstClass = classes.isNotEmpty ? classes.first : null;

    if (firstClass == null) {
      // Coach has no classes yet
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Classes Available'),
            content: const Text(
              'This coach hasn\'t published any classes yet. Please check back soon or send them a message!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Show quick booking dialog
    if (mounted) {
      final booked = await showDialog<bool>(
        context: context,
        builder: (context) => QuickBookingDialog(
          classItem: firstClass,
          coachName: profile.name,
        ),
      );

      if (booked == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Booking request sent!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sendMessage(CoachProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: const Text(
          'This will open the messaging interface. Feature coming soon!',
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

  Future<void> _enrollInClass(Class classItem) async {
    // Check if user is logged in
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      // Show login prompt
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Text('Login Required'),
            ],
          ),
          content: const Text(
            'Please sign in to enroll in this class. It only takes 30 seconds!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );

      if (shouldLogin == true && mounted) {
        context.go('/login');
      }
      return;
    }

    // Load children if not already loaded
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    if (childrenProvider.children.isEmpty) {
      await childrenProvider.loadChildren(authProvider.currentUser?.id ?? '');
    }

    // Get coach name
    final coachProfile = await FirestoreService().getCoachProfile(classItem.coachId);
    final coachName = coachProfile?.name ?? 'Coach';

    // Show quick booking dialog
    if (mounted) {
      final booked = await showDialog<bool>(
        context: context,
        builder: (context) => QuickBookingDialog(
          classItem: classItem,
          coachName: coachName,
        ),
      );

      if (booked == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✅ Enrolled in ${classItem.title}!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  int _calculateProfileCompletion(User coach) {
    // Placeholder - use CoachProfile.getProfileCompletionPercentage()
    return 80;
  }
}

