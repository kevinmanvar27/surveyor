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
  ThemeModeNotifier() : super(ThemeMode.light) {
    // Always use light theme as per requirements
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
  // Removed dark theme functionality as per requirements
  void setSystem() => setThemeMode(ThemeMode.system);
  
  void toggleTheme() {
    // Always stay in light theme as per requirements
    setLight();
  }
  
  /// Check if currently in dark mode
  bool isDarkMode(BuildContext context) {
    // Always return false as dark mode is disabled
    return false;
  }
}

class AutoSunsetNotifier extends StateNotifier<bool> {
  final Ref _ref;
  final SunsetService _sunsetService = SunsetService.instance;
  
  AutoSunsetNotifier(this._ref) : super(false) {
    // Don't load saved setting since auto-sunset is disabled in light-only theme
    // Always keep it disabled
    state = false;
  }
  
  // Removed _loadSavedSetting as auto-sunset is disabled in light-only theme
  
  Future<void> setAutoSunset(bool enabled) async {
    // Always keep auto-sunset disabled for light-only theme
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoSunset, false); // Always save as false
    
    // Always stop monitoring since we don't need it in light-only theme
    _sunsetService.stopMonitoring();
  }
  
  void toggle() {
    // Auto-sunset is always disabled in light-only theme
    setAutoSunset(false);
  }
  
  void _startSunsetMonitoring() {
    _sunsetService.startMonitoring(
      onSunsetChange: (isDark) {
        if (state) {
          // Only auto-switch if auto-sunset is still enabled
          final themeNotifier = _ref.read(themeModeProvider.notifier);
          // Always set to light mode as per light-only theme requirements
          themeNotifier.setLight();
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
