import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'utils/app_config.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/children_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/classes_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/messaging_provider.dart';
import 'providers/admin_provider.dart';
import 'models/user_model.dart';
import 'models/task_model.dart';
import 'models/class_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/dashboard/parent_dashboard_screen.dart';
import 'screens/dashboard/child_dashboard_screen.dart';
import 'screens/dashboard/coach_dashboard_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/coach_calendar_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/share/share_screen.dart';
import 'screens/tasks/create_task_wizard.dart';
import 'screens/tasks/child_task_view_screen.dart';
import 'screens/children/add_edit_child_screen.dart';
import 'screens/settings/points_settings_screen.dart';
import 'screens/ledger/financial_ledger_screen.dart';
import 'screens/landing/landing_screen_v3.dart';
import 'screens/classes/create_class_wizard.dart';
import 'screens/coach/coach_profile_screen.dart';
import 'screens/coach/enhanced_coach_profile_wizard.dart';
import 'screens/coach/quick_start_coach_wizard.dart';
import 'screens/classes/intelligent_class_wizard.dart';
import 'screens/students/student_grouping_screen.dart';
import 'screens/coach/coach_financial_dashboard.dart';
import 'screens/communication/coach_updates_screen.dart';
import 'screens/coach/enhanced_public_coach_page.dart';
import 'screens/coach/manage_students_screen.dart';
import 'screens/classes/browse_classes_modern.dart';
import 'screens/classes/class_detail_screen.dart';
import 'screens/attendance/mark_attendance_screen.dart';
import 'screens/payments/payment_dashboard_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/messaging/messages_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/legal/privacy_policy_screen.dart';
import 'screens/legal/terms_of_service_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/about/timeline_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => ClassesProvider()..loadClasses()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
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
          builder: (context, state) => const LandingScreenV3(),
        ),
        GoRoute(
          path: '/splash',
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
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
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
          path: '/child-tasks',
          builder: (context, state) => const ChildTaskViewScreen(),
        ),
        GoRoute(
          path: '/coach-dashboard',
          builder: (context, state) => const CoachDashboardScreen(),
        ),
        GoRoute(
          path: '/coach-quick-start',
          builder: (context, state) => const QuickStartCoachWizard(),
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
          path: '/coach-calendar',
          builder: (context, state) => const CoachCalendarScreen(),
        ),
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const FeedbackScreen(),
        ),
        GoRoute(
          path: '/share',
          builder: (context, state) => const ShareScreen(),
        ),
        GoRoute(
          path: '/create-task',
          builder: (context, state) {
            final taskId = state.uri.queryParameters['taskId'];
            Task? existingTask;
            if (taskId != null) {
              final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
              try {
                existingTask = tasksProvider.tasks.firstWhere((t) => t.id == taskId);
              } catch (e) {
                // Task not found, will create new
              }
            }
            return CreateTaskWizard(existingTask: existingTask);
          },
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
        GoRoute(
          path: '/create-class',
          builder: (context, state) {
            final classId = state.uri.queryParameters['classId'];
            Class? existingClass;
            if (classId != null) {
              final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
              try {
                existingClass = classesProvider.classes.firstWhere((c) => c.id == classId);
              } catch (e) {
                // Class not found, will create new
              }
            }
            return IntelligentClassWizard(existingClass: existingClass);
          },
        ),
        GoRoute(
          path: '/create-class-old',
          builder: (context, state) {
            final classId = state.uri.queryParameters['classId'];
            Class? existingClass;
            if (classId != null) {
              final classesProvider = Provider.of<ClassesProvider>(context, listen: false);
              try {
                existingClass = classesProvider.classes.firstWhere((c) => c.id == classId);
              } catch (e) {
                // Class not found
              }
            }
            return CreateClassWizard(existingClass: existingClass); // Keep old as backup
          },
        ),
        GoRoute(
          path: '/coach-profile',
          builder: (context, state) => const EnhancedCoachProfileWizard(),
        ),
        GoRoute(
          path: '/coach-profile-old',
          builder: (context, state) => const CoachProfileScreen(), // Keep old as backup
        ),
        GoRoute(
          path: '/manage-students',
          builder: (context, state) => const StudentGroupingScreen(),
        ),
        GoRoute(
          path: '/manage-students-old',
          builder: (context, state) => const ManageStudentsScreen(), // Keep old as backup
        ),
        GoRoute(
          path: '/coach-business',
          builder: (context, state) => const CoachFinancialDashboard(),
        ),
        GoRoute(
          path: '/coach-updates',
          builder: (context, state) => const CoachUpdatesScreen(),
        ),
        GoRoute(
          path: '/coach/:coachId',
          builder: (context, state) {
            final coachId = state.pathParameters['coachId']!;
            return EnhancedPublicCoachPage(coachId: coachId);
          },
        ),
        
        // Class Management Routes
        GoRoute(
          path: '/browse-classes',
          builder: (context, state) => const BrowseClassesModern(),
        ),
        GoRoute(
          path: '/marketplace',
          builder: (context, state) => const MarketplaceScreen(),
        ),
        GoRoute(
          path: '/class-detail',
          builder: (context, state) => ClassDetailScreen(
            classItem: state.extra as Class,
          ),
        ),
        GoRoute(
          path: '/mark-attendance',
          builder: (context, state) => MarkAttendanceScreen(
            classItem: state.extra as Class,
          ),
        ),
        
        // Financial & Analytics Routes
        GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentDashboardScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsDashboardScreen(),
        ),
        
        // Achievements & Messaging Routes
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
        
        // Legal Routes
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsOfServiceScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/timeline',
          builder: (context, state) => const TimelineScreen(),
        ),
        
        // Admin Routes
        GoRoute(
          path: '/admin/login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        // Skip all redirect logic for admin routes
        if (state.matchedLocation.startsWith('/admin/')) {
          return null; // Allow admin routes to handle their own auth
        }
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isLoggedIn;
        final isOnboarding = authProvider.isOnboarding;
        final currentUser = authProvider.currentUser;
        
        // Allow landing page and auth pages for non-logged-in users
        final publicPaths = ['/', '/login', '/register', '/forgot-password', '/email-verification', '/coach/', '/privacy', '/terms', '/about', '/timeline', '/browse-classes', '/marketplace'];
        final isPublicPath = publicPaths.any((path) => state.matchedLocation.startsWith(path));
        
        // If not logged in and not on public pages, redirect to landing
        if (!isLoggedIn && !isPublicPath) {
          return '/';
        }
        
        // If logged in, handle welcome screen and redirects
        if (isLoggedIn && currentUser != null) {
          final hasSeenWelcome = currentUser.preferences['hasSeenWelcome'] ?? false;
          
          // First priority: if they haven't seen welcome, show it
          if (!hasSeenWelcome && state.matchedLocation != '/welcome') {
            return '/welcome';
          }
          
          // If they're on homepage (/) or auth pages, redirect to their dashboard
          if (hasSeenWelcome) {
            if (state.matchedLocation == '/' ||
                state.matchedLocation.startsWith('/login') || 
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
                case UserType.admin:
                  return '/admin/dashboard';
                default:
                  return '/';
              }
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