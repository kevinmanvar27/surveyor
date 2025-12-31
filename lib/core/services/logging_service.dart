import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging service for the application
class LoggingService {
  static const String _appName = 'Surveyor';
  
  /// Log an info message
  static void info(String message, {String? name, Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _appName,
        level: 800, // Info level
        error: error,
      );
    }
  }
  
  /// Log a warning message
  static void warning(String message, {String? name, Object? error}) {
    developer.log(
      message,
      name: name ?? _appName,
      level: 900, // Warning level
      error: error,
    );
  }
  
  /// Log an error message
  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name ?? _appName,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log a debug message (only in debug mode)
  static void debug(String message, {String? name, Object? error}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: name ?? _appName,
        level: 700, // Debug level
        error: error,
      );
    }
  }
  
  /// Log Firebase-related errors with consistent formatting
  static void firebaseError(
    String operation,
    Object error, {
    StackTrace? stackTrace,
    String? userId,
  }) {
    final message = 'Firebase $operation failed${userId != null ? ' for user $userId' : ''}';
    LoggingService.error(
      message,
      name: 'Firebase',
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log authentication events
  static void authEvent(String event, {String? userId, Object? error}) {
    if (error != null) {
      LoggingService.error(
        'Auth $event failed',
        name: 'Auth',
        error: error,
      );
    } else {
      LoggingService.info(
        'Auth $event${userId != null ? ' for user $userId' : ''}',
        name: 'Auth',
      );
    }
  }
  
  /// Log survey operations
  static void surveyEvent(String event, {String? surveyId, Object? error}) {
    if (error != null) {
      LoggingService.error(
        'Survey $event failed${surveyId != null ? ' for survey $surveyId' : ''}',
        name: 'Survey',
        error: error,
      );
    } else {
      LoggingService.info(
        'Survey $event${surveyId != null ? ' for survey $surveyId' : ''}',
        name: 'Survey',
      );
    }
  }
}