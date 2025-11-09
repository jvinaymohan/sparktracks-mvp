import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Universal gradient home button for all dashboards
/// Appears in top-left of AppBar leading position
/// Returns to overview/first tab when pressed
class GradientHomeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const GradientHomeButton({
    Key? key,
    required this.onPressed,
    this.tooltip = 'Home Dashboard',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.home, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

