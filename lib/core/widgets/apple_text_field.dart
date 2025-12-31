import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppleTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool showClearButton;

  const AppleTextField({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.showClearButton = false,
  });

  @override
  State<AppleTextField> createState() => _AppleTextFieldState();
}

class _AppleTextFieldState extends State<AppleTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError 
                    ? (isDark ? AppColors.darkError : AppColors.error)
                    : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
            border: Border.all(
              color: hasError 
                  ? (isDark ? AppColors.darkError : AppColors.error)
                  : _isFocused 
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : Colors.transparent,
              width: _isFocused || hasError ? 2 : 0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText && !_showPassword,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            autofocus: widget.autofocus,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: _buildSuffixIcon(isDark),
              counterText: '',
            ),
          ),
        ),
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasError 
                    ? (isDark ? AppColors.darkError : AppColors.error)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    final List<Widget> suffixWidgets = [];

    // Clear button
    if (widget.showClearButton && 
        widget.controller != null && 
        widget.controller!.text.isNotEmpty &&
        _isFocused) {
      suffixWidgets.add(
        GestureDetector(
          onTap: () {
            widget.controller!.clear();
            widget.onChanged?.call('');
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.iosXs),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              size: AppSpacing.iosIconSm,
              color: isDark ? AppColors.darkSurface : AppColors.surface,
            ),
          ),
        ),
      );
    }

    // Password visibility toggle
    if (widget.obscureText) {
      suffixWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          child: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
            size: AppSpacing.iosIconMd,
            color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
          ),
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      suffixWidgets.add(widget.suffixIcon!);
    }

    if (suffixWidgets.isEmpty) return null;

    if (suffixWidgets.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: suffixWidgets.first,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: suffixWidgets
            .map((widget) => Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: widget,
                ))
            .toList(),
      ),
    );
  }
}

// iOS-style search field
class AppleSearchField extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppleSearchField({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSystemGray6 : AppColors.systemGray6,
        borderRadius: BorderRadius.circular(AppSpacing.iosRadiusMd),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autofocus,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: placeholder ?? 'Search',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: AppSpacing.iosIconMd,
            color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? GestureDetector(
                  onTap: () {
                    controller?.clear();
                    onChanged?.call('');
                    onClear?.call();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.iosXs),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSystemGray : AppColors.systemGray,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: AppSpacing.iosIconSm,
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}