/// Mobile Design Constants (v3.0)
/// iOS and Android specific design guidelines

import 'package:flutter/material.dart';

class MobileConstants {
  // Touch Targets (iOS Human Interface Guidelines & Material Design)
  static const double minTouchTarget = 48.0; // Minimum for both iOS and Android
  static const double recommendedTouchTarget = 56.0; // Comfortable size
  static const double iconButtonSize = 48.0;
  
  // Safe Areas (notches, home indicators)
  static const double iosHomeIndicatorHeight = 34.0;
  static const double iosNotchHeight = 44.0;
  
  // App Bar Heights
  static const double appBarHeight = 56.0;
  static const double appBarHeightWithTabs = 106.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 80.0; // Taller for easier tapping
  static const double bottomNavIconSize = 28.0; // Larger icons
  
  // FAB
  static const double fabSize = 56.0;
  static const double fabMargin = 16.0;
  static const double fabBottomPadding = 16.0;
  
  // List Item Heights
  static const double listItemMinHeight = 72.0; // Comfortable tap area
  static const double compactListItemHeight = 56.0;
  
  // Card Elevation
  static const double cardElevation = 2.0;
  static const double elevatedCardElevation = 4.0;
  
  // Border Radius (iOS friendly)
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double xlRadius = 20.0;
  
  // Spacing (8dp grid)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  
  // Font Sizes (readable on mobile)
  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeHeading = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeLargeTitle = 24.0;
  
  // Form Field Heights
  static const double textFieldHeight = 56.0;
  static const double textFieldMultilineMinHeight = 120.0;
  
  // Bottom Sheet
  static const double bottomSheetHandleWidth = 40.0;
  static const double bottomSheetHandleHeight = 4.0;
  static const double bottomSheetMaxHeight = 0.9; // 90% of screen
  
  // Gesture Thresholds
  static const double swipeThreshold = 100.0; // pixels
  static const double longPressDuration = 500; // milliseconds
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Platform-Specific
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }
  
  static bool isAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }
}

