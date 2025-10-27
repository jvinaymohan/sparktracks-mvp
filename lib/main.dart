import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'utils/app_config.dart';
import 'utils/app_theme.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/dashboard/parent_dashboard_screen.dart';
import 'screens/dashboard/child_dashboard_screen.dart';
import 'screens/dashboard/coach_dashboard_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/tasks/create_task_screen.dart';
import 'screens/children/add_edit_child_screen.dart';
import 'screens/settings/points_settings_screen.dart';
import 'screens/ledger/financial_ledger_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: AppConfig.firebaseApiKey,
      appId: AppConfig.firebaseAppId,
      messagingSenderId: AppConfig.firebaseMessagingSenderId,
      projectId: AppConfig.firebaseProjectId,
    ),
  );
  
  runApp(const SparktracksMVP());
}

class SparktracksMVP extends StatelessWidget {
  const SparktracksMVP({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routerConfig: _buildRouter(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.neutral900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTheme.headline6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppTheme.primaryButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppTheme.secondaryButtonStyle,
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppTheme.textButtonStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        filled: true,
        fillColor: AppTheme.neutral50,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        color: AppTheme.surfaceColor,
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        // Public routes
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/email-verification',
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        
        // Protected routes
        GoRoute(
          path: '/parent-dashboard',
          builder: (context, state) => const ParentDashboardScreen(),
        ),
        GoRoute(
          path: '/child-dashboard',
          builder: (context, state) => const ChildDashboardScreen(),
        ),
        GoRoute(
          path: '/coach-dashboard',
          builder: (context, state) => const CoachDashboardScreen(),
        ),
        GoRoute(
          path: '/notification-settings',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const FeedbackScreen(),
        ),
        GoRoute(
          path: '/create-task',
          builder: (context, state) => const CreateTaskScreen(),
        ),
        GoRoute(
          path: '/add-child',
          builder: (context, state) => const AddEditChildScreen(),
        ),
        GoRoute(
          path: '/edit-child',
          builder: (context, state) => const AddEditChildScreen(), // Pass child data via state.extra
        ),
        GoRoute(
          path: '/points-settings',
          builder: (context, state) => const PointsSettingsScreen(),
        ),
        GoRoute(
          path: '/financial-ledger',
          builder: (context, state) {
            final userType = state.uri.queryParameters['userType'] ?? 'parent';
            return FinancialLedgerScreen(userType: userType);
          },
        ),
      ],
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isLoggedIn;
        final isOnboarding = authProvider.isOnboarding;
        
        // If not logged in and not on auth pages, redirect to login
        if (!isLoggedIn && !state.matchedLocation.startsWith('/login') && 
            !state.matchedLocation.startsWith('/register') && 
            !state.matchedLocation.startsWith('/email-verification')) {
          return '/login';
        }
        
        // If logged in but needs onboarding, redirect to onboarding
        if (isLoggedIn && isOnboarding && state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        
        // If logged in and on auth pages, redirect to appropriate dashboard
        if (isLoggedIn && !isOnboarding) {
          if (state.matchedLocation.startsWith('/login') || 
              state.matchedLocation.startsWith('/register') ||
              state.matchedLocation.startsWith('/email-verification')) {
            final userType = authProvider.currentUser?.type;
            switch (userType) {
              case UserType.parent:
                return '/parent-dashboard';
              case UserType.child:
                return '/child-dashboard';
              case UserType.coach:
                return '/coach-dashboard';
              default:
                return '/onboarding';
            }
          }
        }
        
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Check authentication status after animation
    Future.delayed(const Duration(seconds: 3), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      boxShadow: AppTheme.shadowLarge,
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // App Name
                  Text(
                    AppConfig.appName,
                    style: AppTheme.headline1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // App Description
                  Text(
                    AppConfig.appDescription,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Loading Indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 