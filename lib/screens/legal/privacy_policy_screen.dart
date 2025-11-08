import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sparktracks Privacy Policy',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: November 8, 2025',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 32),
            
            // Privacy Highlights Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user, color: AppTheme.successColor, size: 32),
                      const SizedBox(width: 12),
                      Text('Privacy-First Platform', style: AppTheme.headline5.copyWith(color: AppTheme.successColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sparktracks is built with your privacy and security in mind:',
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildPrivacyHighlight('🔒 Encrypted data transmission (HTTPS/TLS)'),
                  _buildPrivacyHighlight('🛡️ Role-based access control (parents, children, coaches)'),
                  _buildPrivacyHighlight('👨‍👩‍👧 Parents have full control over children\'s data'),
                  _buildPrivacyHighlight('🚫 No data selling - ever'),
                  _buildPrivacyHighlight('🔐 Secure authentication with Firebase'),
                  _buildPrivacyHighlight('👁️ Children\'s safety is our top priority'),
                  _buildPrivacyHighlight('📊 Transparent data practices'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              title: '1. Introduction',
              content: 'Welcome to Sparktracks. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our website or use our app.',
            ),
            
            _buildSection(
              title: '2. Information We Collect',
              content: 'We collect and process the following types of data:\n\n'
                  '• Account Information: Name, email address, and password when you register\n'
                  '• Profile Data: Photos, biographical information, experience, and qualifications\n'
                  '• Usage Data: How you interact with our platform\n'
                  '• Payment Information: Processed securely through our payment provider\n'
                  '• Communication Data: Messages and feedback you send us',
            ),
            
            _buildSection(
              title: '3. How We Use Your Information',
              content: 'We use your information to:\n\n'
                  '• Provide and maintain our services\n'
                  '• Process your transactions and manage payments\n'
                  '• Send you important updates and notifications\n'
                  '• Improve our platform and develop new features\n'
                  '• Respond to your requests and support needs\n'
                  '• Ensure security and prevent fraud',
            ),
            
            _buildSection(
              title: '4. Data Sharing',
              content: 'We do not sell your personal data. We may share your data with:\n\n'
                  '• Service providers who help us operate the platform\n'
                  '• Payment processors for transaction handling\n'
                  '• Other users as needed for platform functionality (e.g., coach profiles are visible to parents)',
            ),
            
            _buildSection(
              title: '5. Children\'s Privacy',
              content: 'We take special care with children\'s data:\n\n'
                  '• Children\'s profiles are created and managed by parents\n'
                  '• Limited information is collected for children\n'
                  '• Children\'s data is not used for marketing\n'
                  '• Parents have full control over their children\'s profiles',
            ),
            
            _buildSection(
              title: '6. Data Security',
              content: 'We implement appropriate security measures to protect your data:\n\n'
                  '• Encrypted connections (HTTPS/TLS)\n'
                  '• Secure authentication\n'
                  '• Regular security audits\n'
                  '• Restricted access to personal data',
            ),
            
            _buildSection(
              title: '7. Your Rights',
              content: 'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Delete your account and data\n'
                  '• Export your data\n'
                  '• Object to certain processing\n'
                  '• Withdraw consent',
            ),
            
            _buildSection(
              title: '8. Cookies',
              content: 'We use cookies and similar technologies to:\n\n'
                  '• Keep you signed in\n'
                  '• Remember your preferences\n'
                  '• Understand how you use our platform\n'
                  '• Improve your experience',
            ),
            
            _buildSection(
              title: '9. Data Retention',
              content: 'We retain your data for as long as your account is active or as needed to provide services. When you delete your account, we will delete or anonymize your data within 30 days, except where required by law.',
            ),
            
            _buildSection(
              title: '10. Changes to This Policy',
              content: 'We may update this privacy policy from time to time. We will notify you of any significant changes by email or through the platform.',
            ),
            
            _buildSection(
              title: '11. Contact Us',
              content: 'If you have any questions about this privacy policy or our data practices, please contact us at:\n\n'
                  'Email: privacy@sparktracks.com\n'
                  'Address: [Your Address]',
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For GDPR/CCPA compliance and legal requirements, please consult with a legal professional to customize this policy for your jurisdiction.',
                      style: AppTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headline6.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyHighlight(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTheme.bodyMedium,
      ),
    );
  }
}

