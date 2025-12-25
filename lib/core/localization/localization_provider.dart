import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en', 'US')) {
    _loadSavedLocale();
  }
  
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(AppConstants.prefLocale);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      state = Locale(parts[0], parts.length > 1 ? parts[1] : '');
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefLocale,
      '${locale.languageCode}_${locale.countryCode ?? ''}',
    );
  }
  
  void setEnglish() => setLocale(const Locale('en', 'US'));
  void setHindi() => setLocale(const Locale('hi', 'IN'));
  void setGujarati() => setLocale(const Locale('gu', 'IN'));
}
