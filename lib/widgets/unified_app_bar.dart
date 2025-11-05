import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

/// Unified app bar for consistent navigation across Parent, Child, and Coach dashboards
class UnifiedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final UserType userType;
  final List<Widget>? additionalActions;
  
  const UnifiedAppBar({
    super.key,
    required this.title,
    required this.userType,
    this.additionalActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Color _getColorForUserType(UserType type) {
    switch (type) {
      case UserType.parent:
        return AppTheme.primaryColor;
      case UserType.child:
        return AppTheme.accentColor;
      case UserType.coach:
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getIconForUserType(UserType type) {
    switch (type) {
      case UserType.parent:
        return Icons.family_restroom;
      case UserType.child:
        return Icons.child_care;
      case UserType.coach:
        return Icons.school;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final color = _getColorForUserType(userType);

    return AppBar(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIconForUserType(userType), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Universal Home Button
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
          tooltip: 'Home',
        ),
        
        // User-specific actions
        if (additionalActions != null) ...additionalActions!,
        
        // Share/Invite Feature
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _showShareDialog(context, currentUser),
          tooltip: 'Share Sparktracks',
        ),
        
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => _showNotifications(context),
          tooltip: 'Notifications',
        ),
        
        // Profile Menu
        PopupMenuButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              currentUser?.name.split(' ').first[0].toUpperCase() ?? 'U',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          tooltip: 'Profile Menu',
          offset: const Offset(0, 50),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(_getIconForUserType(userType), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.name ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        currentUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              enabled: false,
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('My Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'feedback',
              child: Row(
                children: [
                  Icon(Icons.feedback_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Send Feedback'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppTheme.errorColor),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, value as String),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showShareDialog(BuildContext context, User? user) {
    final shareText = _getShareText(user);
    final shareLink = 'https://sparktracks-mvp.web.app/';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Share Sparktracks'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shareText),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neutral300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      shareLink,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Link copied to clipboard!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy link',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.card_giftcard, color: AppTheme.accentColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Early users get lifetime access!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  String _getShareText(User? user) {
    switch (userType) {
      case UserType.parent:
        return 'I\'m using Sparktracks to manage my children\'s tasks and learning! Join me and get lifetime access for free.';
      case UserType.coach:
        return 'Check out my classes on Sparktracks! Manage your child\'s learning and development with me.';
      case UserType.child:
        return 'I\'m using Sparktracks to track my achievements and earn points! It\'s fun!';
      default:
        return 'Join Sparktracks - The modern learning management platform!';
    }
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppTheme.neutral400),
            SizedBox(height: 16),
            Text('No new notifications'),
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

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        if (userType == UserType.coach) {
          context.push('/coach-profile');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile settings coming soon!')),
          );
        }
        break;
      case 'settings':
        context.push('/notification-settings');
        break;
      case 'feedback':
        context.go('/feedback');
        break;
      case 'logout':
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.logout();
        context.go('/');
        break;
    }
  }
}

