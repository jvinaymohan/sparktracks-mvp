import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'app_theme.dart';

class NavigationHelper {
  /// Get the correct dashboard route based on user type
  static String getDashboardRoute(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user == null) return '/';
    
    switch (user.type) {
      case UserType.parent:
        return '/parent-dashboard';
      case UserType.child:
        return '/child-dashboard';
      case UserType.coach:
        return '/coach-dashboard';
      default:
        return '/';
    }
  }
  
  /// Smart back button that goes to the correct dashboard
  static void goToDashboard(BuildContext context) {
    final dashboardRoute = getDashboardRoute(context);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(dashboardRoute);
    }
  }
  
  /// Create a gradient home button widget (reusable)
  static Widget buildGradientHomeButton(BuildContext context, {String? tooltip}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.home, color: Colors.white),
        tooltip: tooltip ?? 'Back to Dashboard',
        onPressed: () {
          final dashboardRoute = getDashboardRoute(context);
          context.go(dashboardRoute);
        },
      ),
    );
  }
}

