class AppConstants {
  static const String appName = 'CityPulse';
  static const String appTagline = 'Real-time urban problem reporting & management';
  static const String version = '1.0.0';

  // Storage keys
  static const String keyOnboardingCompleted = 'cp_onboarding_completed';
  static const String keyAuthToken = 'cp_auth_token';
  static const String keyUserRole = 'cp_user_role';
  static const String keyUserId = 'cp_user_id';

  // Default coordinate (City Center)
  static const double defaultLat = 12.9716;
  static const double defaultLng = 77.5946;
  static const String defaultCityWard = 'Ward 4 • Downtown North';

  // Categories
  static const List<String> categories = [
    'Pothole',
    'Streetlight',
    'Garbage',
    'Water Leakage',
    'Traffic',
    'Other',
  ];

  // Priorities
  static const String priorityLow = 'LOW';
  static const String priorityMedium = 'MEDIUM';
  static const String priorityHigh = 'HIGH';
  static const String priorityCritical = 'CRITICAL';

  // Statuses
  static const String statusSubmitted = 'submitted';
  static const String statusVerified = 'verified';
  static const String statusAssigned = 'assigned';
  static const String statusInProgress = 'inProgress';
  static const String statusResolved = 'resolved';
  static const String statusRejected = 'rejected';
  static const String statusClosed = 'closed';

  // Assets
  static const String logoAsset = 'assets/images/app_logo.png';
  static const String splashAsset = 'assets/images/splash_screen.png';
  static const String onboarding1Asset = 'assets/images/onboarding_1.png';
  static const String onboarding2Asset = 'assets/images/onboarding_2.png';
  static const String onboarding3Asset = 'assets/images/onboarding_3.png';
  static const String citizenAvatarAsset = 'assets/images/citizen_avatar.png';
  static const String officerAvatarAsset = 'assets/images/officer_avatar.png';
  static const String potholeAsset = 'assets/images/pothole.png';
  static const String streetlightAsset = 'assets/images/streetlight.png';
  static const String garbageAsset = 'assets/images/garbage.png';
  static const String waterLeakageAsset = 'assets/images/water_leakage.png';
  static const String repairedRoadAsset = 'assets/images/repaired_road.png';
  static const String mapOverviewAsset = 'assets/images/map_overview.png';
  static const String mapNavigationAsset = 'assets/images/map_navigation.png';
}
