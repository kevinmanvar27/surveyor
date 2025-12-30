import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';
import '../core/config/app_config.dart';
import 'auth_provider.dart';

/// Demo data for testing without Firebase
class DemoExpenseData {
  static List<ExpenseModel> _demoExpenses = [];
  
  static void initialize(String userId) {
    if (_demoExpenses.isEmpty) {
      _demoExpenses = [
        ExpenseModel(
          id: 'demo_exp_1',
          userId: userId,
          surveyId: 'demo_1', // Linked to Greenfield Village survey
          description: 'Fuel for site visit',
          amount: 500,
          category: ExpenseCategory.fuel,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ExpenseModel(
          id: 'demo_exp_2',
          userId: userId,
          surveyId: 'demo_1', // Linked to Greenfield Village survey
          description: 'Lunch during survey',
          amount: 250,
          category: ExpenseCategory.food,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ExpenseModel(
          id: 'demo_exp_3',
          userId: userId,
          surveyId: 'demo_2', // Linked to Sunrise Township survey
          description: 'Equipment repair',
          amount: 1500,
          category: ExpenseCategory.equipment,
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ExpenseModel(
          id: 'demo_exp_4',
          userId: userId,
          // No surveyId - standalone expense
          description: 'Travel to remote village',
          amount: 800,
          category: ExpenseCategory.travel,
          date: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ExpenseModel(
          id: 'demo_exp_5',
          userId: userId,
          // No surveyId - standalone expense
          description: 'Mobile recharge',
          amount: 199,
          category: ExpenseCategory.communication,
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];
    }
  }

  static List<ExpenseModel> getExpenses(String userId) {
    initialize(userId);
    return List.from(_demoExpenses);
  }

  static List<ExpenseModel> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    initialize(userId);
    return _demoExpenses
        .where((e) {
          final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
          final start = DateTime(startDate.year, startDate.month, startDate.day);
          final end = DateTime(endDate.year, endDate.month, endDate.day);
          return (expenseDate.isAtSameMomentAs(start) || expenseDate.isAfter(start)) &&
                 (expenseDate.isAtSameMomentAs(end) || expenseDate.isBefore(end));
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  static String createExpense(ExpenseModel expense) {
    final id = 'demo_exp_${DateTime.now().millisecondsSinceEpoch}';
    final newExpense = ExpenseModel(
      id: id,
      userId: expense.userId,
      surveyId: expense.surveyId,
      description: expense.description,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _demoExpenses.insert(0, newExpense);
    return id;
  }

  static bool updateExpense(ExpenseModel expense) {
    final index = _demoExpenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _demoExpenses[index] = expense;
      return true;
    }
    return false;
  }

  static bool deleteExpense(String expenseId) {
    final index = _demoExpenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      _demoExpenses.removeAt(index);
      return true;
    }
    return false;
  }
}

/// Expense state
class ExpenseState {
  final List<ExpenseModel> expenses;
  final bool isLoading;
  final String? errorMessage;
  final ExpenseTimePeriod selectedPeriod;
  final DateTime selectedDate;

  ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPeriod = ExpenseTimePeriod.month,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  /// Initial state factory
  factory ExpenseState.initial() => ExpenseState();

  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    bool? isLoading,
    String? errorMessage,
    ExpenseTimePeriod? selectedPeriod,
    DateTime? selectedDate,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  /// Alias for error message (used in UI)
  String? get error => errorMessage;

  /// Get total expenses amount
  double get totalExpenses =>
      expenses.fold(0.0, (total, expense) => total + expense.amount);

  /// Alias for totalExpenses (used in UI)
  double get totalAmount => totalExpenses;

  /// Get filtered expenses (same as expenses for now, filtering is done in notifier)
  List<ExpenseModel> get filteredExpenses => expenses;

  /// Get expenses by category
  Map<ExpenseCategory, double> get expensesByCategory {
    final Map<ExpenseCategory, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  /// Get start date of current period
  DateTime? get startDate => dateRange.start;

  /// Get end date of current period
  DateTime? get endDate => dateRange.end;

  /// Get date range based on selected period
  DateRange get dateRange {
    final now = selectedDate;
    switch (selectedPeriod) {
      case ExpenseTimePeriod.day:
        return DateRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case ExpenseTimePeriod.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
        );
      case ExpenseTimePeriod.month:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case ExpenseTimePeriod.year:
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      case ExpenseTimePeriod.all:
        return DateRange(
          start: DateTime(2000),
          end: DateTime(2100),
        );
    }
  }
}



/// Date range helper
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

/// Expense notifier
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository? _repository;
  final String? _userId;

  ExpenseNotifier(this._repository, this._userId) : super(ExpenseState.initial()) {
    if (_userId != null) {
      loadExpenses();
    }
  }

  /// Load expenses based on current period
  Future<void> loadExpenses() async {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dateRange = state.dateRange;

      if (AppConfig.useDemoMode || _repository == null) {
        // Demo mode
        final expenses = DemoExpenseData.getExpensesByDateRange(
          userId,
          dateRange.start,
          dateRange.end,
        );
        state = state.copyWith(expenses: expenses, isLoading: false);
      } else {
        // Firebase mode
        final expenses = await _repository.getExpensesByDateRange(
          userId,
          dateRange.start,
          dateRange.end,
        );
        state = state.copyWith(expenses: expenses, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load expenses: $e',
      );
    }
  }

  /// Change time period
  void setTimePeriod(ExpenseTimePeriod period) {
    state = state.copyWith(selectedPeriod: period, selectedDate: DateTime.now());
    loadExpenses();
  }

  /// Change selected date
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadExpenses();
  }

  /// Change time period and date together (used by calendar dialog)
  /// This ensures the date range is calculated correctly for the new period
  void setTimePeriodAndDate(ExpenseTimePeriod period, DateTime date) {
    state = state.copyWith(selectedPeriod: period, selectedDate: date);
    loadExpenses();
  }

  /// Navigate to previous period
  void previousPeriod() {
    final current = state.selectedDate;
    DateTime newDate;
    
    switch (state.selectedPeriod) {
      case ExpenseTimePeriod.day:
        newDate = current.subtract(const Duration(days: 1));
        break;
      case ExpenseTimePeriod.week:
        newDate = current.subtract(const Duration(days: 7));
        break;
      case ExpenseTimePeriod.month:
        newDate = DateTime(current.year, current.month - 1, current.day);
        break;
      case ExpenseTimePeriod.year:
        newDate = DateTime(current.year - 1, current.month, current.day);
        break;
      case ExpenseTimePeriod.all:
        return;
    }
    
    state = state.copyWith(selectedDate: newDate);
    loadExpenses();
  }

  /// Navigate to next period
  void nextPeriod() {
    final current = state.selectedDate;
    DateTime newDate;
    
    switch (state.selectedPeriod) {
      case ExpenseTimePeriod.day:
        newDate = current.add(const Duration(days: 1));
        break;
      case ExpenseTimePeriod.week:
        newDate = current.add(const Duration(days: 7));
        break;
      case ExpenseTimePeriod.month:
        newDate = DateTime(current.year, current.month + 1, current.day);
        break;
      case ExpenseTimePeriod.year:
        newDate = DateTime(current.year + 1, current.month, current.day);
        break;
      case ExpenseTimePeriod.all:
        return;
    }
    
    // Don't allow future dates
    if (newDate.isAfter(DateTime.now())) return;
    
    state = state.copyWith(selectedDate: newDate);
    loadExpenses();
  }

  /// Add new expense
  Future<bool> addExpense({
    required String description,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? surveyId, // Add optional surveyId parameter
  }) async {
    final userId = _userId;
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final expense = ExpenseModel(
        id: '', // Will be set by repository or demo data
        userId: userId,
        surveyId: surveyId, // Include surveyId in expense creation
        description: description,
        amount: amount,
        category: category,
        date: date,
      );

      final repository = _repository;
      if (AppConfig.useDemoMode || repository == null) {
        DemoExpenseData.createExpense(expense);
      } else {
        await repository.createExpense(expense);
      }

      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add expense: $e',
      );
      return false;
    }
  }

  /// Update expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = _repository;
      if (AppConfig.useDemoMode || repository == null) {
        DemoExpenseData.updateExpense(expense);
      } else {
        await repository.updateExpense(expense);
      }

      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update expense: $e',
      );
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = _repository;
      if (AppConfig.useDemoMode || repository == null) {
        DemoExpenseData.deleteExpense(expenseId);
      } else {
        await repository.deleteExpense(expenseId);
      }

      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete expense: $e',
      );
      return false;
    }
  }
}

/// Providers
final expenseRepositoryProvider = Provider<ExpenseRepository?>((ref) {
  if (AppConfig.useDemoMode) {
    return null;
  }
  return ExpenseRepository(FirebaseFirestore.instance);
});

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid;
  return ExpenseNotifier(repository, userId);
});

/// Provider to get expenses linked to a specific survey
final expensesBySurveyProvider = FutureProvider.family<List<ExpenseModel>, String>((ref, surveyId) async {
  final authState = ref.watch(authProvider);
  final userId = authState.userModel?.uid ?? authState.user?.uid;
  
  if (userId == null) return [];
  
  if (AppConfig.useDemoMode) {
    // Get all demo expenses and filter by surveyId
    final allExpenses = DemoExpenseData.getExpenses(userId);
    return allExpenses.where((e) => e.surveyId == surveyId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  } else {
    final repository = ref.read(expenseRepositoryProvider);
    if (repository == null) return [];
    
    // Query expenses by surveyId
    return await repository.getExpensesBySurvey(surveyId);
  }
});
