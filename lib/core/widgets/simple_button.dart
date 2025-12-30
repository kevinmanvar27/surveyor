import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isDestructive;
  final bool isLarge;

  const SimpleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.isDestructive = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonHeight = isLarge ? AppSpacing.iosButtonHeight + 8 : AppSpacing.iosButtonHeight;
    
    // Determine colors based on theme and button type
    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      if (isDestructive) return isDark ? AppColors.darkError : AppColors.error;
      return isDark ? AppColors.darkPrimary : AppColors.primary;
    }
    
    Color getTextColor() {
      if (textColor != null) return textColor!;
      if (isOutlined) {
        if (isDestructive) return isDark ? AppColors.darkError : AppColors.error;
        return isDark ? AppColors.darkPrimary : AppColors.primary;
      }
      return Colors.white;
    }
    
    Color getBorderColor() {
      if (isDestructive) return isDark ? AppColors.darkError : AppColors.error;
      return isDark ? AppColors.darkPrimary : AppColors.primary;
    }

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: AppSpacing.iosIconSm,
                height: AppSpacing.iosIconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: getTextColor(),
                ),
              )
            : (icon != null 
                ? Icon(icon, size: AppSpacing.iosIconMd) 
                : const SizedBox.shrink()),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isLarge ? 19 : 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: getTextColor(),
          side: BorderSide(color: getBorderColor(), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? AppSpacing.xl : AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: Size(0, buttonHeight),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: AppSpacing.iosIconSm,
              height: AppSpacing.iosIconSm,
              child: const CircularProgressIndicator(
                strokeWidth: 2, 
                color: Colors.white,
              ),
            )
          : (icon != null 
              ? Icon(icon, size: AppSpacing.iosIconMd) 
              : const SizedBox.shrink()),
      label: Text(
        text,
        style: TextStyle(
          fontSize: isLarge ? 19 : 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: getBackgroundColor(),
        foregroundColor: Colors.white,
        disabledBackgroundColor: isDark 
            ? AppColors.darkSystemGray5 
            : AppColors.systemGray5,
        disabledForegroundColor: isDark 
            ? AppColors.darkSystemGray3 
            : AppColors.systemGray3,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? AppSpacing.xl : AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        minimumSize: Size(0, buttonHeight),
      ),
    );
  }
}