import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppleBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;
  final bool isScrollControlled;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool hasBlur;

  const AppleBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.isScrollControlled = false,
    this.height,
    this.padding,
    this.hasBlur = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    bool isScrollControlled = false,
    double? height,
    EdgeInsetsGeometry? padding,
    bool hasBlur = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AppleBottomSheet(
        title: title,
        showHandle: showHandle,
        isScrollControlled: isScrollControlled,
        height: height,
        padding: padding,
        hasBlur: hasBlur,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    Widget content = Container(
      width: double.infinity,
      constraints: height != null 
          ? BoxConstraints(maxHeight: height!)
          : BoxConstraints(
              maxHeight: mediaQuery.size.height * 0.9,
            ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.iosRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.shadow,
            offset: const Offset(0, -2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          if (showHandle) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSystemGray4 : AppColors.systemGray4,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          
          // Title
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ],
          
          // Content
          Flexible(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: bottomPadding),
        ],
      ),
    );

    if (hasBlur) {
      content = ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.iosRadiusLg),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: content,
        ),
      );
    }

    return content;
  }
}

// iOS-style action sheet
class AppleActionSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final List<AppleActionSheetAction> actions;
  final AppleActionSheetAction? cancelAction;

  const AppleActionSheet({
    super.key,
    this.title,
    this.message,
    required this.actions,
    this.cancelAction,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AppleActionSheetAction> actions,
    AppleActionSheetAction? cancelAction,
  }) {
    return AppleBottomSheet.show<T>(
      context: context,
      showHandle: false,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: AppleActionSheet(
        title: title,
        message: message,
        actions: actions,
        cancelAction: cancelAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main action sheet
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
          ),
          child: Column(
            children: [
              // Title and message
              if (title != null || message != null) ...[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      if (title != null) ...[
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (message != null) const SizedBox(height: AppSpacing.sm),
                      ],
                      if (message != null)
                        Text(
                          message!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                ),
              ],
              
              // Actions
              ...actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                
                return Column(
                  children: [
                    _buildActionButton(context, action, isDark),
                    if (index < actions.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: isDark ? AppColors.darkDivider : AppColors.divider,
                      ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        
        // Cancel action
        if (cancelAction != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
            ),
            child: _buildActionButton(context, cancelAction!, isDark),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AppleActionSheetAction action, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Text(
            action.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: action.isDestructive
                  ? (isDark ? AppColors.darkError : AppColors.error)
                  : action.isDefault
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
              fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AppleActionSheetAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AppleActionSheetAction({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

// iOS-style picker bottom sheet
class ApplePickerSheet<T> extends StatelessWidget {
  final String? title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemBuilder;
  final ValueChanged<T>? onChanged;
  final String? confirmText;
  final String? cancelText;

  const ApplePickerSheet({
    super.key,
    this.title,
    required this.items,
    this.selectedItem,
    required this.itemBuilder,
    this.onChanged,
    this.confirmText,
    this.cancelText,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<T> items,
    T? selectedItem,
    required String Function(T) itemBuilder,
    String? confirmText,
    String? cancelText,
  }) {
    T? currentSelection = selectedItem;
    
    return AppleBottomSheet.show<T>(
      context: context,
      title: title,
      isScrollControlled: true,
      height: 300,
      padding: EdgeInsets.zero,
      child: ApplePickerSheet<T>(
        items: items,
        selectedItem: selectedItem,
        itemBuilder: itemBuilder,
        confirmText: confirmText,
        cancelText: cancelText,
        onChanged: (value) => currentSelection = value,
      ),
    ).then((_) => currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    T? currentSelection = selectedItem;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      cancelText ?? 'Cancel',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(currentSelection);
                    },
                    child: Text(
                      confirmText ?? 'Done',
                      style: TextStyle(
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(
              height: 1,
              thickness: 0.5,
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
            
            // Picker
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == currentSelection;
                  
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentSelection = item;
                        });
                        onChanged?.call(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                itemBuilder(item),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                                      : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: AppSpacing.iosIconMd,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}