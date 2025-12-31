/// App configuration settings
class AppConfig {
  AppConfig._();
  
  /// Set to true to use demo mode (no Firebase required)
  /// Set to false when Firebase is properly configured
  static const bool useDemoMode = false;
  
  /// Check if Firebase is configured (not using placeholder values)
  static bool get isFirebaseConfigured {
    // Will be false until real Firebase credentials are added
    return !useDemoMode;
  }
}
