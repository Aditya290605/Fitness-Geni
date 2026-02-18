/// App-wide constants for Fitness Geni
class AppConstants {
  AppConstants._(); // Private constructor

  // App Branding
  static const String appName = 'Fitness Geni';
  static const String appTagline = 'Simple fitness & diet guidance';

  // Shared Preferences Keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyFirstLaunch = 'first_launch';

  // Navigation Routes (used by GoRouter)
  static const String routeSplash = '/splash';
  static const String routeGetStarted = '/get-started';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeOnboarding = '/onboarding';
  static const String routeMain = '/main';

  // Common Strings
  static const String comingSoon = 'Coming Soon';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';

  // Tab Labels
  static const String tabHome = 'Home';
  static const String tabStats = 'Stats';
  static const String tabFit = 'Fit';
  static const String tabProfile = 'Profile';

  // Validation Messages
  static const String errorEmptyField = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorPasswordMismatch = 'Passwords do not match';
  static const String errorPasswordTooShort =
      'Password must be at least 6 characters';

  // Auth Screen Messages
  static const String loginSubtitle = 'Welcome back to your fitness journey';
  static const String signupSubtitle = 'Start your fitness journey today';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
}
