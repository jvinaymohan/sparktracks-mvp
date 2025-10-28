import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _emailSent ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Icon(
            Icons.lock_reset,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Title
          Text(
            'Forgot Password?',
            style: AppTheme.headline4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Subtitle
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Reset Link'),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Back to login
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 80,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXL),
        
        // Title
        Text(
          'Check Your Email',
          style: AppTheme.headline4,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        // Message
        Text(
          'We\'ve sent password reset instructions to:',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.neutral600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          _emailController.text,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXL),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Next Steps:',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                '1. Check your email inbox\n'
                '2. Click the reset link in the email\n'
                '3. Create a new password\n'
                '4. Log in with your new password',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingXL),
        
        // Didn't receive email
        Text(
          'Didn\'t receive the email?',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.neutral600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingS),
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('Try Again'),
        ),
        const SizedBox(height: AppTheme.spacingL),
        
        // Back to login
        OutlinedButton(
          onPressed: () => context.go('/login'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
          ),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}

