import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              const Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildWelcomeSection(),
                          ),
                          const SizedBox(width: 60),
                          SizedBox(
                            width: 480,
                            child: _buildLoginCard(),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildWelcomeSection(),
                          const SizedBox(height: AppTheme.spacingXL),
                          _buildLoginCard(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Logo
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppTheme.spacingXL),
        
        Text(
          'Welcome Back! 👋',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        Text(
          'Continue your learning journey',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXL),
        
        // Features list
        _buildFeatureRow(Icons.star, 'Track your progress'),
        const SizedBox(height: AppTheme.spacingM),
        _buildFeatureRow(Icons.emoji_events, 'Earn achievements'),
        const SizedBox(height: AppTheme.spacingM),
        _buildFeatureRow(Icons.people, 'Connect with coaches'),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 24,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign In',
                style: AppTheme.headline4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your credentials to access your account',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.neutral600,
                ),
              ),
              const SizedBox(height: 32),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'you@example.com',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                  ),
                  filled: true,
                  fillColor: AppTheme.neutral50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.neutral200, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
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
              const SizedBox(height: 20),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock_outlined, color: AppTheme.primaryColor),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.neutral500,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppTheme.neutral50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.neutral200, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Sign In Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.neutral300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'New to Sparktracks?',
                      style: TextStyle(color: AppTheme.neutral500, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.neutral300)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sign Up Button
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: AppTheme.primaryColor, width: 2),
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Check if this is an admin trying to login
      final email = _emailController.text.trim();
      if (email == 'admin@sparktracks.com') {
        // Redirect to admin login page
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Admin users must use the Admin Portal login'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            context.go('/admin/login');
          }
        }
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(email, _passwordController.text);
      
      if (authProvider.isLoggedIn) {
        if (mounted) {
          // Show success animation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Welcome back! 🎉'),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          
          // Redirect based on user type
          final userType = authProvider.currentUser?.type;
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            switch (userType) {
              case UserType.parent:
                context.go('/parent-dashboard');
                break;
              case UserType.child:
                context.go('/child-dashboard');
                break;
              case UserType.coach:
                context.go('/coach-dashboard');
                break;
              default:
                context.go('/parent-dashboard');
            }
          }
        }
      } else if (authProvider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(authProvider.error!)),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }
}
