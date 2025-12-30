import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/expense_model.dart';
import '../../../core/utils/image_utils.dart';
import '../widgets/expense_form_dialog.dart';
import '../widgets/expense_calendar_dialog.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load expenses on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseProvider.notifier).loadExpenses();
    });
  }

  void _onPeriodChanged(ExpenseTimePeriod period) {
    ref.read(expenseProvider.notifier).setTimePeriod(period);
  }

  void _onPreviousPeriod() {
    ref.read(expenseProvider.notifier).previousPeriod();
  }

  void _onNextPeriod() {
    ref.read(expenseProvider.notifier).nextPeriod();
  }

  Future<void> _onCalendarTap() async {
    final expenseState = ref.read(expenseProvider);
    
    final result = await showDialog<CalendarSelectionResult>(
      context: context,
      builder: (context) => ExpenseCalendarDialog(
        initialDate: expenseState.selectedDate,
        initialPeriod: expenseState.selectedPeriod,
      ),
    );
    
    if (result != null) {
      // Apply the selection based on granularity
      final notifier = ref.read(expenseProvider.notifier);
      
      // First set the time period, then set the date
      // This ensures the date range is calculated correctly
      notifier.setTimePeriodAndDate(result.period, result.selectedDate);
    }
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExpenseFormDialog(),
    ).then((_) {
      // Refresh expenses after dialog closes
      ref.read(expenseProvider.notifier).loadExpenses();
    });
  }

  void _showEditExpenseDialog(ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormDialog(expense: expense),
    ).then((_) {
      // Refresh expenses after dialog closes
      ref.read(expenseProvider.notifier).loadExpenses();
    });
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.deleteExpense),
        content: Text(loc.deleteExpenseConfirmation),
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

    if (confirmed == true && expense.id != null) {
      final success = await ref.read(expenseProvider.notifier).deleteExpense(expense.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? loc.expenseDeleted : loc.error),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  String _getCategoryName(ExpenseCategory category, AppLocalizations loc) {
    switch (category) {
      case ExpenseCategory.travel:
        return loc.categoryTravel;
      case ExpenseCategory.equipment:
        return loc.categoryEquipment;
      case ExpenseCategory.food:
        return loc.categoryFood;
      case ExpenseCategory.fuel:
        return loc.categoryFuel;
      case ExpenseCategory.accommodation:
        return loc.categoryAccommodation;
      case ExpenseCategory.communication:
        return loc.categoryCommunication;
      case ExpenseCategory.other:
        return loc.categoryOther;
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final expenseState = ref.watch(expenseProvider);
    final authState = ref.watch(authProvider);
    final userModel = authState.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
        child: CustomScrollView(
          slivers: [
            // Gradient App Bar with user info
            SliverAppBar(
              expandedHeight: 200,
              // floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Profile Image
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: userModel?.profileImageBase64 != null &&
                                            ImageUtils.isValidBase64(userModel!.profileImageBase64)
                                        ? Image.memory(
                                            ImageUtils.base64ToBytes(userModel.profileImageBase64!)!,
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.person, color: Colors.white, size: 28),
                                          )
                                        : const Icon(Icons.person, color: Colors.white, size: 28),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loc.expenses,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        _getDateRangeText(expenseState, loc),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Total Expenses Display
                            _buildTotalExpensesCard(expenseState, loc),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Time Period Filter Buttons
            SliverPersistentHeader(
              pinned: true,
              delegate: _PeriodFilterDelegate(
                selectedPeriod: expenseState.selectedPeriod,
                loc: loc,
                onPeriodChanged: _onPeriodChanged,
                onPrevious: _onPreviousPeriod,
                onNext: _onNextPeriod,
                onCalendarTap: _onCalendarTap,
              ),
            ),

            // Content
            if (expenseState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (expenseState.error != null)
              SliverFillRemaining(
                child: _buildErrorState(expenseState.error!, loc),
              )
            else if (expenseState.filteredExpenses.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(loc),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Breakdown - commented out for future use
                      // _buildCategoryBreakdown(expenseState, loc),
                      // const SizedBox(height: 24),
                      
                      // Recent Expenses List
                      _buildExpensesList(expenseState, loc),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          loc.addExpense,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getDateRangeText(ExpenseState state, AppLocalizations loc) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final start = state.startDate;
    final end = state.endDate;
    
    if (start != null && end != null) {
      if (state.selectedPeriod == ExpenseTimePeriod.day) {
        return dateFormat.format(start);
      }
      return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
    }
    return loc.allExpenses;
  }

  Widget _buildTotalExpensesCard(ExpenseState state, AppLocalizations loc) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.totalExpenses,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(state.totalAmount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpenseState state, AppLocalizations loc) {
    final categoryTotals = state.expensesByCategory;
    if (categoryTotals.isEmpty) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.pie_chart, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              loc.byCategory,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: sortedCategories.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percentage = state.totalAmount > 0
                  ? (amount / state.totalAmount * 100)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCategoryName(category, loc),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(category),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesList(ExpenseState state, AppLocalizations loc) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE'); // Day name like "Saturday"

    // Group expenses by date
    final Map<String, List<ExpenseModel>> groupedExpenses = {};
    for (final expense in state.filteredExpenses) {
      final dateKey = dateFormat.format(expense.date);
      groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
    }

    // Sort date keys (most recent first)
    final sortedDateKeys = groupedExpenses.keys.toList()
      ..sort((a, b) {
        final dateA = dateFormat.parse(a);
        final dateB = dateFormat.parse(b);
        return dateB.compareTo(dateA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt_long, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              loc.recentExpenses,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const Spacer(),
            Text(
              '${state.filteredExpenses.length} ${loc.items}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Date-wise sections
        ...sortedDateKeys.map((dateKey) {
          final expenses = groupedExpenses[dateKey]!;
          final date = dateFormat.parse(dateKey);
          final isToday = _isToday(date);
          final isYesterday = _isYesterday(date);
          
          // Calculate total for this date
          final dayTotal = expenses.fold<double>(0, (sum, e) => sum + e.amount);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? 'Today' : isYesterday ? 'Yesterday' : dayFormat.format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            dateKey,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currencyFormat.format(dayTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Expenses for this date
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.border.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Dismissible(
                      key: Key(expense.id ?? 'expense_${dateKey}_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: index == 0 && expenses.length == 1
                              ? BorderRadius.circular(16)
                              : index == 0
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    )
                                  : index == expenses.length - 1
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        )
                                      : null,
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        await _deleteExpense(expense);
                        return false;
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(expense.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(expense.category),
                            color: _getCategoryColor(expense.category),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          expense.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _getCategoryName(expense.category, loc),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Text(
                          currencyFormat.format(expense.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onTap: () => _showEditExpenseDialog(expense),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 64,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.noExpenses,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.noExpensesDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddExpenseDialog,
              icon: const Icon(Icons.add),
              label: Text(loc.addExpense),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              loc.error,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(expenseProvider.notifier).loadExpenses(),
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Period Filter Delegate for sticky filter buttons
class _PeriodFilterDelegate extends SliverPersistentHeaderDelegate {
  final ExpenseTimePeriod selectedPeriod;
  final AppLocalizations loc;
  final Function(ExpenseTimePeriod) onPeriodChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCalendarTap;

  _PeriodFilterDelegate({
    required this.selectedPeriod,
    required this.loc,
    required this.onPeriodChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onCalendarTap,
  });

  String _getPeriodLabel(ExpenseTimePeriod period) {
    switch (period) {
      case ExpenseTimePeriod.day:
        return loc.dailyExpenses;
      case ExpenseTimePeriod.week:
        return loc.weeklyExpenses;
      case ExpenseTimePeriod.month:
        return loc.monthlyExpenses;
      case ExpenseTimePeriod.year:
        return loc.yearlyExpenses;
      case ExpenseTimePeriod.all:
        return loc.allExpenses;
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Navigation Row with Previous/Next buttons and Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Previous button
                // IconButton(
                //   onPressed: onPrevious,
                //   icon: const Icon(Icons.chevron_left),
                //   style: IconButton.styleFrom(
                //     backgroundColor: Colors.white,
                //     foregroundColor: AppColors.primary,
                //   ),
                // ),
                // const SizedBox(width: 8),
                // Filter buttons
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ExpenseTimePeriod.values.map((period) {
                        final isSelected = period == selectedPeriod;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(
                              _getPeriodLabel(period),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) => onPeriodChanged(period),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            checkmarkColor: Colors.white,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Next button
                /*IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),*/
                const SizedBox(width: 4),
                // Calendar button for date picker
                IconButton(
                  onPressed: onCalendarTap,
                  icon: const Icon(Icons.calendar_month),
                  tooltip: loc.jumpToDate,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _PeriodFilterDelegate oldDelegate) {
    // Only rebuild when selectedPeriod changes - callbacks are stable
    return oldDelegate.selectedPeriod != selectedPeriod;
  }
}
