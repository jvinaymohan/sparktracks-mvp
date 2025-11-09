import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/playdate_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/playdate_service.dart';
import '../../utils/app_theme.dart';

/// Screen for creating a new playdate
/// Full implementation: 4-6 hours
class CreatePlaydateScreen extends StatefulWidget {
  const CreatePlaydateScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlaydateScreen> createState() => _CreatePlaydateScreenState();
}

class _CreatePlaydateScreenState extends State<CreatePlaydateScreen> {
  // TODO: Implement full creation wizard
  // Estimated time: 4-6 hours
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Playdate'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: AppTheme.neutral400),
              const SizedBox(height: 24),
              Text(
                'Playdate Creation Wizard',
                style: AppTheme.headline5,
              ),
              const SizedBox(height: 12),
              Text(
                'Full playdate creation wizard coming in next sprint!\n\n'
                'Will include:\n'
                '• Event details & description\n'
                '• Invite other families\n'
                '• Transportation coordination\n'
                '• Expense splitting setup\n'
                '• Location & time picker',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Estimated completion: 4-6 hours',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.neutral600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

