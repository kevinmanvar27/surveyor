import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sunset_service.dart';

const String _prefThemeMode = 'theme_mode';
const String _prefAutoSunset = 'auto_sunset_mode';

/// Provider for the current theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Provider for auto-sunset mode setting
final autoSunsetModeProvider = StateNotifierProvider<AutoSunsetNotifier, bool>((ref) {
  return AutoSunsetNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedTheme();
  }
  
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_prefThemeMode);
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, mode.name);
  }
  
  void setLight() => setThemeMode(ThemeMode.light);
  void setDark() => setThemeMode(ThemeMode.dark);
  void setSystem() => setThemeMode(ThemeMode.system);
  
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setDark();
    } else if (state == ThemeMode.dark) {
      setLight();
    } else {
      // If system, switch to light
      setLight();
    }
  }
  
  /// Check if currently in dark mode
  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.dark) return true;
    if (state == ThemeMode.light) return false;
    // System mode - check platform brightness
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}

class AutoSunsetNotifier extends StateNotifier<bool> {
  final Ref _ref;
  final SunsetService _sunsetService = SunsetService.instance;
  
  AutoSunsetNotifier(this._ref) : super(false) {
    _loadSavedSetting();
  }
  
  Future<void> _loadSavedSetting() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true for auto-sunset mode
    final enabled = prefs.getBool(_prefAutoSunset) ?? true;
    state = enabled;
    
    if (enabled) {
      _startSunsetMonitoring();
    }
  }
  
  Future<void> setAutoSunset(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoSunset, enabled);
    
    if (enabled) {
      _startSunsetMonitoring();
    } else {
      _sunsetService.stopMonitoring();
    }
  }
  
  void toggle() => setAutoSunset(!state);
  
  void _startSunsetMonitoring() {
    _sunsetService.startMonitoring(
      onSunsetChange: (isDark) {
        if (state) {
          // Only auto-switch if auto-sunset is still enabled
          final themeNotifier = _ref.read(themeModeProvider.notifier);
          if (isDark) {
            themeNotifier.setDark();
          } else {
            themeNotifier.setLight();
          }
        }
      },
    );
  }
  
  @override
  void dispose() {
    _sunsetService.stopMonitoring();
    super.dispose();
  }
}

/// Extension to easily get theme info
extension ThemeModeExtension on ThemeMode {
  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
  
  String getLabel(BuildContext context) {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
