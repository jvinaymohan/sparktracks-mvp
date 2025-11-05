import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/classes_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/share_feature_card.dart';

/// Dedicated sharing screen for promoting Sparktracks
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share & Invite'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Share Sparktracks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help friends and family discover Sparktracks!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // User-specific share cards
            if (user?.type == UserType.parent) ..._buildParentShareCards(),
            if (user?.type == UserType.coach) ..._buildCoachShareCards(context),
            if (user?.type == UserType.child) ..._buildChildShareCards(),
            
            const SizedBox(height: 24),
            
            // Early Access Highlight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.card_giftcard, color: AppTheme.accentColor, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Early Access Offer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Everyone who joins now gets lifetime access at no charge! Share this opportunity with friends and family.',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParentShareCards() {
    return [
      const Text(
        'Share with Friends',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      ShareFeatureCard(
        title: 'Invite Other Parents',
        description: 'Help your friends manage their children\'s tasks!',
        shareLink: 'https://sparktracks-mvp.web.app/',
        shareMessage: '🎉 I\'m using Sparktracks to manage my kids\' tasks & rewards! Join me and get lifetime access for free during early access. It\'s been a game-changer!',
        icon: Icons.family_restroom,
        color: AppTheme.primaryColor,
      ),
      const SizedBox(height: 16),
      ShareFeatureCard(
        title: 'Find Coaches',
        description: 'Browse classes or recommend Sparktracks to your child\'s coaches!',
        shareLink: 'https://sparktracks-mvp.web.app/',
        shareMessage: '👋 Check out Sparktracks - an amazing platform for coaches to manage classes, students, and attendance!',
        icon: Icons.school,
        color: AppTheme.successColor,
      ),
    ];
  }

  List<Widget> _buildCoachShareCards(BuildContext context) {
    final classesProvider = Provider.of<ClassesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final myClasses = classesProvider.getClassesForCoach(authProvider.currentUser?.id ?? '');
    
    return [
      const Text(
        'Promote Your Classes',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      ShareFeatureCard(
        title: 'Share Your Classes',
        description: 'Invite parents to browse and enroll their children!',
        shareLink: 'https://sparktracks-mvp.web.app/',
        shareMessage: '🏫 Check out my classes on Sparktracks! I offer ${myClasses.length} program(s) for children. Sign up for free and enroll your child today!',
        icon: Icons.campaign,
        color: AppTheme.successColor,
      ),
      const SizedBox(height: 16),
      ShareFeatureCard(
        title: 'Invite Other Coaches',
        description: 'Grow the coaching community on Sparktracks!',
        shareLink: 'https://sparktracks-mvp.web.app/',
        shareMessage: '👋 Fellow coaches! Join Sparktracks to manage your classes, students, and attendance all in one place. Free lifetime access for early users!',
        icon: Icons.groups,
        color: AppTheme.accentColor,
      ),
      const SizedBox(height: 24),
      
      // My Public Classes
      if (myClasses.where((c) => c.isPublic).isNotEmpty) ...[
        const Text(
          'Your Public Classes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...myClasses.where((c) => c.isPublic).map((classItem) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.successColor,
                child: const Icon(Icons.class_, color: Colors.white),
              ),
              title: Text(classItem.title),
              subtitle: Text('${classItem.enrolledStudentIds.length} enrolled'),
              trailing: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final link = classItem.shareableLink ?? 'https://sparktracks-mvp.web.app/';
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Link for "${classItem.title}" copied!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                tooltip: 'Copy class link',
              ),
            ),
          );
        }).toList(),
      ],
    ];
  }

  List<Widget> _buildChildShareCards() {
    return [
      const Text(
        'Share Your Progress',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      ShareFeatureCard(
        title: 'Tell Your Friends',
        description: 'Invite friends to join Sparktracks and earn points together!',
        shareLink: 'https://sparktracks-mvp.web.app/',
        shareMessage: '🎮 I\'m using Sparktracks to complete tasks and earn rewards! It\'s super fun - you should try it!',
        icon: Icons.group_add,
        color: AppTheme.accentColor,
      ),
    ];
  }
}

