class AppConstants {
  // App Information
  static const String appName = 'WellnessFlow';
  static const String appVersion = '1.0.0';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // API Endpoints
  static const String baseUrl = 'https://api.wellnessflow.com';

  // Local Storage Keys
  static const String userToken = 'user_token';
  static const String userPreferences = 'user_preferences';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String progressCollection = 'progress';
  static const String categoriesCollection = 'categories';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxBioLength = 200;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheExpiration = Duration(hours: 24);

  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Something went wrong, please try again';
  static const String authError = 'Authentication failed';
  static const String unknownError = 'An unexpected error occurred';
}
