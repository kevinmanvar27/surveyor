import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class SurveySearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSearch;
  final VoidCallback? onClear;

  const SurveySearchBar({
    super.key,
    this.initialValue = '',
    required this.onSearch,
    this.onClear,
  });

  @override
  State<SurveySearchBar> createState() => _SurveySearchBarState();
}

class _SurveySearchBarState extends State<SurveySearchBar> {
  late TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _showClear = widget.initialValue.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });
  }

  void _handleClear() {
    _controller.clear();
    widget.onSearch('');
    widget.onClear?.call();
  }

  void _handleSubmit(String value) {
    widget.onSearch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: _handleSubmit,
        onChanged: (value) {
          // Debounced search - trigger after user stops typing
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_controller.text == value) {
              widget.onSearch(value.trim());
            }
          });
        },
        decoration: InputDecoration(
          hintText: loc.searchSurveys,
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextHint : AppColors.textSecondary,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          suffixIcon: _showClear
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  onPressed: _handleClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
