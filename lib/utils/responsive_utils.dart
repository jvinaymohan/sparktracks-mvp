import 'package:flutter/material.dart';

/// Responsive Utilities for Mobile, Tablet, Desktop (v3.0)
/// Ensures consistent mobile-first experience across all screens

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Touch target minimum (iOS Human Interface Guidelines)
  static const double minTouchTarget = 48.0;
  
  // Padding
  static const double mobilePadding = 16.0;
  static const double tabletPadding = 24.0;
  static const double desktopPadding = 32.0;
  
  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  /// Get responsive padding based on screen size
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return mobilePadding;
    if (isTablet(context)) return tabletPadding;
    return desktopPadding;
  }
  
  /// Get responsive column count for grids
  static int getGridColumns(BuildContext context, {int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  /// Show dialog or bottom sheet based on device
  static Future<T?> showResponsiveDialog<T>({
    required BuildContext context,
    required Widget child,
    bool dismissible = true,
  }) {
    if (isMobile(context)) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        isDismissible: dismissible,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: child,
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      );
    }
  }
  
  /// Build responsive layout (different widgets for mobile/desktop)
  static Widget buildResponsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop ?? tablet ?? mobile;
  }
  
  /// Get responsive list padding (accounts for FAB)
  static EdgeInsets getListPadding(BuildContext context, {bool hasFAB = false}) {
    final basePadding = getResponsivePadding(context);
    return EdgeInsets.only(
      left: basePadding,
      right: basePadding,
      top: basePadding,
      bottom: hasFAB ? 80 : basePadding, // Extra padding for FAB
    );
  }
  
  /// Build touch-friendly button with minimum size
  static ButtonStyle getTouchFriendlyButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: const Size(minTouchTarget, minTouchTarget),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }
  
  /// Build responsive grid
  static Widget buildResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
    double spacing = 16,
  }) {
    final columns = getGridColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );
    
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
  
  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  /// Build responsive row/column
  static Widget buildResponsiveRowColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double spacing = 16,
  }) {
    if (isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, isHorizontal: false),
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(children, spacing, isHorizontal: true),
      );
    }
  }
  
  static List<Widget> _addSpacing(List<Widget> children, double spacing, {required bool isHorizontal}) {
    if (children.isEmpty) return children;
    
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          isHorizontal 
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }
    return spacedChildren;
  }
}

/// Widget extension for responsive helpers
extension ResponsiveWidget on Widget {
  /// Show this widget only on mobile
  Widget showOnMobile(BuildContext context) {
    return ResponsiveUtils.isMobile(context) ? this : const SizedBox.shrink();
  }
  
  /// Show this widget only on desktop
  Widget showOnDesktop(BuildContext context) {
    return ResponsiveUtils.isDesktop(context) ? this : const SizedBox.shrink();
  }
  
  /// Add touch-friendly padding
  Widget touchPadding() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: this,
    );
  }
}

