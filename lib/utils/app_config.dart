class AppConfig {
  // App Information
  static const String appName = 'Sparktracks MVP';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Comprehensive Learning Management Platform';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'sparktracks-mvp';
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // SendGrid Configuration
  static const String sendGridApiKey = 'YOUR_SENDGRID_API_KEY';
  static const String sendGridFromEmail = 'noreply@sparktracks.com';
  static const String sendGridFromName = 'Sparktracks';
  
  // Twilio Configuration
  static const String twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  static const String twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  static const String twilioFromNumber = 'YOUR_TWILIO_PHONE_NUMBER';
  
  // API Endpoints
  static const String baseApiUrl = 'https://api.sparktracks.com';
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