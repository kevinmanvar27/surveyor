import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/survey_model.dart';
import '../../../providers/survey_provider.dart';

class SurveyFilterSheet extends ConsumerStatefulWidget {
  const SurveyFilterSheet({super.key});

  @override
  ConsumerState<SurveyFilterSheet> createState() => _SurveyFilterSheetState();
}

class _SurveyFilterSheetState extends ConsumerState<SurveyFilterSheet> {
  SurveyStatus? _selectedStatus;
  SurveySortOption _selectedSort = SurveySortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    final state = ref.read(surveyListProvider);
    // Convert String to SurveyStatus? for internal use
    _selectedStatus = state.statusFilter == 'All' 
        ? null 
        : SurveyStatus.values.where((s) => s.displayName == state.statusFilter).firstOrNull;
    _selectedSort = state.sortOption;
  }

  void _applyFilters() {
    // Convert SurveyStatus? to String for provider
    final statusString = _selectedStatus?.displayName ?? 'All';
    ref.read(surveyListProvider.notifier).setStatusFilter(statusString);
    ref.read(surveyListProvider.notifier).setSortOption(_selectedSort);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedSort = SurveySortOption.dateDesc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.filterAndSort,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(loc.reset),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter Section
          Text(
            loc.filterByStatus,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(null, loc.all, isDark),
              ...SurveyStatus.values.map((status) => _buildStatusChip(status, status.displayName, isDark)),
            ],
          ),
          const SizedBox(height: 24),

          // Sort Section
          Text(
            loc.sortBy,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildSortOption(SurveySortOption.dateDesc, loc.newestFirst, Icons.arrow_downward, isDark),
          _buildSortOption(SurveySortOption.dateAsc, loc.oldestFirst, Icons.arrow_upward, isDark),
          _buildSortOption(SurveySortOption.pendingDesc, loc.highestPendingFirst, Icons.currency_rupee, isDark),
          _buildSortOption(SurveySortOption.pendingAsc, loc.lowestPendingFirst, Icons.currency_rupee, isDark),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                loc.applyFilters,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusChip(SurveyStatus? status, String label, bool isDark) {
    final isSelected = _selectedStatus == status;
    Color chipColor;
    Color textColor;

    if (status == null) {
      chipColor = isSelected 
          ? Theme.of(context).primaryColor 
          : (isDark ? AppColors.darkBorder : AppColors.border);
      textColor = isSelected 
          ? Colors.white 
          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    } else {
      switch (status) {
        case SurveyStatus.working:
          chipColor = isSelected ? AppColors.info : AppColors.info.withValues(alpha: isDark ? 0.2 : 0.1);
          textColor = isSelected ? Colors.white : (isDark ? AppColors.darkStatusWorking : AppColors.info);
          break;
        case SurveyStatus.waiting:
          chipColor = isSelected ? AppColors.warning : AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1);
          textColor = isSelected ? Colors.white : (isDark ? AppColors.darkStatusWaiting : AppColors.warning);
          break;
        case SurveyStatus.done:
          chipColor = isSelected ? AppColors.success : AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1);
          textColor = isSelected ? Colors.white : (isDark ? AppColors.darkStatusDone : AppColors.success);
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(20),
          border: status == null && !isSelected
              ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.border)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(SurveySortOption option, String label, IconData icon, bool isDark) {
    final isSelected = _selectedSort == option;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSort = option;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
