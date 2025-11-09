import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import 'admin_data_cleanup_dialog.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final settings = adminProvider.systemSettings;
        
        if (settings == null) {
          return const Center(child: Text('Loading settings...'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Settings', style: AppTheme.headline4),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${_formatDate(settings.updatedAt)} by ${settings.updatedBy}',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
              ),
              const SizedBox(height: 24),
              
              // Maintenance Mode
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.construction, color: AppTheme.warningColor),
                          const SizedBox(width: 12),
                          Text('Maintenance Mode', style: AppTheme.headline6),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enable this to prevent users from accessing the app',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Maintenance Mode'),
                        subtitle: Text(
                          settings.maintenanceMode ? 'App is currently locked' : 'App is accessible',
                        ),
                        value: settings.maintenanceMode,
                        activeColor: AppTheme.warningColor,
                        onChanged: (value) {
                          _toggleMaintenanceMode(value, adminProvider);
                        },
                      ),
                      if (settings.maintenanceMode && settings.maintenanceMessage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Message: ${settings.maintenanceMessage}'),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Registration Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_add, color: AppTheme.infoColor),
                          const SizedBox(width: 12),
                          Text('Registration Settings', style: AppTheme.headline6),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Allow New Registrations'),
                        subtitle: const Text('Users can create new accounts'),
                        value: settings.allowNewRegistrations,
                        onChanged: (value) {
                          // Update setting
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Require Email Verification'),
                        subtitle: const Text('Users must verify email before login'),
                        value: settings.requireEmailVerification,
                        onChanged: (value) {
                          // Update setting
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Feature Flags
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.toggle_on, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text('Feature Flags', style: AppTheme.headline6),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enable or disable features without deploying new code',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
                      ),
                      const SizedBox(height: 16),
                      ...settings.featureFlags.entries.map((entry) {
                        return SwitchListTile(
                          title: Text(_formatFeatureName(entry.key)),
                          subtitle: Text(entry.value ? 'Enabled' : 'Disabled'),
                          value: entry.value,
                          onChanged: (value) {
                            adminProvider.updateFeatureFlag(entry.key, value);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Limits & Quotas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: AppTheme.successColor),
                          const SizedBox(width: 12),
                          Text('Limits & Quotas', style: AppTheme.headline6),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLimitRow(
                        'Max Children per Parent',
                        settings.maxChildrenPerParent,
                      ),
                      _buildLimitRow(
                        'Max Classes per Coach',
                        settings.maxClassesPerCoach,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Danger Zone
              Card(
                color: AppTheme.errorColor.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: AppTheme.errorColor),
                          const SizedBox(width: 12),
                          Text(
                            'Danger Zone',
                            style: AppTheme.headline6.copyWith(color: AppTheme.errorColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AdminDataCleanupDialog(),
                          );
                        },
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Clean Platform Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will delete all users, tasks, and classes. Cannot be undone!',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          ),
          Text(value, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyLarge),
          Row(
            children: [
              Text(value.toString(), style: AppTheme.headline6),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                onPressed: () {
                  // Edit limit
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFeatureName(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _toggleMaintenanceMode(bool enabled, AdminProvider adminProvider) {
    if (enabled) {
      final messageController = TextEditingController(
        text: 'We are currently performing maintenance. Please check back soon!',
      );
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Maintenance Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will lock all users out of the app.'),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message to display',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                adminProvider.toggleMaintenanceMode(true, messageController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Maintenance mode enabled'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
    } else {
      adminProvider.toggleMaintenanceMode(false, null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Maintenance mode disabled'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Clear All Data?'),
        content: const Text(
          'This will permanently delete:\n\n'
          '• All users\n'
          '• All tasks\n'
          '• All classes\n'
          '• All enrollments\n'
          '• All messages\n\n'
          'This action CANNOT be undone!\n\n'
          'Type "DELETE ALL" to confirm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon - requires additional confirmation'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}

