import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to calculate sunset time and determine if it's currently after sunset.
/// Uses a simplified calculation based on location (defaults to approximate sunset times).
class SunsetService {
  SunsetService._();
  
  static final SunsetService instance = SunsetService._();
  
  Timer? _sunsetCheckTimer;
  final _sunsetController = StreamController<bool>.broadcast();
  
  /// Stream that emits true when it becomes sunset/night time
  Stream<bool> get sunsetStream => _sunsetController.stream;
  
  /// Check if current time is after sunset
  /// Uses approximate sunset times based on month (for general use)
  bool isAfterSunset() {
    final now = DateTime.now();
    final sunsetTime = _getApproximateSunsetTime(now);
    final sunriseTime = _getApproximateSunriseTime(now);
    
    // It's dark if we're after sunset OR before sunrise
    return now.isAfter(sunsetTime) || now.isBefore(sunriseTime);
  }
  
  /// Get approximate sunset time for the current day
  /// This uses a simplified model - in production, you might want to use
  /// a proper astronomical calculation or API based on user's location
  DateTime _getApproximateSunsetTime(DateTime date) {
    // Approximate sunset hours by month (Northern Hemisphere, adjust for your region)
    // These are rough estimates - you can customize based on your target region
    final sunsetHours = <int, double>{
      1: 17.5,   // January: ~5:30 PM
      2: 18.0,   // February: ~6:00 PM
      3: 18.5,   // March: ~6:30 PM
      4: 19.5,   // April: ~7:30 PM
      5: 20.0,   // May: ~8:00 PM
      6: 20.5,   // June: ~8:30 PM
      7: 20.5,   // July: ~8:30 PM
      8: 20.0,   // August: ~8:00 PM
      9: 19.0,   // September: ~7:00 PM
      10: 18.0,  // October: ~6:00 PM
      11: 17.5,  // November: ~5:30 PM
      12: 17.0,  // December: ~5:00 PM
    };
    
    final hour = sunsetHours[date.month] ?? 18.0;
    final hourInt = hour.floor();
    final minutes = ((hour - hourInt) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hourInt, minutes);
  }
  
  /// Get approximate sunrise time for the current day
  DateTime _getApproximateSunriseTime(DateTime date) {
    // Approximate sunrise hours by month
    final sunriseHours = <int, double>{
      1: 7.0,    // January: ~7:00 AM
      2: 6.5,    // February: ~6:30 AM
      3: 6.0,    // March: ~6:00 AM
      4: 5.5,    // April: ~5:30 AM
      5: 5.0,    // May: ~5:00 AM
      6: 5.0,    // June: ~5:00 AM
      7: 5.0,    // July: ~5:00 AM
      8: 5.5,    // August: ~5:30 AM
      9: 6.0,    // September: ~6:00 AM
      10: 6.5,   // October: ~6:30 AM
      11: 6.5,   // November: ~6:30 AM
      12: 7.0,   // December: ~7:00 AM
    };
    
    final hour = sunriseHours[date.month] ?? 6.0;
    final hourInt = hour.floor();
    final minutes = ((hour - hourInt) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hourInt, minutes);
  }
  
  /// Start monitoring for sunset/sunrise transitions
  void startMonitoring({required void Function(bool isDark) onSunsetChange}) {
    // Check immediately
    final isDark = isAfterSunset();
    onSunsetChange(isDark);
    
    // Check every minute for sunset/sunrise transition
    _sunsetCheckTimer?.cancel();
    _sunsetCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final currentlyDark = isAfterSunset();
      onSunsetChange(currentlyDark);
      _sunsetController.add(currentlyDark);
    });
    
    debugPrint('SunsetService: Monitoring started. Currently ${isDark ? "dark" : "light"}');
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _sunsetCheckTimer?.cancel();
    _sunsetCheckTimer = null;
  }
  
  /// Get time until next sunset
  Duration? getTimeUntilSunset() {
    final now = DateTime.now();
    final sunset = _getApproximateSunsetTime(now);
    
    if (now.isBefore(sunset)) {
      return sunset.difference(now);
    }
    return null; // Already past sunset
  }
  
  /// Get time until next sunrise
  Duration? getTimeUntilSunrise() {
    final now = DateTime.now();
    var sunrise = _getApproximateSunriseTime(now);
    
    if (now.isAfter(sunrise)) {
      // Get tomorrow's sunrise
      sunrise = _getApproximateSunriseTime(now.add(const Duration(days: 1)));
    }
    
    return sunrise.difference(now);
  }
  
  void dispose() {
    stopMonitoring();
    _sunsetController.close();
  }
}
