/// Environment configuration helper
/// 
/// This class provides a way to load configuration from environment variables
/// or fallback to default values for development.
class EnvConfig {
  /// Get Firebase API Key from environment or fallback to default
  static String get firebaseApiKey {
    return const String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'AIzaSyBIhm3YOb4lTiME7mafMgMPnCPpM-1lrvs', // Development fallback
    );
  }

  /// Get Firebase App ID from environment or fallback to default
  static String get firebaseAppId {
    return const String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '1:541040481650:web:f50cb079c07203a7ca79eb', // Development fallback
    );
  }

  /// Get Firebase Messaging Sender ID from environment or fallback to default
  static String get firebaseMessagingSenderId {
    return const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '541040481650', // Development fallback
    );
  }

  /// Get Firebase Project ID from environment or fallback to default
  static String get firebaseProjectId {
    return const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'surveyor-90246', // Development fallback
    );
  }

  /// Get Firebase Auth Domain from environment or fallback to default
  static String get firebaseAuthDomain {
    return const String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'surveyor-90246.firebaseapp.com', // Development fallback
    );
  }

  /// Get Firebase Storage Bucket from environment or fallback to default
  static String get firebaseStorageBucket {
    return const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'surveyor-90246.firebasestorage.app', // Development fallback
    );
  }

  /// Get Firebase Measurement ID from environment or fallback to default
  static String get firebaseMeasurementId {
    return const String.fromEnvironment(
      'FIREBASE_MEASUREMENT_ID',
      defaultValue: 'G-YF7KYQJK5F', // Development fallback
    );
  }

  /// Get iOS Bundle ID from environment or fallback to default
  static String get iosBundleId {
    return const String.fromEnvironment(
      'IOS_BUNDLE_ID',
      defaultValue: 'com.example.surveyor', // Development fallback
    );
  }
}