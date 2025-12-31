import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/models/survey_model.dart';
import '../data/models/expense_model.dart';
import '../core/config/app_config.dart';
import 'auth_provider.dart';

/// State for transaction list
class TransactionState {
  final List<TransactionModel> transactions;
  final List<TransactionGroup> groupedTransactions;
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalCredit;
  final double totalDebit;

  TransactionState({
    this.transactions = const [],
    this.groupedTransactions = const [],
    this.isLoading = false,
    this.error,
    this.startDate,
    this.endDate,
    this.totalCredit = 0,
    this.totalDebit = 0,
  });

  double get netBalance => totalCredit - totalDebit;

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionGroup>? groupedTransactions,
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    double? totalCredit,
    double? totalDebit,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalCredit: totalCredit ?? this.totalCredit,
      totalDebit: totalDebit ?? this.totalDebit,
    );
  }
}

/// Provider for transaction state
final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref);
});

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionNotifier(this._ref) : super(TransactionState());

  /// Load all transactions (combining surveys and expenses)
  Future<void> loadTransactions({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (AppConfig.useDemoMode) {
        await _loadDemoTransactions();
        return;
      }

      final userId = _ref.read(authProvider).user?.uid;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      final List<TransactionModel> allTransactions = [];

      // 1. Load survey-based transactions (total payment and received payments)
      final surveysSnapshot = await _firestore
          .collection('surveys')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in surveysSnapshot.docs) {
        final survey = SurveyModel.fromFirestore(doc);
        
        // Only add actual payment receipts as transactions (not total payment which is just expected amount)
        for (final receipt in survey.paymentReceipts) {
          allTransactions.add(TransactionModel(
            id: '${survey.id}_receipt_${receipt.id}',
            userId: userId,
            surveyId: survey.id,
            type: TransactionType.receivedPayment,
            description: survey.applicantName,
            amount: receipt.amount,
            isCredit: true,
            date: receipt.receivedDate,
            surveyNumber: survey.surveyNumber,
            applicantName: survey.applicantName,
          ));
        }
      }

      // 2. Load expense transactions
      final expensesSnapshot = await _firestore
          .collection('expenses')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in expensesSnapshot.docs) {
        final expense = ExpenseModel.fromFirestore(doc);
        
        // Find linked survey info if available
        String? surveyNumber;
        String? applicantName;
        if (expense.surveyId != null) {
          try {
            final surveyDoc = await _firestore
                .collection('surveys')
                .doc(expense.surveyId)
                .get();
            if (surveyDoc.exists) {
              final survey = SurveyModel.fromFirestore(surveyDoc);
              surveyNumber = survey.surveyNumber;
              applicantName = survey.applicantName;
            }
          } catch (e) {
            debugPrint('Error fetching linked survey: $e');
          }
        }

        allTransactions.add(TransactionModel(
          id: expense.id,
          userId: userId,
          surveyId: expense.surveyId,
          expenseId: expense.id,
          type: TransactionType.expense,
          description: expense.description,
          amount: expense.amount,
          isCredit: false, // Expenses are debits
          date: expense.date,
          surveyNumber: surveyNumber,
          applicantName: applicantName,
          expenseCategory: expense.category.displayName,
        ));
      }

      // Filter by date range if provided
      List<TransactionModel> filteredTransactions = allTransactions;
      if (startDate != null) {
        filteredTransactions = filteredTransactions
            .where((t) => t.date.isAfter(startDate.subtract(const Duration(days: 1))))
            .toList();
      }
      if (endDate != null) {
        filteredTransactions = filteredTransactions
            .where((t) => t.date.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      // Sort by date (newest first)
      filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Group by date
      final grouped = _groupTransactionsByDate(filteredTransactions);

      // Calculate totals
      final totalCredit = filteredTransactions
          .where((t) => t.isCredit)
          .fold(0.0, (total, t) => total + t.amount);
      final totalDebit = filteredTransactions
          .where((t) => !t.isCredit)
          .fold(0.0, (total, t) => total + t.amount);

      state = state.copyWith(
        transactions: filteredTransactions,
        groupedTransactions: grouped,
        isLoading: false,
        startDate: startDate,
        endDate: endDate,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
      );
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Group transactions by date
  List<TransactionGroup> _groupTransactionsByDate(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in transactions) {
      final dateKey = _getDateKey(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    // Convert to TransactionGroup list
    final groups = grouped.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      return TransactionGroup(
        date: date,
        transactions: entry.value,
      );
    }).toList();

    // Sort by date (newest first)
    groups.sort((a, b) => b.date.compareTo(a.date));

    return groups;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load demo transactions for testing
  Future<void> _loadDemoTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final demoTransactions = [
      // Today's transactions - only actual received payments, not expected totals
      TransactionModel(
        id: 'demo_2',
        userId: 'demo_user',
        surveyId: 'survey_1',
        type: TransactionType.receivedPayment,
        description: 'John Smith',
        amount: 5000,
        isCredit: true,
        date: now.subtract(const Duration(days: 3)),
        surveyNumber: 'SRV-2024-001',
        applicantName: 'John Smith',
      ),
      TransactionModel(
        id: 'demo_2b',
        userId: 'demo_user',
        surveyId: 'survey_1',
        type: TransactionType.receivedPayment,
        description: 'John Smith',
        amount: 5000,
        isCredit: true,
        date: now,
        surveyNumber: 'SRV-2024-001',
        applicantName: 'John Smith',
      ),
      TransactionModel(
        id: 'demo_3',
        userId: 'demo_user',
        surveyId: 'survey_1',
        expenseId: 'expense_1',
        type: TransactionType.expense,
        description: 'Travel to site',
        amount: 500,
        isCredit: false,
        date: now,
        surveyNumber: 'SRV-2024-001',
        applicantName: 'John Smith',
        expenseCategory: 'Travel',
      ),

      // Yesterday's transactions
      TransactionModel(
        id: 'demo_5',
        userId: 'demo_user',
        expenseId: 'expense_2',
        type: TransactionType.expense,
        description: 'Fuel for vehicle',
        amount: 800,
        isCredit: false,
        date: now.subtract(const Duration(days: 1)),
        expenseCategory: 'Fuel',
      ),

      // Last week transactions
      TransactionModel(
        id: 'demo_6',
        userId: 'demo_user',
        surveyId: 'survey_3',
        type: TransactionType.receivedPayment,
        description: 'Raj Kumar',
        amount: 12000,
        isCredit: true,
        date: now.subtract(const Duration(days: 5)),
        surveyNumber: 'SRV-2024-003',
        applicantName: 'Raj Kumar',
      ),
      TransactionModel(
        id: 'demo_7',
        userId: 'demo_user',
        expenseId: 'expense_3',
        type: TransactionType.expense,
        description: 'Equipment purchase',
        amount: 2500,
        isCredit: false,
        date: now.subtract(const Duration(days: 5)),
        expenseCategory: 'Equipment',
      ),
    ];

    // Sort and group
    demoTransactions.sort((a, b) => b.date.compareTo(a.date));
    final grouped = _groupTransactionsByDate(demoTransactions);

    final totalCredit = demoTransactions
        .where((t) => t.isCredit)
        .fold(0.0, (total, t) => total + t.amount);
    final totalDebit = demoTransactions
        .where((t) => !t.isCredit)
        .fold(0.0, (total, t) => total + t.amount);

    state = state.copyWith(
      transactions: demoTransactions,
      groupedTransactions: grouped,
      isLoading: false,
      totalCredit: totalCredit,
      totalDebit: totalDebit,
    );
  }

  /// Set date filter
  void setDateFilter(DateTime? start, DateTime? end) {
    loadTransactions(startDate: start, endDate: end);
  }

  /// Clear date filter
  void clearDateFilter() {
    loadTransactions();
  }

  /// Refresh transactions
  Future<void> refresh() async {
    await loadTransactions(startDate: state.startDate, endDate: state.endDate);
  }
}
