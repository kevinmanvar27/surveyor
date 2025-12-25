import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../theme_provider.dart';

class AppleThemeToggle extends ConsumerWidget {
  final bool showLabel;
  final bool isCompact;

  const AppleThemeToggle({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isCompact) {
      return _buildCompactToggle(context, ref, themeMode, isDark);
    }

    return _buildFullToggle(context, ref, themeMode, isDark);
  }

  Widget _buildCompactToggle(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusRound),
        border: isDark 
            ? Border.all(color: AppColors.darkOutline, width: 0.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context: context,
            ref: ref,
            icon: Icons.light_mode_outlined,
            isSelected: themeMode == ThemeMode.light,
            onTap: () => ref.read(themeModeProvider.notifier).setLight(),
            isDark: isDark,
          ),
          _buildToggleButton(
            context: context,
            ref: ref,
            icon: Icons.dark_mode_outlined,
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => ref.read(themeModeProvider.notifier).setDark(),
            isDark: isDark,
          ),
          _buildToggleButton(
            context: context,
            ref: ref,
            icon: Icons.brightness_auto_outlined,
            isSelected: themeMode == ThemeMode.system,
            onTap: () => ref.read(themeModeProvider.notifier).setSystem(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFullToggle(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.iosXs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
        border: isDark 
            ? Border.all(color: AppColors.darkOutline, width: 0.5)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.iosXs,
              ),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.iosXs),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFullToggleButton(
                context: context,
                ref: ref,
                icon: Icons.light_mode_outlined,
                label: 'Light',
                isSelected: themeMode == ThemeMode.light,
                onTap: () => ref.read(themeModeProvider.notifier).setLight(),
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.iosXs),
              _buildFullToggleButton(
                context: context,
                ref: ref,
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isSelected: themeMode == ThemeMode.dark,
                onTap: () => ref.read(themeModeProvider.notifier).setDark(),
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.iosXs),
              _buildFullToggleButton(
                context: context,
                ref: ref,
                icon: Icons.brightness_auto_outlined,
                label: 'Auto',
                isSelected: themeMode == ThemeMode.system,
                onTap: () => ref.read(themeModeProvider.notifier).setSystem(),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusRound),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iosIconMd,
          color: isSelected 
              ? Colors.white
              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildFullToggleButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusSm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.iosIconMd,
              color: isSelected 
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.iosXs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected 
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// iOS-style segmented control for theme switching
class AppleSegmentedThemeControl extends ConsumerWidget {
  const AppleSegmentedThemeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.iosXs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSystemGray6 : AppColors.systemGray6,
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            context: context,
            ref: ref,
            text: 'Light',
            isSelected: themeMode == ThemeMode.light,
            onTap: () => ref.read(themeModeProvider.notifier).setLight(),
            isDark: isDark,
          ),
          _buildSegment(
            context: context,
            ref: ref,
            text: 'Dark',
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => ref.read(themeModeProvider.notifier).setDark(),
            isDark: isDark,
          ),
          _buildSegment(
            context: context,
            ref: ref,
            text: 'Auto',
            isSelected: themeMode == ThemeMode.system,
            onTap: () => ref.read(themeModeProvider.notifier).setSystem(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required WidgetRef ref,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? AppColors.darkSurface : AppColors.surface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.iosRadiusXs),
            boxShadow: isSelected ? [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.shadow,
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? (isDark ? AppColors.darkOnSurface : AppColors.onSurface)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}