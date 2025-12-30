import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'env_config.dart';

/// Firebase configuration options for surveyor-90246
/// 
/// SECURITY NOTE: In production, these values should be loaded from
/// environment variables or secure configuration files.
/// For development, these are kept here for convenience.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web Firebase Options
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    authDomain: EnvConfig.firebaseAuthDomain,
    storageBucket: EnvConfig.firebaseStorageBucket,
    measurementId: EnvConfig.firebaseMeasurementId,
  );

  /// Android Firebase Options
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKeyAndroid,
    appId: EnvConfig.firebaseAppIdAndroid,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
  );

  /// iOS Firebase Options
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKeyIos,
    appId: EnvConfig.firebaseAppIdIos,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
    iosBundleId: EnvConfig.iosBundleId,
  );

  /// macOS Firebase Options
  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKeyIos,
    appId: EnvConfig.firebaseAppIdIos,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    storageBucket: EnvConfig.firebaseStorageBucket,
    iosBundleId: EnvConfig.iosBundleId,
  );
}
