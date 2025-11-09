import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'gradient_home_button.dart';

/// Universal AppBar for all dashboards (Parent, Coach, Child, Admin)
/// Provides consistent structure: Home button, personalized title, actions
class UniversalDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleOverride;
  final TabBar? bottom;
  final List<Widget>? additionalActions;
  final VoidCallback onHomePressed;
  final bool showPersonalizedTitle;
  final String defaultTitle;

  const UniversalDashboardAppBar({
    Key? key,
    this.titleOverride,
    this.bottom,
    this.additionalActions,
    required this.onHomePressed,
    this.showPersonalizedTitle = true,
    this.defaultTitle = 'Dashboard',
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GradientHomeButton(onPressed: onHomePressed),
      title: _buildTitle(context),
      bottom: bottom,
      actions: _buildActions(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (titleOverride != null) {
      return Text(titleOverride!);
    }

    if (!showPersonalizedTitle) {
      return Text(defaultTitle);
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userName = authProvider.currentUser?.name ?? 'User';
        final firstName = userName.split(' ').first;
        return Text('Welcome, $firstName');
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final standardActions = <Widget>[
      // Notifications
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        tooltip: 'Notifications',
        onPressed: () => context.push('/notifications'),
      ),
      
      // Calendar
      IconButton(
        icon: const Icon(Icons.calendar_today),
        tooltip: 'Calendar',
        onPressed: () => context.push('/calendar'),
      ),
      
      // Feedback
      IconButton(
        icon: const Icon(Icons.feedback_outlined),
        tooltip: 'Feedback',
        onPressed: () => context.go('/feedback'),
      ),
      
      // Settings
      IconButton(
        icon: const Icon(Icons.settings_outlined),
        tooltip: 'Settings',
        onPressed: () => context.push('/notification-settings'),
      ),
      
      // Logout
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();
          if (context.mounted) {
            context.go('/');
          }
        },
      ),
    ];

    // Add any additional actions before standard ones
    if (additionalActions != null) {
      return [...additionalActions!, ...standardActions];
    }

    return standardActions;
  }
}

