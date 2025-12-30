import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class EmptySurveyWidget extends StatelessWidget {
  final bool isSearching;
  final VoidCallback? onAddSurvey;

  const EmptySurveyWidget({
    super.key,
    this.isSearching = false,
    this.onAddSurvey,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            /*Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_outlined : Icons.map_outlined,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),*/

            // Title
            Text(
              isSearching ? loc.noSearchResults : loc.noSurveys,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              isSearching ? loc.tryDifferentSearch : loc.addFirstSurvey,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            // Add Survey Button (only when not searching)
            if (!isSearching && onAddSurvey != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAddSurvey,
                icon: const Icon(Icons.add),
                label: Text(loc.addSurvey),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
