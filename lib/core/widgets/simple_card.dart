import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';

class SimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final bool hasBlur;
  final bool hasShadow;
  final double? elevation;

  const SimpleCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.hasBlur = false,
    this.hasShadow = true,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // iOS-style shadow
    final boxShadow = hasShadow ? [
      BoxShadow(
        color: isDark ? AppColors.darkShadow : AppColors.shadow,
        offset: const Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: isDark 
            ? AppColors.darkShadow.withOpacity(0.1) 
            : AppColors.shadow.withOpacity(0.05),
        offset: const Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ] : null;

    final cardColor = color ?? (isDark ? AppColors.darkSurface : AppColors.surface);

    Widget cardWidget = Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
        boxShadow: boxShadow,
        border: isDark 
            ? Border.all(color: AppColors.darkOutline, width: 0.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
          splashColor: isDark 
              ? AppColors.darkPrimary.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          highlightColor: isDark 
              ? AppColors.darkPrimary.withOpacity(0.05)
              : AppColors.primary.withOpacity(0.05),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

// iOS-style Grouped Card (for settings-like lists)
class GroupedCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final String? title;
  final String? footer;

  const GroupedCard({
    super.key,
    required this.children,
    this.margin,
    this.title,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 
              AppSpacing.lg, 
              AppSpacing.md, 
              AppSpacing.sm,
            ),
            child: Text(
              title!.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
        Container(
          margin: margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
            border: isDark 
                ? Border.all(color: AppColors.darkOutline, width: 0.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.shadow,
                offset: const Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
            child: Column(
              children: children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                
                return Column(
                  children: [
                    child,
                    if (index < children.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: AppSpacing.md,
                        color: isDark ? AppColors.darkDivider : AppColors.divider,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        if (footer != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 
              AppSpacing.sm, 
              AppSpacing.md, 
              AppSpacing.lg,
            ),
            child: Text(
              footer!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}