import 'package:flutter/material.dart';
import '../../models/playdate_model.dart';
import '../../utils/app_theme.dart';

/// Playdate detail screen with RSVP, transportation, and expenses
/// Full implementation: 3-4 hours
class PlaydateDetailScreen extends StatelessWidget {
  final Playdate playdate;

  const PlaydateDetailScreen({
    Key? key,
    required this.playdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playdate Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: AppTheme.neutral400),
              const SizedBox(height: 24),
              Text('Playdate Detail Screen', style: AppTheme.headline5),
              const SizedBox(height: 12),
              Text(
                'Full detail view coming soon!\n\n'
                'Will include:\n'
                '• RSVP management\n'
                '• Transportation coordination\n'
                '• Expense splitting & tracking\n'
                '• Participant list\n'
                '• Chat with organizer',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text('Selected: ${playdate.title}', style: AppTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

