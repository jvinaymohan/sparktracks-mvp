import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      boxShadow: AppTheme.shadowLarge,
                    ),
                    child: const Icon(
                      Icons.email,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  Text(
                    'Verify Your Email',
                    style: AppTheme.headline1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  
                  Text(
                    'We sent a verification code to your email',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Verification Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _tokenController,
                              decoration: const InputDecoration(
                                labelText: 'Verification Code',
                                prefixIcon: Icon(Icons.verified_user),
                                hintText: 'Enter the 6-digit code',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the verification code';
                                }
                                if (value.length != 6) {
                                  return 'Code must be 6 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                            
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _handleVerification,
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Verify Email'),
                                );
                              },
                            ),
                            
                            const SizedBox(height: AppTheme.spacingM),
                            
                            TextButton(
                              onPressed: () {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                authProvider.sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Verification email sent!')),
                                );
                              },
                              child: const Text('Resend Code'),
                            ),
                            
                            const SizedBox(height: AppTheme.spacingM),
                            
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Back to Login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerification() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.verifyEmail(_tokenController.text);
      
      if (authProvider.currentUser?.emailVerified == true) {
        if (mounted) {
          context.go('/onboarding');
        }
      } else if (authProvider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error!)),
          );
        }
      }
    }
  }
}
