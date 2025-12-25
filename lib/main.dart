import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_provider.dart';
import 'demo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if not in demo mode
  if (!AppConfig.useDemoMode) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      debugPrint('Running in demo mode due to Firebase configuration error.');
    }
  } else {
    debugPrint('Running in DEMO MODE - Firebase not initialized');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ProviderScope(child: SurveyorApp()));
}

class SurveyorApp extends ConsumerWidget {
  const SurveyorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Watch auto-sunset provider to ensure it's initialized
    // This triggers the sunset monitoring when enabled
    ref.watch(autoSunsetModeProvider);
    
    // Update system UI overlay style based on theme
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    
    // iOS-style system UI overlay
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.background,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Apple-style themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('gu', 'IN'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Routing - using routes instead of router for now
      initialRoute: '/',
      routes: {
        '/': (context) => const DemoScreen(),
      },
      
      // iOS-style scroll behavior
      scrollBehavior: const AppleScrollBehavior(),
      
      builder: (context, child) {
        // Ensure consistent text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

// iOS-style scroll behavior
class AppleScrollBehavior extends ScrollBehavior {
  const AppleScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // iOS-style bouncing scroll physics
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // iOS-style scrollbar
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: false,
      trackVisibility: false,
      thickness: 3.0,
      radius: const Radius.circular(1.5),
      child: child,
    );
  }
}