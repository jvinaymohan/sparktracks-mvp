import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/navigation_helper.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _activityReminders = true;
  bool _progressUpdates = true;
  bool _paymentReminders = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    if (user?.notificationPreferences != null) {
      final prefs = user!.notificationPreferences!;
      setState(() {
        _emailNotifications = prefs.emailEnabled;
        _smsNotifications = prefs.smsEnabled;
        _pushNotifications = prefs.pushEnabled;
        _activityReminders = prefs.notificationSettings['class_reminders'] ?? true;
        _progressUpdates = prefs.notificationSettings['achievement_alerts'] ?? true;
        _paymentReminders = prefs.notificationSettings['payment_reminders'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
          onPressed: () => NavigationHelper.goToDashboard(context),
        ),
        actions: [
          NavigationHelper.buildGradientHomeButton(context),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        children: [
          // Notification Methods
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Methods',
                    style: AppTheme.headline6,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive updates via email'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('SMS Notifications'),
                    subtitle: const Text('Receive updates via text message'),
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() {
                        _smsNotifications = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive updates via push notifications'),
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Notification Types
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Types',
                    style: AppTheme.headline6,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  SwitchListTile(
                    title: const Text('Activity Reminders'),
                    subtitle: const Text('Reminders for upcoming activities'),
                    value: _activityReminders,
                    onChanged: (value) {
                      setState(() {
                        _activityReminders = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Progress Updates'),
                    subtitle: const Text('Updates on your progress and achievements'),
                    value: _progressUpdates,
                    onChanged: (value) {
                      setState(() {
                        _progressUpdates = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Payment Reminders'),
                    subtitle: const Text('Reminders for payments and billing'),
                    value: _paymentReminders,
                    onChanged: (value) {
                      setState(() {
                        _paymentReminders = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Save Button
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final preferences = NotificationPreferences(
      emailEnabled: _emailNotifications,
      smsEnabled: _smsNotifications,
      pushEnabled: _pushNotifications,
      notificationSettings: {
        'class_reminders': _activityReminders,
        'achievement_alerts': _progressUpdates,
        'payment_reminders': _paymentReminders,
        'weekly_summary': true,
        'security_alerts': true,
      },
    );
    
    await userProvider.updateNotificationPreferences(preferences);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }
}
