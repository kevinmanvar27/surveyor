import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, loc.appearance, Icons.palette_outlined),
          const SizedBox(height: 8),
          _buildThemeCard(context, ref, loc, currentThemeMode, isDark),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(context, loc.language, Icons.language_outlined),
          const SizedBox(height: 8),
          _buildLanguageCard(context, ref, loc, currentLocale, isDark),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader(context, loc.account, Icons.person_outline),
          const SizedBox(height: 8),
          _buildAccountCard(context, ref, loc, isDark),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, loc.about, Icons.info_outline),
          const SizedBox(height: 8),
          _buildAboutCard(context, loc, isDark),
          const SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(context, ref, loc, isDark),
          const SizedBox(height: 32),

          // App Version
          Center(
            child: Text(
              '${loc.version} ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    ThemeMode currentThemeMode,
    bool isDark,
  ) {
    final autoSunset = ref.watch(autoSunsetModeProvider);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            ref,
            loc.lightMode,
            Icons.light_mode_outlined,
            ThemeMode.light,
            currentThemeMode == ThemeMode.light && !autoSunset,
            isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildThemeOption(
            context,
            ref,
            loc.darkMode,
            Icons.dark_mode_outlined,
            ThemeMode.dark,
            currentThemeMode == ThemeMode.dark && !autoSunset,
            isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildThemeOption(
            context,
            ref,
            loc.systemDefault,
            Icons.settings_suggest_outlined,
            ThemeMode.system,
            currentThemeMode == ThemeMode.system && !autoSunset,
            isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildAutoSunsetOption(context, ref, loc, autoSunset, isDark),
        ],
      ),
    );
  }
  
  Widget _buildAutoSunsetOption(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    bool isEnabled,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        ref.read(autoSunsetModeProvider.notifier).toggle();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.wb_twilight,
              size: 22,
              color: isEnabled
                  ? Theme.of(context).primaryColor
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto (Sunset)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                  Text(
                    'Automatically switch to dark mode at sunset',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (value) {
                ref.read(autoSunsetModeProvider.notifier).setAutoSunset(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String themeName,
    IconData icon,
    ThemeMode themeMode,
    bool isSelected,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        // Disable auto-sunset when manually selecting a theme
        ref.read(autoSunsetModeProvider.notifier).setAutoSunset(false);
        ref.read(themeModeProvider.notifier).setThemeMode(themeMode);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                themeName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
    Locale currentLocale,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _buildLanguageOption(
            context,
            ref,
            'English',
            'en',
            currentLocale.languageCode == 'en',
            isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildLanguageOption(
            context,
            ref,
            'हिंदी',
            'hi',
            currentLocale.languageCode == 'hi',
            isDark,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildLanguageOption(
            context,
            ref,
            'ગુજરાતી',
            'gu',
            currentLocale.languageCode == 'gu',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String languageName,
    String languageCode,
    bool isSelected,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              languageName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, AppLocalizations loc, bool isDark) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      _getInitials(user.displayName ?? user.email ?? 'U'),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user.displayName != null && user.displayName!.isNotEmpty)
                          Text(
                            user.displayName!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        if (user.email != null)
                          Text(
                            user.email!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                          ),
                        if (user.phoneNumber != null)
                          Text(
                            user.phoneNumber!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                loc.notLoggedIn,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, AppLocalizations loc, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _buildAboutItem(
            context,
            Icons.description_outlined,
            loc.termsOfService,
            isDark,
            () {
              // TODO: Navigate to Terms of Service
            },
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildAboutItem(
            context,
            Icons.privacy_tip_outlined,
            loc.privacyPolicy,
            isDark,
            () {
              // TODO: Navigate to Privacy Policy
            },
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          _buildAboutItem(
            context,
            Icons.help_outline,
            loc.helpAndSupport,
            isDark,
            () {
              // TODO: Navigate to Help & Support
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, AppLocalizations loc, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.05),
      child: InkWell(
        onTap: () => _showLogoutDialog(context, ref, loc),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                loc.logout,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(loc.logout),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
