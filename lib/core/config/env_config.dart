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

  /// Get Firebase API Key for iOS from environment or fallback to default
  static String get firebaseApiKeyIos {
    return const String.fromEnvironment(
      'FIREBASE_API_KEY_IOS',
      defaultValue: 'AIzaSyB-_LDr0UQ--za0akJLIWFZX6_7O8GcAtI', // iOS API Key from GoogleService-Info.plist
    );
  }

  /// Get Firebase App ID from environment or fallback to default (Web)
  static String get firebaseAppId {
    return const String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '1:541040481650:web:f50cb079c07203a7ca79eb', // Web App ID
    );
  }

  /// Get Firebase API Key for Android from environment or fallback to default
  static String get firebaseApiKeyAndroid {
    return const String.fromEnvironment(
      'FIREBASE_API_KEY_ANDROID',
      defaultValue: 'AIzaSyCAnvEAmEv0FfSQUPEEW7q3oCFE0dVY_K4', // Android API Key from google-services.json
    );
  }

  /// Get Firebase App ID for Android from environment or fallback to default
  static String get firebaseAppIdAndroid {
    return const String.fromEnvironment(
      'FIREBASE_APP_ID_ANDROID',
      defaultValue: '1:541040481650:android:ae2d244afe0c974fca79eb', // Android App ID from google-services.json
    );
  }

  /// Get Firebase App ID for iOS from environment or fallback to default
  static String get firebaseAppIdIos {
    return const String.fromEnvironment(
      'FIREBASE_APP_ID_IOS',
      defaultValue: '1:541040481650:ios:82bbe3c64c6b5caaca79eb', // iOS App ID from GoogleService-Info.plist
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
      defaultValue: 'com.rektech.surveyor', // Development fallback
    );
  }
}