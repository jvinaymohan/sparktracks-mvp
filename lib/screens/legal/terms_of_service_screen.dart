import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sparktracks Terms of Service',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: November 8, 2025',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing or using Sparktracks, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our platform.',
            ),
            
            _buildSection(
              title: '2. Description of Service',
              content: 'Sparktracks is a platform that connects parents, children, and coaches for managing activities, tasks, and classes. We provide tools for:\n\n'
                  '• Task management and tracking\n'
                  '• Class scheduling and enrollment\n'
                  '• Progress monitoring\n'
                  '• Payment processing\n'
                  '• Communication between parties',
            ),
            
            _buildSection(
              title: '3. User Accounts',
              content: 'To use our services, you must:\n\n'
                  '• Be at least 18 years old (for parent and coach accounts)\n'
                  '• Provide accurate and complete information\n'
                  '• Maintain the security of your password\n'
                  '• Notify us immediately of any unauthorized use\n'
                  '• Be responsible for all activities under your account',
            ),
            
            _buildSection(
              title: '4. User Roles and Responsibilities',
              content: '**Parents:**\n'
                  '• Create and manage child profiles\n'
                  '• Supervise children\'s use of the platform\n'
                  '• Review and approve tasks and activities\n'
                  '• Make payments for enrolled classes\n\n'
                  '**Coaches:**\n'
                  '• Provide accurate profile information\n'
                  '• Deliver services as advertised\n'
                  '• Maintain appropriate qualifications\n'
                  '• Ensure child safety in all interactions\n\n'
                  '**Children:**\n'
                  '• Use the platform under parent supervision\n'
                  '• Follow platform rules and guidelines',
            ),
            
            _buildSection(
              title: '5. Payments and Refunds',
              content: '• All payments are processed through our secure payment provider\n'
                  '• Coaches set their own pricing\n'
                  '• Platform fees apply to transactions (details provided at checkout)\n'
                  '• Refund policies are set by individual coaches\n'
                  '• Sparktracks is not responsible for disputes between users and coaches',
            ),
            
            _buildSection(
              title: '6. Content Guidelines',
              content: 'Users agree not to post content that:\n\n'
                  '• Violates any laws or regulations\n'
                  '• Infringes on intellectual property rights\n'
                  '• Contains harmful, offensive, or inappropriate material\n'
                  '• Impersonates another person or entity\n'
                  '• Contains viruses or malicious code',
            ),
            
            _buildSection(
              title: '7. Child Safety',
              content: 'We are committed to child safety:\n\n'
                  '• Coaches must comply with all applicable child protection laws\n'
                  '• Parents maintain full control over child accounts\n'
                  '• We do not facilitate direct messaging between children and non-parent adults\n'
                  '• Report any concerns to safety@sparktracks.com',
            ),
            
            _buildSection(
              title: '8. Prohibited Activities',
              content: 'You may not:\n\n'
                  '• Use the platform for any illegal purpose\n'
                  '• Harass, abuse, or harm other users\n'
                  '• Attempt to gain unauthorized access\n'
                  '• Scrape or copy content without permission\n'
                  '• Interfere with platform operations\n'
                  '• Create fake accounts or profiles',
            ),
            
            _buildSection(
              title: '9. Intellectual Property',
              content: 'The Sparktracks platform, including all content, features, and functionality, is owned by Sparktracks and protected by copyright, trademark, and other laws. You retain ownership of content you post, but grant us a license to use it for platform operations.',
            ),
            
            _buildSection(
              title: '10. Disclaimers',
              content: 'Sparktracks is provided "as is" without warranties of any kind. We do not:\n\n'
                  '• Guarantee uninterrupted or error-free service\n'
                  '• Verify the qualifications of all coaches\n'
                  '• Guarantee the quality of services provided by coaches\n'
                  '• Take responsibility for interactions between users',
            ),
            
            _buildSection(
              title: '11. Limitation of Liability',
              content: 'To the maximum extent permitted by law, Sparktracks shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the platform.',
            ),
            
            _buildSection(
              title: '12. Termination',
              content: 'We may suspend or terminate your account if you:\n\n'
                  '• Violate these Terms of Service\n'
                  '• Engage in fraudulent activity\n'
                  '• Pose a safety risk to other users\n'
                  '• Have not used the platform for an extended period\n\n'
                  'You may delete your account at any time from your settings.',
            ),
            
            _buildSection(
              title: '13. Changes to Terms',
              content: 'We reserve the right to modify these terms at any time. We will notify users of significant changes. Continued use of the platform after changes constitutes acceptance of the new terms.',
            ),
            
            _buildSection(
              title: '14. Dispute Resolution',
              content: 'Any disputes arising from these terms shall be resolved through:\n\n'
                  '1. Good faith negotiation\n'
                  '2. Mediation (if negotiation fails)\n'
                  '3. Binding arbitration\n\n'
                  'Governing Law: [Your Jurisdiction]',
            ),
            
            _buildSection(
              title: '15. Contact Information',
              content: 'For questions about these Terms of Service, contact us at:\n\n'
                  'Email: legal@sparktracks.com\n'
                  'Address: [Your Address]',
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppTheme.warningColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These terms are a template. Please consult with a legal professional to customize them for your specific business needs and jurisdiction.',
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
}

