import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // LIGHT THEME - Apple Style Colors
  
  // Primary Colors - iOS Blue
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryVariant = Color(0xFF0056CC);
  static const Color primaryLight = Color(0xFF5AC8FA); // For backward compatibility
  static const Color primaryDark = Color(0xFF0040DD); // For backward compatibility
  
  // Secondary Colors - iOS Gray
  static const Color secondary = Color(0xFF8E8E93);
  static const Color secondaryVariant = Color(0xFF6D6D70);
  
  // Surface Colors - iOS Style
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F7);
  static const Color background = Color(0xFFF2F2F7);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  
  // Text Colors - iOS Style
  static const Color onSurface = Color(0xFF000000);
  static const Color onSurfaceVariant = Color(0xFF3C3C43);
  static const Color onBackground = Color(0xFF000000);
  static const Color onBackgroundSecondary = Color(0xFF3C3C43);
  
  // Legacy text colors for backward compatibility
  static const Color textPrimary = onSurface;
  static const Color textSecondary = Color(0xFF8E8E93);
  
  // Status Colors - iOS Style
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);
  
  // Status colors for surveys
  static const Color statusWorking = primary;
  static const Color statusWaiting = warning;
  static const Color statusDone = success;
  
  // Border & Outline - iOS Style
  static const Color outline = Color(0xFFC6C6C8);
  static const Color outlineVariant = Color(0xFFE5E5EA);
  static const Color border = outline; // For backward compatibility
  static const Color divider = Color(0xFFE5E5EA);
  static const Color shadow = Color(0x1A000000);
  
  // Card colors for backward compatibility
  static const Color cardSuccess = Color(0xFFF0FDF4);
  static const Color cardError = Color(0xFFFEF2F2);
  
  // iOS System Colors (Light)
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemPink = Color(0xFFFF2D92);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemYellow = Color(0xFFFFCC00);
  
  // iOS Gray Scale (Light)
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);
  
  // DARK THEME - Apple Style Colors
  
  // Primary Colors - iOS Blue (Dark)
  static const Color darkPrimary = Color(0xFF0A84FF);
  static const Color darkPrimaryVariant = Color(0xFF0056CC);
  
  // Secondary Colors - iOS Gray (Dark)
  static const Color darkSecondary = Color(0xFF8E8E93);
  static const Color darkSecondaryVariant = Color(0xFFAEAEB2);
  
  // Surface Colors - iOS Dark Style
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkBackgroundSecondary = Color(0xFF1C1C1E);
  
  // Text Colors - iOS Dark Style
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFFEBEBF5);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnBackgroundSecondary = Color(0xFFEBEBF5);
  
  // Legacy dark text colors for backward compatibility
  static const Color darkTextPrimary = darkOnSurface;
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  
  // Status Colors - iOS Dark Style
  static const Color darkSuccess = Color(0xFF30D158);
  static const Color darkWarning = Color(0xFFFF9F0A);
  static const Color darkError = Color(0xFFFF453A);
  static const Color darkInfo = Color(0xFF64D2FF);
  
  // Status colors for surveys (dark)
  static const Color darkStatusWorking = darkPrimary;
  static const Color darkStatusWaiting = darkWarning;
  static const Color darkStatusDone = darkSuccess;
  
  // Border & Outline - iOS Dark Style
  static const Color darkOutline = Color(0xFF38383A);
  static const Color darkOutlineVariant = Color(0xFF48484A);
  static const Color darkBorder = darkOutline; // For backward compatibility
  static const Color darkDivider = Color(0xFF38383A);
  static const Color darkShadow = Color(0x33000000);
  
  // Card colors for dark theme
  static const Color darkCardSuccess = Color(0xFF0D2818);
  static const Color darkCardError = Color(0xFF2D1B1B);
  
  // iOS System Colors (Dark)
  static const Color darkSystemBlue = Color(0xFF0A84FF);
  static const Color darkSystemGreen = Color(0xFF30D158);
  static const Color darkSystemIndigo = Color(0xFF5E5CE6);
  static const Color darkSystemOrange = Color(0xFFFF9F0A);
  static const Color darkSystemPink = Color(0xFFFF375F);
  static const Color darkSystemPurple = Color(0xFFBF5AF2);
  static const Color darkSystemRed = Color(0xFFFF453A);
  static const Color darkSystemTeal = Color(0xFF64D2FF);
  static const Color darkSystemYellow = Color(0xFFFFD60A);
  
  // iOS Dark Gray Scale
  static const Color darkSystemGray = Color(0xFF8E8E93);
  static const Color darkSystemGray2 = Color(0xFF636366);
  static const Color darkSystemGray3 = Color(0xFF48484A);
  static const Color darkSystemGray4 = Color(0xFF3A3A3C);
  static const Color darkSystemGray5 = Color(0xFF2C2C2E);
  static const Color darkSystemGray6 = Color(0xFF1C1C1E);
  
  // Gradients for backward compatibility
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF28A745)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Additional colors for backward compatibility
  static const Color darkTextHint = darkSystemGray;
}