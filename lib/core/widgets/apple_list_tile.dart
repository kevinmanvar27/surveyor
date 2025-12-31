import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final bool showChevron;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;

  const AppleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.showChevron = false,
    this.backgroundColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.surface),
      child: InkWell(
        onTap: onTap,
        splashColor: isDark 
            ? AppColors.darkPrimary.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        highlightColor: isDark 
            ? AppColors.darkPrimary.withOpacity(0.05)
            : AppColors.primary.withOpacity(0.05),
        child: Container(
          padding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: !isLast ? Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.divider,
                width: 0.5,
              ),
            ) : null,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) title!,
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.iosXs),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null || showChevron) ...[
                const SizedBox(width: AppSpacing.sm),
                if (trailing != null) 
                  trailing!
                else if (showChevron)
                  Icon(
                    Icons.chevron_right,
                    size: AppSpacing.iosIconMd,
                    color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// iOS-style settings list tile with icon
class AppleSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool showChevron;

  const AppleSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: iconBackgroundColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary),
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusXs),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iosIconSm,
          color: iconColor ?? Colors.white,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      showChevron: showChevron && trailing == null,
      onTap: onTap,
    );
  }
}

// iOS-style toggle list tile
class AppleToggleTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const AppleToggleTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleListTile(
      leading: icon != null ? Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: iconBackgroundColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary),
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusXs),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iosIconSm,
          color: iconColor ?? Colors.white,
        ),
      ) : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      ),
      onTap: onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}

// iOS-style disclosure tile (with chevron)
class AppleDisclosureTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const AppleDisclosureTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleListTile(
      leading: icon != null ? Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: iconBackgroundColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary),
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusXs),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iosIconSm,
          color: iconColor ?? Colors.white,
        ),
      ) : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: value != null ? Text(
        value!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ) : null,
      showChevron: true,
      onTap: onTap,
    );
  }
}