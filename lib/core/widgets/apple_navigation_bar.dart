import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppleNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;
  final bool showBorder;
  final PreferredSizeWidget? bottom;

  const AppleNavigationBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation,
    this.showBorder = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.background),
        border: showBorder ? Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 0.5,
          ),
        ) : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: AppSpacing.iosNavBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  // Leading
                  if (leading != null)
                    leading!
                  else if (automaticallyImplyLeading && canPop)
                    _buildBackButton(context, isDark),
                  
                  // Title
                  Expanded(
                    child: centerTitle 
                        ? Center(child: _buildTitle(context, isDark))
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: (leading != null || (automaticallyImplyLeading && canPop)) 
                                    ? AppSpacing.md 
                                    : 0,
                              ),
                              child: _buildTitle(context, isDark),
                            ),
                          ),
                  ),
                  
                  // Actions
                  if (actions != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ],
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chevron_left,
              size: AppSpacing.iconLg,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            Text(
              'Back',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    if (titleWidget != null) return titleWidget!;
    if (title == null) return const SizedBox.shrink();
    
    return Text(
      title!,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
    AppSpacing.iosNavBarHeight + 44, // Approximate safe area top
  );
}

// iOS-style large title navigation bar
class AppleLargeNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Widget? bottom;

  const AppleLargeNavigationBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.background),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation bar
            Container(
              height: AppSpacing.iosNavBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  // Leading
                  if (leading != null)
                    leading!
                  else if (automaticallyImplyLeading && canPop)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              size: AppSpacing.iconLg,
                              color: isDark ? AppColors.darkPrimary : AppColors.primary,
                            ),
                            Text(
                              'Back',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Actions
                  if (actions != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ],
                ],
              ),
            ),
            
            // Large title
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
    AppSpacing.iosNavBarHeight + 60 + 44, // Nav bar + Large title + Safe area
  );
}

// iOS-style action button for navigation bars
class AppleNavBarAction extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDisabled;

  const AppleNavBarAction({
    super.key,
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDisabled
                ? (isDark ? AppColors.darkSystemGray : AppColors.systemGray)
                : isDestructive
                    ? (isDark ? AppColors.darkError : AppColors.error)
                    : (isDark ? AppColors.darkPrimary : AppColors.primary),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// iOS-style icon button for navigation bars
class AppleNavBarIconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final String? tooltip;

  const AppleNavBarIconAction({
    super.key,
    required this.icon,
    this.onPressed,
    this.isDisabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget button = GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          icon,
          size: AppSpacing.iconMd,
          color: isDisabled
              ? (isDark ? AppColors.darkSystemGray : AppColors.systemGray)
              : (isDark ? AppColors.darkPrimary : AppColors.primary),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}