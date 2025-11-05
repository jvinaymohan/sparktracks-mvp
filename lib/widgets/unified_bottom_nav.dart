import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

/// Unified bottom navigation for consistent UX across all user types
class UnifiedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserType userType;
  
  const UnifiedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
  });

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

  List<BottomNavigationBarItem> _getNavItemsForUserType(UserType type) {
    switch (type) {
      case UserType.parent:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Children',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Classes',
          ),
        ];
      case UserType.child:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Rewards',
          ),
        ];
      case UserType.coach:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            activeIcon: Icon(Icons.class_),
            label: 'My Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Insights',
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: _getColorForUserType(userType),
      unselectedItemColor: AppTheme.neutral600,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: Colors.white,
      items: _getNavItemsForUserType(userType),
    );
  }
}

