import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/survey_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/repositories/survey_repository.dart';
import '../../../providers/survey_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../expense/widgets/expense_form_dialog.dart';

class SurveyDetailScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const SurveyDetailScreen({
    super.key,
    required this.surveyId,
  });

  @override
  ConsumerState<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends ConsumerState<SurveyDetailScreen> {
  SurveyModel? _survey;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      SurveyModel? survey;
      
      // Use demo data or repository based on mode
      if (AppConfig.useDemoMode) {
        survey = DemoSurveyData.getSurveyById(widget.surveyId);
      } else {
        final repository = ref.read(surveyRepositoryProvider);
        if (repository != null) {
          survey = await repository.getSurveyById(widget.surveyId);
        } else {
          survey = DemoSurveyData.getSurveyById(widget.surveyId);
        }
      }
      
      setState(() {
        _survey = survey;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final loc = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteSurvey),
        content: Text(loc.deleteSurveyConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && _survey != null) {
      try {
        // Use demo data or repository based on mode
        if (AppConfig.useDemoMode) {
          DemoSurveyData.deleteSurvey(_survey!.id!);
        } else {
          final repository = ref.read(surveyRepositoryProvider);
          if (repository != null) {
            await repository.deleteSurvey(_survey!.id!);
          } else {
            DemoSurveyData.deleteSurvey(_survey!.id!);
          }
        }
        
        ref.read(surveyListProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.surveyDeleted),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _handleEdit() {
    if (_survey != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.surveyForm,
        arguments: {'surveyId': _survey!.id},
      );
    }
  }

  void _handleGenerateInvoice() {
    if (_survey != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.invoice,
        arguments: {'surveyId': _survey!.id},
      );
    }
  }

  Future<void> _handleCall() async {
    if (_survey != null) {
      // Copy phone number to clipboard
      await Clipboard.setData(ClipboardData(text: _survey!.mobileNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).phoneCopied),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.surveyDetails),
        actions: [
          if (_survey != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _handleEdit,
              tooltip: loc.edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _handleDelete,
              tooltip: loc.delete,
            ),
          ],
        ],
      ),
      body: _buildBody(loc),
      floatingActionButton: _survey != null && _survey!.status == SurveyStatus.done
          ? FloatingActionButton.extended(
              onPressed: _handleGenerateInvoice,
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(loc.generateInvoice),
            )
          : null,
    );
  }

  Widget _buildBody(AppLocalizations loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              loc.errorLoadingSurvey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSurvey,
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
            ),
          ],
        ),
      );
    }

    if (_survey == null) {
      return Center(
        child: Text(loc.surveyNotFound),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSurvey,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(_survey!, isDark),
            
            const SizedBox(height: 24),
            
            // Survey Info Card
            _buildInfoCard(
              title: loc.surveyInformation,
              icon: Icons.description_outlined,
              isDark: isDark,
              children: [
                _buildInfoRow(loc.villageName, _survey!.villageName, isDark),
                _buildInfoRow(loc.surveyNumber, _survey!.surveyNumber, isDark),
                _buildInfoRow('Survey Type', _survey!.surveyType.displayName, isDark),
                _buildInfoRow(
                  loc.createdAt,
                  _formatDate(_survey!.createdAt),
                  isDark,
                ),
                _buildInfoRow(
                  loc.updatedAt,
                  _formatDate(_survey!.updatedAt),
                  isDark,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Applicant Info Card
            _buildInfoCard(
              title: loc.applicantInformation,
              icon: Icons.person_outline,
              isDark: isDark,
              children: [
                _buildInfoRow(loc.applicantName, _survey!.applicantName, isDark),
                _buildInfoRowWithAction(
                  loc.mobileNumber,
                  _survey!.mobileNumber,
                  Icons.phone_outlined,
                  _handleCall,
                  isDark,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Payment Info Card
            _buildPaymentCard(loc, isDark),
            
            const SizedBox(height: 16),
            
            // Linked Expenses Section
            // _buildLinkedExpensesSection(loc, isDark),
            //
            // const SizedBox(height: 16),
            
            // Invoice Status Card
            if (_survey!.invoiceUrl != null)
              _buildInvoiceCard(loc, isDark),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SurveyModel survey, bool isDark) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (survey.status) {
      case SurveyStatus.working:
        backgroundColor = AppColors.info.withValues(alpha: isDark ? 0.2 : 0.1);
        textColor = isDark ? AppColors.darkStatusWorking : AppColors.info;
        icon = Icons.engineering_outlined;
        break;
      case SurveyStatus.waiting:
        backgroundColor = AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1);
        textColor = isDark ? AppColors.darkStatusWaiting : AppColors.warning;
        icon = Icons.hourglass_empty_outlined;
        break;
      case SurveyStatus.done:
        backgroundColor = AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1);
        textColor = isDark ? AppColors.darkStatusDone : AppColors.success;
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 8),
          Text(
            survey.status.displayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Divider(height: 24, color: isDark ? AppColors.darkDivider : AppColors.divider),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithAction(
    String label,
    String value,
    IconData actionIcon,
    VoidCallback onAction,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(actionIcon, size: 20),
                  onPressed: onAction,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(AppLocalizations loc, bool isDark) {
    final isPaid = _survey!.pendingPayment <= 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  loc.paymentDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Divider(height: 24, color: isDark ? AppColors.darkDivider : AppColors.divider),
            
            _buildPaymentRow(
              loc.totalPayment,
              '₹${_survey!.totalPayment.toStringAsFixed(2)}',
              isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              isDark,
            ),
            _buildPaymentRow(
              loc.receivedPayment,
              '₹${_survey!.receivedPayment.toStringAsFixed(2)}',
              isDark ? AppColors.darkStatusDone : AppColors.success,
              isDark,
            ),
            Divider(height: 16, color: isDark ? AppColors.darkDivider : AppColors.divider),
            _buildPaymentRow(
              loc.pendingPayment,
              '₹${_survey!.pendingPayment.toStringAsFixed(2)}',
              isPaid ? (isDark ? AppColors.darkStatusDone : AppColors.success) : AppColors.error,
              isDark,
              isBold: true,
            ),
            
            if (!isPaid) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? AppColors.darkStatusWaiting : AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.paymentPending,
                        style: TextStyle(
                          color: isDark ? AppColors.darkStatusWaiting : AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, Color valueColor, bool isDark, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedExpensesSection(AppLocalizations loc, bool isDark) {
    final surveyId = _survey?.id;
    if (surveyId == null) return const SizedBox.shrink();
    
    return Consumer(
      builder: (context, ref, child) {
        final expensesAsync = ref.watch(expensesBySurveyProvider(surveyId));
        
        return expensesAsync.when(
          loading: () => Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.divider),
            ),
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => const SizedBox.shrink(),
          data: (expenses) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.divider),
              ),
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.surveyExpenses,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        // Add Expense button removed - survey detail is read-only view
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    if (expenses.isEmpty)
                      // Empty state
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.noLinkedExpenses,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Expenses list
                      Column(
                        children: [
                          ...expenses.map((expense) => _buildExpenseItem(expense, isDark)),
                          const SizedBox(height: 8),
                          // Total
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.totalExpenses,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  '₹${expenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense, bool isDark) {
    final categoryColor = _getCategoryColor(expense.category);
    final categoryIcon = _getCategoryIcon(expense.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Description and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.category.displayName} • ${_formatDate(expense.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '₹${expense.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpenseFormDialog(
        surveyId: _survey?.id,
      ),
    ).then((_) {
      // Refresh the expenses list after adding
      if (mounted) {
        ref.invalidate(expensesBySurveyProvider(_survey!.id!));
        setState(() {}); // Trigger rebuild to show updated expenses
      }
    });
  }

  Widget _buildInvoiceCard(AppLocalizations loc, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: (isDark ? AppColors.darkStatusDone : AppColors.success).withValues(alpha: 0.5)),
      ),
      color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: isDark ? AppColors.darkStatusDone : AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.invoiceGenerated,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.tapToViewInvoice,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: _handleGenerateInvoice,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Colors.blue;
      case ExpenseCategory.equipment:
        return Colors.orange;
      case ExpenseCategory.food:
        return Colors.green;
      case ExpenseCategory.fuel:
        return Colors.red;
      case ExpenseCategory.accommodation:
        return Colors.purple;
      case ExpenseCategory.communication:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.equipment:
        return Icons.build;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.fuel:
        return Icons.local_gas_station;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.communication:
        return Icons.phone;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
