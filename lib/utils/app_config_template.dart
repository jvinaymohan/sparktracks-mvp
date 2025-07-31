// Copy this file to app_config.dart and fill in your credentials
class AppConfig {
  // App Information
  static const String appName = 'Sparktracks MVP';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Comprehensive Learning Management Platform';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'your-firebase-project-id';
  static const String firebaseApiKey = 'your-firebase-api-key';
  static const String firebaseAppId = 'your-firebase-app-id';
  static const String firebaseMessagingSenderId = 'your-sender-id';
  
  // Supabase Configuration
  static const String supabaseUrl = 'your-supabase-url';
  static const String supabaseAnonKey = 'your-supabase-anon-key';
  
  // SendGrid Configuration
  static const String sendGridApiKey = 'your-sendgrid-api-key';
  static const String sendGridFromEmail = 'noreply@yourdomain.com';
  static const String sendGridFromName = 'Your App Name';
  
  // Twilio Configuration
  static const String twilioAccountSid = 'your-twilio-account-sid';
  static const String twilioAuthToken = 'your-twilio-auth-token';
  static const String twilioFromNumber = 'your-twilio-phone-number';
  
  // API Endpoints
  static const String baseApiUrl = 'https://api.yourdomain.com';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String classesEndpoint = '/classes';
  static const String paymentsEndpoint = '/payments';
  static const String notificationsEndpoint = '/notifications';
  
  // Feature Flags
  static const bool enableEmailNotifications = true;
  static const bool enableSmsNotifications = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Notification Settings
  static const int maxEmailPerDay = 1000;
  static const int maxSmsPerDay = 500;
  static const Duration emailCooldown = Duration(minutes: 5);
  static const Duration smsCooldown = Duration(minutes: 10);
  
  // Payment Settings
  static const String defaultCurrency = 'USD';
  static const double defaultPointsToDollarRatio = 100.0;
  static const int maxPaymentRetries = 3;
  
  // Security Settings
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Development Settings
  static const bool isDevelopment = true;
  static const bool enableDebugLogging = true;
  static const bool enableMockData = false;
} 